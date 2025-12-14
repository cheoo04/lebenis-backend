# apps/payments/wave_views.py
"""
Vues pour l'intégration Wave Money.

Endpoints:
- POST /api/v1/payments/wave/checkout/ : Créer une session de paiement
- GET /api/v1/payments/wave/checkout/{session_id}/ : Vérifier le statut
- POST /api/v1/payments/wave/webhook/ : Recevoir les notifications Wave
"""

import logging
import json
from decimal import Decimal

from django.conf import settings
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator

from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny

from apps.deliveries.models import Delivery
from .models import DriverPayment
from .wave_service import wave_service, WavePaymentError

logger = logging.getLogger(__name__)


class WaveCheckoutView(APIView):
    """
    Créer une session de paiement Wave pour une livraison.
    
    POST /api/v1/payments/wave/checkout/
    {
        "delivery_id": "uuid",
        "success_url": "https://...",  // optionnel
        "error_url": "https://..."     // optionnel
    }
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        delivery_id = request.data.get('delivery_id')
        
        if not delivery_id:
            return Response(
                {'error': 'delivery_id est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            # Récupérer la livraison
            delivery = Delivery.objects.get(id=delivery_id)
            
            # Vérifier que l'utilisateur est le propriétaire
            is_owner = False
            if delivery.merchant and hasattr(request.user, 'merchant_profile'):
                if delivery.merchant.id == request.user.merchant_profile.id:
                    is_owner = True
            if delivery.created_by and delivery.created_by.id == request.user.id:
                is_owner = True
            
            if not is_owner:
                return Response(
                    {'error': 'Vous ne pouvez payer que vos propres livraisons'},
                    status=status.HTTP_403_FORBIDDEN
                )
            
            # Vérifier que la livraison n'est pas déjà payée
            if delivery.payment_status == 'paid':
                return Response(
                    {'error': 'Cette livraison est déjà payée'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # URLs de callback
            base_url = getattr(settings, 'FRONTEND_URL', 'https://lebenis.com')
            success_url = request.data.get('success_url') or f"{base_url}/payment/success?delivery={delivery_id}"
            error_url = request.data.get('error_url') or f"{base_url}/payment/error?delivery={delivery_id}"
            
            # Informations client
            customer_phone = None
            customer_name = None
            
            if hasattr(request.user, 'phone_number'):
                customer_phone = request.user.phone_number
            customer_name = request.user.full_name or request.user.email
            
            # Créer la session Wave
            session = wave_service.create_checkout_session(
                amount=Decimal(str(delivery.calculated_price)),
                currency='XOF',
                client_reference=delivery.tracking_number,
                success_url=success_url,
                error_url=error_url,
                customer_phone=customer_phone,
                customer_name=customer_name,
            )
            
            # Sauvegarder l'ID de session dans la livraison (optionnel)
            # On pourrait ajouter un champ wave_session_id au modèle
            
            logger.info(f"✅ Session Wave créée pour livraison {delivery.tracking_number}: {session.get('id')}")
            
            return Response({
                'success': True,
                'session_id': session.get('id'),
                'checkout_url': session.get('checkout_url') or session.get('wave_launch_url'),
                'amount': float(delivery.calculated_price),
                'currency': 'XOF',
                'delivery': {
                    'id': str(delivery.id),
                    'tracking_number': delivery.tracking_number,
                }
            })
            
        except Delivery.DoesNotExist:
            return Response(
                {'error': 'Livraison introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        except WavePaymentError as e:
            logger.error(f"❌ Erreur Wave: {e.message}", extra={'code': e.code, 'details': e.details})
            return Response(
                {'error': f'Erreur Wave: {e.message}', 'code': e.code},
                status=status.HTTP_502_BAD_GATEWAY
            )
        except Exception as e:
            logger.exception(f"❌ Erreur inattendue lors de la création du checkout Wave")
            return Response(
                {'error': 'Erreur lors de la création du paiement'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class WaveCheckoutStatusView(APIView):
    """
    Vérifier le statut d'une session de paiement Wave.
    
    GET /api/v1/payments/wave/checkout/{session_id}/
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request, session_id):
        try:
            session = wave_service.get_checkout_session(session_id)
            
            return Response({
                'session_id': session.get('id'),
                'status': session.get('status'),
                'amount': session.get('amount'),
                'currency': session.get('currency'),
                'client_reference': session.get('client_reference'),
                'paid_at': session.get('paid_at'),
            })
            
        except WavePaymentError as e:
            return Response(
                {'error': e.message, 'code': e.code},
                status=status.HTTP_400_BAD_REQUEST
            )


