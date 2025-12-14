# apps/payments/wave_service.py
"""
Service d'intégration Wave Money pour LeBeni's

Wave API Documentation: https://docs.wave.com/
Environnements:
- Sandbox: https://api.sandbox.wave.com
- Production: https://api.wave.com
"""

import logging
import requests
import hmac
import hashlib
import json
from decimal import Decimal
from typing import Optional, Dict, Any, List
from django.conf import settings
from django.utils import timezone

logger = logging.getLogger(__name__)


class WavePaymentError(Exception):
    """Exception pour les erreurs Wave"""
    def __init__(self, message: str, code: str = None, details: dict = None):
        self.message = message
        self.code = code
        self.details = details or {}
        super().__init__(self.message)


class WaveService:
    """
    Service pour les paiements Wave Money.
    
    Fonctionnalités:
    - Encaissement (checkout) : Client paie via Wave
    - Paiement de masse (payout) : Payer les drivers
    - Vérification de solde
    - Webhooks
    """
    
    # URLs de l'API Wave
    SANDBOX_URL = "https://api.sandbox.wave.com/v1"
    PRODUCTION_URL = "https://api.wave.com/v1"
    
    def __init__(self):
        self.api_key = getattr(settings, 'WAVE_API_KEY', None)
        self.api_secret = getattr(settings, 'WAVE_API_SECRET', None)
        self.webhook_secret = getattr(settings, 'WAVE_WEBHOOK_SECRET', None)
        self.is_sandbox = getattr(settings, 'WAVE_SANDBOX', True)
        self.merchant_id = getattr(settings, 'WAVE_MERCHANT_ID', None)
        
        self.base_url = self.SANDBOX_URL if self.is_sandbox else self.PRODUCTION_URL
        
        if not self.api_key:
            logger.warning("⚠️ WAVE_API_KEY non configurée")
    
    def _get_headers(self) -> Dict[str, str]:
        """Headers pour les requêtes API Wave"""
        return {
            'Authorization': f'Bearer {self.api_key}',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
        }
    
    def _make_request(
        self, 
        method: str, 
        endpoint: str, 
        data: dict = None,
        timeout: int = 30
    ) -> Dict[str, Any]:
        """
        Effectue une requête à l'API Wave.
        
        Args:
            method: GET, POST, PUT, DELETE
            endpoint: Endpoint de l'API (ex: /checkout/sessions)
            data: Données à envoyer
            timeout: Timeout en secondes
            
        Returns:
            Réponse JSON de l'API
            
        Raises:
            WavePaymentError: Si la requête échoue
        """
        url = f"{self.base_url}{endpoint}"
        
        try:
            logger.info(f"Wave API: {method} {endpoint}")
            
            response = requests.request(
                method=method,
                url=url,
                headers=self._get_headers(),
                json=data,
                timeout=timeout
            )
            
            # Log la réponse
            logger.debug(f"Wave response: {response.status_code} - {response.text[:500]}")
            
            # Gérer les erreurs HTTP
            if response.status_code >= 400:
                error_data = response.json() if response.text else {}
                raise WavePaymentError(
                    message=error_data.get('message', f'Erreur HTTP {response.status_code}'),
                    code=error_data.get('code', str(response.status_code)),
                    details=error_data
                )
            
            return response.json() if response.text else {}
            
        except requests.exceptions.Timeout:
            raise WavePaymentError("Timeout lors de la connexion à Wave", code="TIMEOUT")
        except requests.exceptions.ConnectionError:
            raise WavePaymentError("Impossible de se connecter à Wave", code="CONNECTION_ERROR")
        except json.JSONDecodeError:
            raise WavePaymentError("Réponse invalide de Wave", code="INVALID_RESPONSE")
    
    # =========================================================================
    # ENCAISSEMENT (CHECKOUT) - Client paie via Wave
    # =========================================================================
    
    def create_checkout_session(
        self,
        amount: Decimal,
        currency: str = "XOF",
        client_reference: str = None,
        success_url: str = None,
        error_url: str = None,
        customer_phone: str = None,
        customer_name: str = None,
    ) -> Dict[str, Any]:
        """
        Crée une session de paiement Wave (checkout).
        Le client sera redirigé vers Wave pour payer.
        
        Args:
            amount: Montant en CFA (XOF)
            currency: Devise (XOF par défaut)
            client_reference: Référence unique (ex: tracking_number)
            success_url: URL de redirection après paiement réussi
            error_url: URL de redirection après échec
            customer_phone: Numéro de téléphone du client (format: +225XXXXXXXXXX)
            customer_name: Nom du client
            
        Returns:
            {
                'id': 'session_xxxx',
                'checkout_url': 'https://pay.wave.com/...',
                'status': 'pending',
                'amount': 2000,
                'currency': 'XOF',
                ...
            }
        """
        data = {
            'amount': str(int(amount)),  # Wave attend un entier
            'currency': currency,
        }
        
        if client_reference:
            data['client_reference'] = client_reference
        if success_url:
            data['success_url'] = success_url
        if error_url:
            data['error_url'] = error_url
        
        # Informations client optionnelles
        if customer_phone or customer_name:
            data['customer'] = {}
            if customer_phone:
                data['customer']['mobile'] = customer_phone
            if customer_name:
                data['customer']['name'] = customer_name
        
        result = self._make_request('POST', '/checkout/sessions', data)
        
        logger.info(f"✅ Session checkout créée: {result.get('id')} - {amount} {currency}")
        
        return result
    
    def get_checkout_session(self, session_id: str) -> Dict[str, Any]:
        """
        Récupère les détails d'une session de checkout.
        
        Args:
            session_id: ID de la session Wave
            
        Returns:
            Détails de la session incluant le statut
        """
        return self._make_request('GET', f'/checkout/sessions/{session_id}')
    
    # =========================================================================
    # PAIEMENT DE MASSE (PAYOUT) - Payer les drivers
    # =========================================================================
    
    def create_payout(
        self,
        recipient_phone: str,
        amount: Decimal,
        currency: str = "XOF",
        client_reference: str = None,
        name: str = None,
    ) -> Dict[str, Any]:
        """
        Effectue un paiement vers un compte Wave (payout).
        Utilisé pour payer les drivers.
        
        Args:
            recipient_phone: Numéro Wave du destinataire (+225XXXXXXXXXX)
            amount: Montant à envoyer en CFA
            currency: Devise (XOF)
            client_reference: Référence unique (ex: driver_payment_id)
            name: Nom du destinataire
            
        Returns:
            {
                'id': 'payout_xxxx',
                'status': 'succeeded' | 'pending' | 'failed',
                'amount': 1500,
                'recipient': {...},
                ...
            }
        """
        data = {
            'recipient_mobile': recipient_phone,
            'amount': str(int(amount)),
            'currency': currency,
        }
        
        if client_reference:
            data['client_reference'] = client_reference
        if name:
            data['name'] = name
        
        result = self._make_request('POST', '/payouts', data)
        
        logger.info(f"✅ Payout créé: {result.get('id')} - {amount} {currency} vers {recipient_phone}")
        
        return result
    
    def create_bulk_payout(
        self,
        payouts: List[Dict[str, Any]],
        batch_name: str = None,
    ) -> Dict[str, Any]:
        """
        Effectue des paiements de masse vers plusieurs comptes Wave.
        Idéal pour payer tous les drivers d'un coup.
        
        Args:
            payouts: Liste de paiements, chaque élément contient:
                - recipient_phone: str
                - amount: Decimal
                - client_reference: str (optionnel)
                - name: str (optionnel)
            batch_name: Nom du lot (ex: "Paiements drivers 2025-12-12")
            
        Returns:
            {
                'id': 'batch_xxxx',
                'status': 'processing',
                'payouts': [...],
                'total_amount': 50000,
                ...
            }
        """
        payout_items = []
        
        for payout in payouts:
            item = {
                'recipient_mobile': payout['recipient_phone'],
                'amount': str(int(payout['amount'])),
                'currency': payout.get('currency', 'XOF'),
            }
            if payout.get('client_reference'):
                item['client_reference'] = payout['client_reference']
            if payout.get('name'):
                item['name'] = payout['name']
            payout_items.append(item)
        
        data = {
            'payouts': payout_items,
        }
        
        if batch_name:
            data['name'] = batch_name
        
        result = self._make_request('POST', '/payouts/bulk', data)
        
        total = sum(int(p['amount']) for p in payout_items)
        logger.info(f"✅ Batch payout créé: {result.get('id')} - {len(payout_items)} paiements - {total} CFA")
        
        return result
    
    def get_payout(self, payout_id: str) -> Dict[str, Any]:
        """Récupère les détails d'un payout"""
        return self._make_request('GET', f'/payouts/{payout_id}')
    
    # =========================================================================
    # SOLDE ET COMPTE
    # =========================================================================
    
    def get_balance(self) -> Dict[str, Any]:
        """
        Récupère le solde du compte Wave Business.
        
        Returns:
            {
                'available': 500000,
                'pending': 10000,
                'currency': 'XOF'
            }
        """
        return self._make_request('GET', '/balance')
    
    # =========================================================================
    # WEBHOOKS
    # =========================================================================
    
    def verify_webhook_signature(self, payload: bytes, signature: str) -> bool:
        """
        Vérifie la signature d'un webhook Wave.
        
        Args:
            payload: Corps de la requête en bytes
            signature: Header 'Wave-Signature'
            
        Returns:
            True si la signature est valide
        """
        if not self.webhook_secret:
            logger.warning("⚠️ WAVE_WEBHOOK_SECRET non configuré, signature non vérifiée")
            return True  # Accepter en dev
        
        expected_signature = hmac.new(
            self.webhook_secret.encode(),
            payload,
            hashlib.sha256
        ).hexdigest()
        
        return hmac.compare_digest(expected_signature, signature)
    
    def parse_webhook_event(self, payload: dict) -> Dict[str, Any]:
        """
        Parse un événement webhook Wave.
        
        Types d'événements:
        - checkout.session.completed : Paiement client réussi
        - checkout.session.expired : Session expirée
        - payout.succeeded : Payout réussi
        - payout.failed : Payout échoué
        
        Args:
            payload: Corps JSON du webhook
            
        Returns:
            Événement parsé avec type et données
        """
        event_type = payload.get('type', payload.get('event'))
        data = payload.get('data', payload)
        
        return {
            'type': event_type,
            'data': data,
            'id': payload.get('id'),
            'created_at': payload.get('created_at'),
        }


# Instance singleton pour usage facile
wave_service = WaveService()
