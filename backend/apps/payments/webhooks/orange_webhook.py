# apps/payments/webhooks/orange_webhook.py

import logging
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from django.views.decorators.csrf import csrf_exempt
from django.utils import timezone
from apps.payments.models import Payment, TransactionHistory
from apps.payments.services.orange_money_service import OrangeMoneyService
from apps.notifications.models import NotificationHistory

logger = logging.getLogger(__name__)


@csrf_exempt
@api_view(['POST'])
@permission_classes([AllowAny])  # Webhook public (validation signature)
def orange_money_webhook(request):
    """
    Webhook pour recevoir les notifications de paiement Orange Money.
    
    POST /api/v1/webhooks/orange-money/
    
    Orange Money envoie:
    {
        "order_id": "LB-20250119-ABCD",
        "amount": 2000,
        "txnid": "MP200119.1234.A12345",
        "status": "SUCCESS",  // ou FAILED, PENDING
        "currency": "OUV",
        "notif_token": "xyz789"
    }
    """
    try:
        # Logger la réception du webhook
        logger.info(f"📩 Webhook Orange Money reçu: {request.data}")
        
        # Extraire les données
        order_id = request.data.get('order_id')
        txnid = request.data.get('txnid')
        payment_status = request.data.get('status')
        amount = request.data.get('amount')
        currency = request.data.get('currency')
        notif_token = request.data.get('notif_token')
        
        # Validation des données obligatoires
        if not all([order_id, payment_status]):
            logger.error("❌ Webhook invalide: order_id ou status manquant")
            return Response(
                {'error': 'order_id et status requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Instancier le service Orange Money
        orange_money_service = OrangeMoneyService()
        
        # Valider la signature (optionnel en sandbox)
        signature = request.headers.get('X-Orange-Signature', '')
        is_valid = orange_money_service.validate_webhook_signature(
            request.data, 
            signature
        )
        
        if not is_valid and orange_money_service.environment == 'production':
            logger.error("❌ Webhook signature invalide")
            return Response(
                {'error': 'Signature invalide'},
                status=status.HTTP_401_UNAUTHORIZED
            )
        
        # Récupérer le paiement
        try:
            payment = Payment.objects.get(reference=order_id)
        except Payment.DoesNotExist:
            logger.error(f"❌ Paiement introuvable: {order_id}")
            return Response(
                {'error': 'Paiement introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Mettre à jour le statut du paiement
        old_status = payment.status
        
        if payment_status == 'SUCCESS':
            payment.status = 'completed'
            payment.transaction_id = txnid
            payment.completed_at = timezone.now()
            
            # Créer l'entrée dans l'historique des transactions
            TransactionHistory.objects.create(
                transaction_type='collection',
                amount=payment.total_amount,
                currency='XOF',
                driver=payment.driver,
                payment=payment,
                external_reference=txnid,
                provider='orange_money',
                status='completed',
                metadata=request.data,
                completed_at=timezone.now()
            )
            
            logger.info(f"✅ Paiement complété: {order_id} - {txnid}")
            
        elif payment_status == 'FAILED':
            payment.status = 'failed'
            payment.failed_at = timezone.now()
            payment.error_message = request.data.get('error_message', 'Paiement échoué')
            
            # Transaction échouée
            TransactionHistory.objects.create(
                transaction_type='collection',
                amount=payment.total_amount,
                currency='XOF',
                driver=payment.driver,
                payment=payment,
                external_reference=txnid,
                provider='orange_money',
                status='failed',
                error_message=payment.error_message,
                metadata=request.data
            )
            
            logger.warning(f"⚠️ Paiement échoué: {order_id}")
            
        elif payment_status == 'PENDING':
            payment.status = 'processing'
            
            logger.info(f"⏳ Paiement en cours: {order_id}")
        
        # Sauvegarder les changements
        payment.metadata = {
            **payment.metadata,
            'webhook_received_at': timezone.now().isoformat(),
            'webhook_data': request.data
        }
        payment.save()
        
        # Envoyer une notification au driver si complété
        if payment.status == 'completed':
            NotificationHistory.create_and_send(
                user=payment.driver.user,
                notification_type='payment_received',
                title='💰 Paiement reçu',
                body=f'Paiement de {payment.total_amount} FCFA reçu pour la livraison #{payment.delivery.tracking_number}',
                data={
                    'payment_id': str(payment.id),
                    'delivery_id': str(payment.delivery.id),
                    'amount': str(payment.total_amount)
                },
                action='open_payment_details'
            )
        
        # Répondre à Orange Money
        return Response({
            'status': 'OK',
            'order_id': order_id,
            'updated_status': payment.status
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"❌ Erreur traitement webhook: {str(e)}")
        return Response(
            {'error': 'Erreur serveur'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