@method_decorator(csrf_exempt, name='dispatch')
class WaveWebhookView(APIView):
    """
    Endpoint pour recevoir les webhooks Wave.
    
    POST /api/v1/payments/wave/webhook/
    
    Wave envoie des notifications pour:
    - checkout.session.completed : Paiement client réussi
    - checkout.session.expired : Session expirée
    - payout.succeeded : Paiement driver réussi
    - payout.failed : Paiement driver échoué
    """
    permission_classes = [AllowAny]  # Pas d'auth, mais signature vérifiée
    
    def post(self, request):
        # Vérifier la signature
        signature = request.headers.get('Wave-Signature', '')
        
        if not wave_service.verify_webhook_signature(request.body, signature):
            logger.warning("⚠️ Signature webhook Wave invalide")
            return HttpResponse(status=401)
        
        try:
            payload = json.loads(request.body)
            event = wave_service.parse_webhook_event(payload)
            
            event_type = event['type']
            data = event['data']
            
            logger.info(f"📩 Webhook Wave reçu: {event_type}")
            
            # Traiter selon le type d'événement
            if event_type == 'checkout.session.completed':
                self._handle_checkout_completed(data)
            elif event_type == 'checkout.session.expired':
                self._handle_checkout_expired(data)
            elif event_type == 'payout.succeeded':
                self._handle_payout_succeeded(data)
            elif event_type == 'payout.failed':
                self._handle_payout_failed(data)
            else:
                logger.info(f"Type d'événement Wave non géré: {event_type}")
            
            return HttpResponse(status=200)
            
        except json.JSONDecodeError:
            logger.error("❌ Payload webhook Wave invalide")
            return HttpResponse(status=400)
        except Exception as e:
            logger.exception(f"❌ Erreur traitement webhook Wave: {e}")
            # Retourner 200 pour éviter que Wave ne renvoie
            return HttpResponse(status=200)
    
    def _handle_checkout_completed(self, data):
        """Traite un paiement client réussi"""
        client_reference = data.get('client_reference')  # tracking_number
        
        if not client_reference:
            logger.warning("Checkout completed sans client_reference")
            return
        
        try:
            # Trouver la livraison par tracking_number
            delivery = Delivery.objects.get(tracking_number=client_reference)
            
            # Mettre à jour le statut de paiement
            delivery.payment_status = 'paid'
            delivery.save(update_fields=['payment_status', 'updated_at'])
            
            logger.info(f"✅ Paiement confirmé pour livraison {client_reference}")
            
            # TODO: Envoyer notification push au client
            # TODO: Envoyer notification push au driver si assigné
            
        except Delivery.DoesNotExist:
            logger.warning(f"Livraison introuvable pour tracking: {client_reference}")
    
    def _handle_checkout_expired(self, data):
        """Traite une session de paiement expirée"""
        client_reference = data.get('client_reference')
        logger.info(f"⏰ Session de paiement expirée: {client_reference}")
        # Optionnel: envoyer une notification au client
    
    def _handle_payout_succeeded(self, data):
        """Traite un paiement driver réussi"""
        client_reference = data.get('client_reference')  # driver_payment_id
        
        if not client_reference:
            logger.warning("Payout succeeded sans client_reference")
            return
        
        try:
            # Trouver le DriverPayment
            payment = DriverPayment.objects.get(id=client_reference)
            
            payment.status = 'paid'
            payment.payment_reference = data.get('id', '')
            payment.paid_at = data.get('created_at')
            payment.save()
            
            logger.info(f"✅ Paiement driver confirmé: {client_reference}")
            
            # TODO: Envoyer notification push au driver
            
        except DriverPayment.DoesNotExist:
            logger.warning(f"DriverPayment introuvable: {client_reference}")
    
    def _handle_payout_failed(self, data):
        """Traite un paiement driver échoué"""
        client_reference = data.get('client_reference')
        error_message = data.get('error', {}).get('message', 'Erreur inconnue')
        
        if not client_reference:
            return
        
        try:
            payment = DriverPayment.objects.get(id=client_reference)
            
            payment.status = 'failed'
            payment.notes = f"Échec Wave: {error_message}"
            payment.save()
            
            logger.error(f"❌ Paiement driver échoué: {client_reference} - {error_message}")
            
            # TODO: Alerter l'admin
            # TODO: Réessayer automatiquement ?
            
        except DriverPayment.DoesNotExist:
            pass


class WaveBalanceView(APIView):
    """
    Vérifier le solde du compte Wave Business (admin only).
    
    GET /api/v1/payments/wave/balance/
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        # Vérifier que c'est un admin
        if not request.user.is_staff:
            return Response(
                {'error': 'Accès réservé aux administrateurs'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        try:
            balance = wave_service.get_balance()
            
            return Response({
                'available': balance.get('available'),
                'pending': balance.get('pending'),
                'currency': balance.get('currency', 'XOF'),
            })
            
        except WavePaymentError as e:
            return Response(
                {'error': e.message},
                status=status.HTTP_502_BAD_GATEWAY
            )
