# apps/payments/services/mtn_momo_service.py

import logging
import requests
import uuid
from datetime import datetime, timedelta
from django.conf import settings
from django.core.cache import cache

logger = logging.getLogger(__name__)


class MTNMoMoService:
    """
    Service d'intégration MTN Mobile Money pour la Côte d'Ivoire.
    
    Documentation API: https://momodeveloper.mtn.com/api-documentation/
    
    Fonctionnalités:
    - Collection (client paie via MTN)
    - Disbursement (transfert vers driver)
    - Vérification de statut
    - Webhook validation
    
    Environnements:
    - Sandbox: https://sandbox.momodeveloper.mtn.com
    - Production: https://proxy.momoapi.mtn.com
    """
    
    def __init__(self):
        """Initialise le service MTN MoMo avec les credentials"""
        self.environment = settings.MTN_MOMO_ENVIRONMENT  # 'sandbox' ou 'production'
        self.subscription_key = settings.MTN_MOMO_SUBSCRIPTION_KEY
        
        # URLs selon l'environnement
        if self.environment == 'sandbox':
            self.base_url = 'https://sandbox.momodeveloper.mtn.com'
        else:
            self.base_url = 'https://proxy.momoapi.mtn.com'
        
        # Collections API (client paie)
        self.collection_url = f'{self.base_url}/collection/v1_0'
        
        # Disbursements API (transfert driver)
        self.disbursement_url = f'{self.base_url}/disbursement/v1_0'
        
        # API User & Key (créés une seule fois)
        self.api_user = settings.MTN_MOMO_API_USER
        self.api_key = settings.MTN_MOMO_API_KEY
        
        logger.info(f"✅ MTN MoMo Service initialisé (env: {self.environment})")
    
    
    # ==========================================================================
    # AUTHENTIFICATION & TOKENS
    # ==========================================================================
    
    def _get_access_token(self, product='collection'):
        """
        Obtient un access token OAuth pour Collection ou Disbursement.
        
        Args:
            product (str): 'collection' ou 'disbursement'
        
        Returns:
            str: Access token valide
        """
        cache_key = f'mtn_momo_{product}_token'
        cached_token = cache.get(cache_key)
        
        if cached_token:
            logger.debug(f"✅ Token {product} récupéré du cache")
            return cached_token
        
        # Choisir l'URL selon le produit
        if product == 'collection':
            token_url = f'{self.collection_url}/token/'
        elif product == 'disbursement':
            token_url = f'{self.disbursement_url}/token/'
        else:
            raise ValueError(f"Produit invalide: {product}")
        
        headers = {
            'Ocp-Apim-Subscription-Key': self.subscription_key,
        }
        
        # Basic Auth avec API User et API Key
        auth = (self.api_user, self.api_key)
        
        try:
            response = requests.post(
                token_url,
                headers=headers,
                auth=auth,
                timeout=30
            )
            
            response.raise_for_status()
            data = response.json()
            
            access_token = data.get('access_token')
            expires_in = data.get('expires_in', 3600)  # Par défaut 1h
            
            # Cache le token (durée: expires_in - 5 min de sécurité)
            cache.set(cache_key, access_token, timeout=expires_in - 300)
            
            logger.info(f"✅ Token {product} obtenu (expire dans {expires_in}s)")
            return access_token
            
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Erreur obtention token {product}: {str(e)}")
            if hasattr(e.response, 'text'):
                logger.error(f"Réponse: {e.response.text}")
            raise
    
    
    # ==========================================================================
    # COLLECTION (CLIENT → LEBENI'S)
    # ==========================================================================
    
    def request_to_pay(self, amount, customer_phone, reference, currency='XOF'):
        """
        Demande de paiement au client via MTN Mobile Money.
        
        Args:
            amount (float): Montant en CFA
            customer_phone (str): Numéro du client (+2250701234567)
            reference (str): Référence unique de la transaction
            currency (str): Devise (XOF pour Côte d'Ivoire)
        
        Returns:
            dict: {
                'reference_id': 'uuid-v4',
                'status': 'PENDING',
                'customer_phone': '+2250701234567'
            }
        """
        # Générer un UUID v4 unique pour la transaction
        reference_id = str(uuid.uuid4())
        
        # Formater le numéro de téléphone
        formatted_phone = self.format_phone_number(customer_phone)
        
        # Headers
        token = self._get_access_token('collection')
        headers = {
            'Authorization': f'Bearer {token}',
            'X-Reference-Id': reference_id,
            'X-Target-Environment': self.environment,
            'Ocp-Apim-Subscription-Key': self.subscription_key,
            'Content-Type': 'application/json'
        }
        
        # Body
        payload = {
            'amount': str(amount),
            'currency': currency,
            'externalId': reference,  # Notre référence interne (DEL_...)
            'payer': {
                'partyIdType': 'MSISDN',
                'partyId': formatted_phone
            },
            'payerMessage': 'Paiement livraison LeBeni\'s',
            'payeeNote': f'Livraison {reference}'
        }
        
        try:
            url = f'{self.collection_url}/requesttopay'
            
            response = requests.post(
                url,
                headers=headers,
                json=payload,
                timeout=30
            )
            
            # MTN retourne 202 Accepted (pas 200)
            if response.status_code == 202:
                logger.info(
                    f"✅ Demande de paiement MTN créée: {reference_id} | "
                    f"{amount} CFA | {formatted_phone}"
                )
                
                return {
                    'reference_id': reference_id,
                    'status': 'PENDING',
                    'customer_phone': formatted_phone,
                    'amount': amount,
                    'external_id': reference
                }
            else:
                logger.error(f"❌ Erreur MTN request_to_pay: {response.status_code}")
                logger.error(f"Réponse: {response.text}")
                raise Exception(f"MTN API Error: {response.status_code} - {response.text}")
                
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Erreur request_to_pay MTN: {str(e)}")
            raise
    
    
    def check_payment_status(self, reference_id):
        """
        Vérifie le statut d'un paiement Collection.
        
        Args:
            reference_id (str): UUID retourné par request_to_pay
        
        Returns:
            str: 'SUCCESSFUL', 'FAILED', 'PENDING'
        """
        token = self._get_access_token('collection')
        
        headers = {
            'Authorization': f'Bearer {token}',
            'X-Target-Environment': self.environment,
            'Ocp-Apim-Subscription-Key': self.subscription_key,
        }
        
        try:
            url = f'{self.collection_url}/requesttopay/{reference_id}'
            
            response = requests.get(
                url,
                headers=headers,
                timeout=30
            )
            
            response.raise_for_status()
            data = response.json()
            
            status = data.get('status')  # SUCCESSFUL, FAILED, PENDING
            reason = data.get('reason')  # Si échec
            
            logger.info(f"✅ Statut paiement MTN {reference_id}: {status}")
            
            if reason:
                logger.warning(f"⚠️  Raison: {reason}")
            
            return status
            
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Erreur vérification statut MTN: {str(e)}")
            if hasattr(e.response, 'text'):
                logger.error(f"Réponse: {e.response.text}")
            return 'UNKNOWN'
    
    
    # ==========================================================================
    # DISBURSEMENT (LEBENI'S → DRIVER)
    # ==========================================================================
    
    def transfer_to_driver(self, amount, receiver_phone, reference, currency='XOF'):
        """
        Transfère de l'argent vers le compte MTN MoMo d'un driver.
        
        Args:
            amount (float): Montant en CFA
            receiver_phone (str): Numéro du driver (+2250701234567)
            reference (str): Référence unique (PAYOUT_...)
            currency (str): Devise (XOF)
        
        Returns:
            dict: {
                'reference_id': 'uuid-v4',
                'status': 'PENDING',
                'receiver_phone': '+2250701234567'
            }
        """
        # Générer un UUID v4 unique
        reference_id = str(uuid.uuid4())
        
        # Formater le numéro
        formatted_phone = self.format_phone_number(receiver_phone)
        
        # Headers
        token = self._get_access_token('disbursement')
        headers = {
            'Authorization': f'Bearer {token}',
            'X-Reference-Id': reference_id,
            'X-Target-Environment': self.environment,
            'Ocp-Apim-Subscription-Key': self.subscription_key,
            'Content-Type': 'application/json'
        }
        
        # Body
        payload = {
            'amount': str(amount),
            'currency': currency,
            'externalId': reference,
            'payee': {
                'partyIdType': 'MSISDN',
                'partyId': formatted_phone
            },
            'payerMessage': 'Paiement journalier LeBeni\'s',
            'payeeNote': f'Vos gains du {reference}'
        }
        
        try:
            url = f'{self.disbursement_url}/transfer'
            
            response = requests.post(
                url,
                headers=headers,
                json=payload,
                timeout=30
            )
            
            # MTN retourne 202 Accepted
            if response.status_code == 202:
                logger.info(
                    f"✅ Transfert MTN créé: {reference_id} | "
                    f"{amount} CFA → {formatted_phone}"
                )
                
                return {
                    'reference_id': reference_id,
                    'status': 'PENDING',
                    'receiver_phone': formatted_phone,
                    'amount': amount,
                    'external_id': reference
                }
            else:
                logger.error(f"❌ Erreur MTN transfer: {response.status_code}")
                logger.error(f"Réponse: {response.text}")
                raise Exception(f"MTN API Error: {response.status_code} - {response.text}")
                
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Erreur transfer MTN: {str(e)}")
            raise
    
    
    def check_transfer_status(self, reference_id):
        """
        Vérifie le statut d'un transfert Disbursement.
        
        Args:
            reference_id (str): UUID retourné par transfer_to_driver
        
        Returns:
            str: 'SUCCESSFUL', 'FAILED', 'PENDING'
        """
        token = self._get_access_token('disbursement')
        
        headers = {
            'Authorization': f'Bearer {token}',
            'X-Target-Environment': self.environment,
            'Ocp-Apim-Subscription-Key': self.subscription_key,
        }
        
        try:
            url = f'{self.disbursement_url}/transfer/{reference_id}'
            
            response = requests.get(
                url,
                headers=headers,
                timeout=30
            )
            
            response.raise_for_status()
            data = response.json()
            
            status = data.get('status')
            reason = data.get('reason')
            
            logger.info(f"✅ Statut transfert MTN {reference_id}: {status}")
            
            if reason:
                logger.warning(f"⚠️  Raison: {reason}")
            
            return status
            
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Erreur vérification transfert MTN: {str(e)}")
            if hasattr(e.response, 'text'):
                logger.error(f"Réponse: {e.response.text}")
            return 'UNKNOWN'
    
    
    # ==========================================================================
    # UTILITAIRES
    # ==========================================================================
    
    def format_phone_number(self, phone):
        """
        Formate un numéro de téléphone pour MTN MoMo (Côte d'Ivoire).
        
        Formats acceptés:
        - 0701234567 → 2250701234567
        - +2250701234567 → 2250701234567
        - 2250701234567 → 2250701234567
        
        Args:
            phone (str): Numéro à formater
        
        Returns:
            str: Numéro formaté sans le '+'
        """
        # Nettoyer
        phone = str(phone).strip().replace(' ', '').replace('-', '')
        
        # Retirer le + si présent
        if phone.startswith('+'):
            phone = phone[1:]
        
        # Ajouter 225 si manquant (Côte d'Ivoire)
        if phone.startswith('0'):
            phone = '225' + phone[1:]
        elif not phone.startswith('225'):
            phone = '225' + phone
        
        return phone
    
    
    def get_account_balance(self, product='collection'):
        """
        Récupère le solde du compte MTN MoMo.
        
        Args:
            product (str): 'collection' ou 'disbursement'
        
        Returns:
            dict: {
                'availableBalance': '1000.00',
                'currency': 'XOF'
            }
        """
        token = self._get_access_token(product)
        
        headers = {
            'Authorization': f'Bearer {token}',
            'X-Target-Environment': self.environment,
            'Ocp-Apim-Subscription-Key': self.subscription_key,
        }
        
        try:
            if product == 'collection':
                url = f'{self.collection_url}/account/balance'
            else:
                url = f'{self.disbursement_url}/account/balance'
            
            response = requests.get(
                url,
                headers=headers,
                timeout=30
            )
            
            response.raise_for_status()
            balance = response.json()
            
            logger.info(
                f"💰 Solde MTN {product}: "
                f"{balance.get('availableBalance')} {balance.get('currency')}"
            )
            
            return balance
            
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Erreur récupération solde MTN: {str(e)}")
            if hasattr(e.response, 'text'):
                logger.error(f"Réponse: {e.response.text}")
            return None
    
    
    # IPs officielles MTN MoMo API (à mettre à jour selon documentation MTN)
    MTN_ALLOWED_IPS = [
        # MTN Sandbox IPs
        '196.46.20.0/24',
        '196.216.149.0/24',
        # MTN Production IPs (Côte d'Ivoire)
        '41.202.0.0/16',
        '41.207.0.0/16',
        '154.127.60.0/24',
        # Localhost pour tests
        '127.0.0.1',
        '::1',
    ]
    
    def validate_webhook_signature(self, request_body, signature, client_ip=None):
        """
        Valide un webhook MTN MoMo via IP whitelisting.
        
        Note: MTN n'utilise pas de signature HMAC.
        La validation se fait via l'IP whitelisting et SSL mutual auth.
        
        Args:
            request_body (str): Corps de la requête
            signature (str): Signature (non utilisée pour MTN)
            client_ip (str): IP du client faisant la requête
        
        Returns:
            bool: True si valide
        """
        import ipaddress
        
        # En sandbox, accepter tout pour le dev
        if self.environment == 'sandbox':
            logger.debug("🔓 Sandbox: webhook MTN IP validation skipped")
            return True
        
        # En production, vérifier l'IP source
        if not client_ip:
            logger.warning("⚠️ Webhook MTN: IP client non fournie")
            return False
        
        try:
            client_ip_obj = ipaddress.ip_address(client_ip)
            
            for allowed in self.MTN_ALLOWED_IPS:
                try:
                    # Vérifier si c'est un réseau CIDR ou une IP unique
                    if '/' in allowed:
                        network = ipaddress.ip_network(allowed, strict=False)
                        if client_ip_obj in network:
                            logger.info(f"✅ IP webhook MTN validée: {client_ip} dans {allowed}")
                            return True
                    else:
                        if client_ip_obj == ipaddress.ip_address(allowed):
                            logger.info(f"✅ IP webhook MTN validée: {client_ip}")
                            return True
                except ValueError:
                    continue
            
            logger.warning(
                f"⚠️ IP webhook MTN non autorisée: {client_ip}. "
                f"IPs autorisées: {self.MTN_ALLOWED_IPS}"
            )
            return False
            
        except ValueError as e:
            logger.error(f"❌ IP client invalide: {client_ip} - {e}")
            return False
