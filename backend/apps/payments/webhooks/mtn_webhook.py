# apps/payments/webhooks/mtn_webhook.py

import logging
import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.utils import timezone

from apps.payments.models import Payment, TransactionHistory
from apps.payments.services.mtn_momo_service import MTNMoMoService
from apps.notifications.models import NotificationHistory

logger = logging.getLogger(__name__)


@csrf_exempt
@require_http_methods(["POST"])
def mtn_momo_webhook(request):
    """
    Webhook pour recevoir les notifications de MTN Mobile Money.
    
    MTN envoie une notification lorsque le statut d'une transaction change.
    
    POST /api/v1/payments/webhooks/mtn-momo/
    
    Body (exemple):
    {
        "referenceId": "uuid-v4",
        "externalId": "DEL_20250124_123",
        "status": "SUCCESSFUL",
        "amount": "10000",
        "currency": "XOF",
        "financialTransactionId": "MTN123456",
        "reason": null
    }
    """
    try:
        # Parser le body JSON
        try:
            data = json.loads(request.body)
        except json.JSONDecodeError:
            logger.error("❌ MTN Webhook: JSON invalide")
            return JsonResponse(
                {'error': 'Invalid JSON'},
                status=400
            )
        
        # Extraire les données
        reference_id = data.get('referenceId')
        external_id = data.get('externalId')  # Notre order_id (DEL_... ou PAYOUT_...)
        status = data.get('status')  # SUCCESSFUL, FAILED, PENDING
        amount = data.get('amount')
        currency = data.get('currency', 'XOF')
        transaction_id = data.get('financialTransactionId')
        reason = data.get('reason')
        
        logger.info(f"📥 MTN Webhook reçu: {external_id} | Status: {status}")
        
        # Validation des données
        if not reference_id or not external_id or not status:
            logger.error("❌ MTN Webhook: Données manquantes")
            return JsonResponse(
                {'error': 'Missing required fields'},
                status=400
            )
        
        # Valider la signature (en production uniquement)
        mtn_service = MTNMoMoService()
        signature = request.META.get('HTTP_X_SIGNATURE', '')
        
        if not mtn_service.validate_webhook_signature(request.body.decode('utf-8'), signature):
            logger.error("❌ MTN Webhook: Signature invalide")
            return JsonResponse(
                {'error': 'Invalid signature'},
                status=401
            )
        
        # Traiter selon le statut
        if status == 'SUCCESSFUL':
            process_successful_payment(external_id, reference_id, transaction_id, amount)
        elif status == 'FAILED':
            process_failed_payment(external_id, reference_id, reason)
        elif status == 'PENDING':
            process_pending_payment(external_id, reference_id)
        
        # Retourner 200 OK à MTN
        return JsonResponse({
            'success': True,
            'reference_id': reference_id,
            'external_id': external_id,
            'status': status
        })
        
    except Exception as e:
        logger.error(f"❌ Erreur traitement webhook MTN: {str(e)}")
        import traceback
        traceback.print_exc()
        
        # Retourner 500 pour que MTN réessaie
        return JsonResponse(
            {'error': 'Internal server error'},
            status=500
        )


def process_successful_payment(order_id, reference_id, transaction_id, amount):
    """
    Traite un paiement MTN réussi.
    
    Args:
        order_id (str): Notre identifiant (DEL_... ou PAYOUT_...)
        reference_id (str): UUID MTN
        transaction_id (str): ID transaction MTN
        amount (str): Montant
    """
    try:
        # Chercher le Payment correspondant
        payment = Payment.objects.filter(
            delivery__tracking_number__icontains=order_id.replace('DEL_', '')
        ).first()
        
        if not payment:
            logger.warning(f"⚠️  Payment introuvable pour {order_id}")
            return
        
        # Mettre à jour le statut
        payment.status = 'completed'
        payment.provider_reference = reference_id
        payment.paid_at = timezone.now()
        payment.save()
        
        logger.info(f"✅ Payment {payment.id} marqué comme completed (MTN)")
        
        # Créer l'entrée TransactionHistory
        TransactionHistory.objects.create(
            payment=payment,
            transaction_type='collection',
            amount=payment.amount,
            status='success',
            provider_reference=transaction_id
        )
        
        # Envoyer notification au driver
        NotificationHistory.create_and_send(
            user=payment.driver.user,
            notification_type='payment_received',
            title='💰 Paiement reçu (MTN)',
            body=f'Paiement de {payment.driver_amount} CFA reçu pour la livraison #{payment.delivery.tracking_number}',
            data={
                'payment_id': str(payment.id),
                'amount': str(payment.driver_amount),
                'delivery_id': str(payment.delivery.id),
                'provider': 'mtn_momo'
            },
            action='view_payment',
            action_url=f'/payments/{payment.id}'
        )
        
        logger.info(f"✅ Notification envoyée au driver {payment.driver.user.full_name}")
        
    except Exception as e:
        logger.error(f"❌ Erreur process_successful_payment: {str(e)}")


def process_failed_payment(order_id, reference_id, reason):
    """
    Traite un paiement MTN échoué.
    
    Args:
        order_id (str): Notre identifiant
        reference_id (str): UUID MTN
        reason (str): Raison de l'échec
    """
    try:
        payment = Payment.objects.filter(
            delivery__tracking_number__icontains=order_id.replace('DEL_', '')
        ).first()
        
        if not payment:
            logger.warning(f"⚠️  Payment introuvable pour {order_id}")
            return
        
        # Mettre à jour le statut
        payment.status = 'failed'
        payment.provider_reference = reference_id
        payment.save()
        
        logger.warning(f"⚠️  Payment {payment.id} échoué (MTN): {reason}")
        
        # Créer l'entrée TransactionHistory
        TransactionHistory.objects.create(
            payment=payment,
            transaction_type='collection',
            amount=payment.amount,
            status='failed',
            provider_reference=reference_id,
            error_message=reason[:500] if reason else 'Échec MTN'
        )
        
        # Envoyer notification au driver
        NotificationHistory.create_and_send(
            user=payment.driver.user,
            notification_type='payment_failed',
            title='❌ Paiement échoué (MTN)',
            body=f'Le paiement pour la livraison #{payment.delivery.tracking_number} a échoué.',
            data={
                'payment_id': str(payment.id),
                'delivery_id': str(payment.delivery.id),
                'reason': reason,
                'provider': 'mtn_momo'
            }
        )
        
    except Exception as e:
        logger.error(f"❌ Erreur process_failed_payment: {str(e)}")


def process_pending_payment(order_id, reference_id):
    """
    Traite un paiement MTN en attente.
    
    Args:
        order_id (str): Notre identifiant
        reference_id (str): UUID MTN
    """
    try:
        payment = Payment.objects.filter(
            delivery__tracking_number__icontains=order_id.replace('DEL_', '')
        ).first()
        
        if not payment:
            logger.warning(f"⚠️  Payment introuvable pour {order_id}")
            return
        
        # Mettre à jour le statut
        payment.status = 'processing'
        payment.provider_reference = reference_id
        payment.save()
        
        logger.info(f"⏳ Payment {payment.id} en traitement (MTN)")
        
        # Créer l'entrée TransactionHistory
        TransactionHistory.objects.create(
            payment=payment,
            transaction_type='collection',
            amount=payment.amount,
            status='pending',
            provider_reference=reference_id
        )
        
    except Exception as e:
        logger.error(f"❌ Erreur process_pending_payment: {str(e)}")
