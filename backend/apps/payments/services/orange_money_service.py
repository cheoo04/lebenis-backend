# apps/payments/services/orange_money_service.py

import requests
import logging
import base64
from decimal import Decimal
from typing import Dict, Optional, Tuple
from django.conf import settings
from django.utils import timezone
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)


class OrangeMoneyService:
    """
    Service pour gérer les paiements Orange Money (Côte d'Ivoire).
    Supporte Collection (client paie) et Disbursement (versement livreur).
    
    Documentation: https://developer.orange.com/apis/orange-money-webpay/
    """
    
    def __init__(self):
        # Configuration depuis settings
        self.client_id = getattr(settings, 'ORANGE_MONEY_CLIENT_ID', '')
        self.client_secret = getattr(settings, 'ORANGE_MONEY_CLIENT_SECRET', '')
        self.merchant_key = getattr(settings, 'ORANGE_MONEY_MERCHANT_KEY', '')
        self.base_url = getattr(settings, 'ORANGE_MONEY_BASE_URL', 
                                'https://api.orange.com/orange-money-webpay/ci/v1')
        self.environment = getattr(settings, 'ORANGE_MONEY_ENVIRONMENT', 'sandbox')
        
        # Cache du token
        self._access_token = None
        self._token_expires_at = None
    
    def _get_access_token(self) -> Optional[str]:
        """
        Obtient un access token OAuth2.
        Cache le token jusqu'à expiration.
        
        Returns:
            str: Access token ou None si erreur
        """
        # Vérifier si on a un token valide en cache
        if self._access_token and self._token_expires_at:
            if timezone.now() < self._token_expires_at:
                return self._access_token
        
        try:
            # Encoder credentials en Base64
            credentials = f"{self.client_id}:{self.client_secret}"
            encoded_credentials = base64.b64encode(credentials.encode()).decode()
            
            # Requête OAuth
            url = "https://api.orange.com/oauth/v3/token"
            headers = {
                'Authorization': f'Basic {encoded_credentials}',
                'Content-Type': 'application/x-www-form-urlencoded'
            }
            data = {
                'grant_type': 'client_credentials'
            }
            
            response = requests.post(url, headers=headers, data=data, timeout=30)
            response.raise_for_status()
            
            result = response.json()
            self._access_token = result.get('access_token')
            expires_in = result.get('expires_in', 3600)  # Défaut 1h
            
            # Calculer expiration (avec marge de 5 minutes)
            self._token_expires_at = timezone.now() + timedelta(seconds=expires_in - 300)
            
            logger.info("✅ Orange Money access token obtenu")
            return self._access_token
            
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Erreur OAuth Orange Money: {str(e)}")
            return None
    
    def initiate_payment(
        self,
        order_id: str,
        amount: Decimal,
        customer_phone: str,
        reference: str,
        return_url: str = '',
        cancel_url: str = '',
        notif_url: str = ''
    ) -> Tuple[bool, Dict]:
        """
        Initie un paiement Orange Money (Collection).
        Le client recevra un prompt USSD sur son téléphone.
        
        Args:
            order_id: ID unique de la commande (delivery tracking number)
            amount: Montant en FCFA
            customer_phone: Numéro Orange Money client (+225...)
            reference: Description du paiement
            return_url: URL de retour après succès
            cancel_url: URL si annulation
            notif_url: URL webhook pour notification
        
        Returns:
            Tuple[bool, Dict]: (success, response_data)
        """
        access_token = self._get_access_token()
        if not access_token:
            return False, {'error': 'Impossible d\'obtenir le token OAuth'}
        
        try:
            url = f"{self.base_url}/webpayment"
            headers = {
                'Authorization': f'Bearer {access_token}',
                'Content-Type': 'application/json'
            }
            
            # Payload
            payload = {
                'merchant_key': self.merchant_key,
                'currency': 'OUV',  # XOF (FCFA) en Orange Money
                'order_id': order_id,
                'amount': int(amount),  # Orange Money attend un entier
                'return_url': return_url or f"{settings.FRONTEND_URL}/payment/success",
                'cancel_url': cancel_url or f"{settings.FRONTEND_URL}/payment/cancel",
                'notif_url': notif_url or f"{settings.BACKEND_URL}/api/v1/webhooks/orange-money/",
                'lang': 'fr',
                'reference': reference
            }
            
            response = requests.post(url, headers=headers, json=payload, timeout=30)
            response.raise_for_status()
            
            result = response.json()
            
            logger.info(f"✅ Paiement Orange Money initié: {order_id}")
            return True, {
                'payment_url': result.get('payment_url'),
                'pay_token': result.get('pay_token'),
                'notif_token': result.get('notif_token'),
                'order_id': order_id
            }
            
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Erreur initiation paiement Orange Money: {str(e)}")
            error_msg = str(e)
            
            # Parser les erreurs Orange Money
            if hasattr(e, 'response') and e.response is not None:
                try:
                    error_data = e.response.json()
                    error_msg = error_data.get('error_description', error_msg)
                except:
                    pass
            
            return False, {'error': error_msg}
    
    def check_payment_status(self, order_id: str) -> Tuple[bool, Dict]:
        """
        Vérifie le statut d'un paiement.
        
        Args:
            order_id: ID de la commande
        
        Returns:
            Tuple[bool, Dict]: (success, status_data)
        """
        access_token = self._get_access_token()
        if not access_token:
            return False, {'error': 'Impossible d\'obtenir le token OAuth'}
        
        try:
            url = f"{self.base_url}/transactionstatus/{order_id}"
            headers = {
                'Authorization': f'Bearer {access_token}'
            }
            
            response = requests.get(url, headers=headers, timeout=30)
            response.raise_for_status()
            
            result = response.json()
            
            status = result.get('status', 'UNKNOWN')
            
            return True, {
                'status': status,  # SUCCESS, PENDING, FAILED, EXPIRED
                'txnid': result.get('txnid'),
                'order_id': order_id,
                'amount': result.get('amount'),
                'currency': result.get('currency')
            }
            
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Erreur vérification statut: {str(e)}")
            return False, {'error': str(e)}
    
    def transfer_to_driver(
        self,
        order_id: str,
        amount: Decimal,
        receiver_phone: str,
        reference: str
    ) -> Tuple[bool, Dict]:
        """
        Effectue un transfert vers un livreur (Disbursement/Payout).
        
        Args:
            order_id: ID unique du versement
            amount: Montant à verser en FCFA
            receiver_phone: Numéro Orange Money du livreur
            reference: Description du transfert
        
        Returns:
            Tuple[bool, Dict]: (success, response_data)
        """
        access_token = self._get_access_token()
        if not access_token:
            return False, {'error': 'Impossible d\'obtenir le token OAuth'}
        
        try:
            url = f"{self.base_url}/cashout"
            headers = {
                'Authorization': f'Bearer {access_token}',
                'Content-Type': 'application/json'
            }
            
            payload = {
                'merchant_key': self.merchant_key,
                'currency': 'OUV',
                'order_id': order_id,
                'amount': int(amount),
                'receiver_phone': receiver_phone,  # Format: +2250701234567
                'reference': reference
            }
            
            response = requests.post(url, headers=headers, json=payload, timeout=30)
            response.raise_for_status()
            
            result = response.json()
            
            logger.info(f"✅ Transfert Orange Money réussi: {order_id} → {receiver_phone}")
            return True, {
                'txnid': result.get('txnid'),
                'order_id': order_id,
                'status': result.get('status'),
                'amount': amount
            }
            
        except requests.exceptions.RequestException as e:
            logger.error(f"❌ Erreur transfert Orange Money: {str(e)}")
            error_msg = str(e)
            
            if hasattr(e, 'response') and e.response is not None:
                try:
                    error_data = e.response.json()
                    error_msg = error_data.get('error_description', error_msg)
                except:
                    pass
            
            return False, {'error': error_msg}
    
    def validate_webhook_signature(self, payload: Dict, signature: str) -> bool:
        """
        Valide la signature d'un webhook Orange Money.
        
        Args:
            payload: Données du webhook
            signature: Signature reçue dans les headers
        
        Returns:
            bool: True si signature valide
        """
        # TODO: Implémenter validation signature selon doc Orange Money
        # Pour l'instant, on accepte tous les webhooks en sandbox
        if self.environment == 'sandbox':
            return True
        
        # En production, valider la signature
        return True
    
    @staticmethod
    def format_phone_number(phone: str) -> str:
        """
        Formate un numéro de téléphone pour Orange Money CI.
        
        Args:
            phone: Numéro (ex: 0701234567, +2250701234567)
        
        Returns:
            str: Numéro formaté (+2250701234567)
        """
        # Retirer espaces et tirets
        phone = phone.replace(' ', '').replace('-', '')
        
        # Ajouter +225 si manquant
        if phone.startswith('0'):
            phone = '+225' + phone[1:]
        elif not phone.startswith('+'):
            phone = '+225' + phone
        
        return phone


# Instance globale
orange_money_service = OrangeMoneyService()
