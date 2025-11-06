# apps/payments/tasks.py

import logging
from decimal import Decimal
from datetime import datetime, timedelta
from django.utils import timezone
from django.db.models import Sum
from celery import shared_task

from .models import Payment, DailyPayout, TransactionHistory
from .services.orange_money_service import OrangeMoneyService
from apps.drivers.models import Driver
from apps.notifications.models import NotificationHistory

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3)
def process_daily_payouts(self):
    """
    Tâche Celery exécutée chaque jour à 23h59.
    
    Pour chaque driver ayant des paiements completed du jour :
    1. Créer un DailyPayout groupé
    2. Transférer l'argent via Orange Money
    3. Mettre à jour les statuts
    4. Envoyer notification au driver
    """
    logger.info("🚀 Démarrage du traitement des paiements quotidiens (23h59)")
    
    today = timezone.now().date()
    start_of_day = timezone.make_aware(datetime.combine(today, datetime.min.time()))
    end_of_day = timezone.now()
    
    # Récupérer tous les drivers avec paiements completed aujourd'hui
    drivers_with_payments = Driver.objects.filter(
        payments__status='completed',
        payments__created_at__gte=start_of_day,
        payments__created_at__lte=end_of_day
    ).distinct()
    
    total_payouts_created = 0
    total_amount_transferred = Decimal('0')
    failed_payouts = []
    
    for driver in drivers_with_payments:
        try:
            # Récupérer les paiements completed du jour pour ce driver
            today_payments = Payment.objects.filter(
                driver=driver,
                status='completed',
                created_at__gte=start_of_day,
                created_at__lte=end_of_day,
                daily_payout__isnull=True  # Pas encore dans un payout
            )
            
            if not today_payments.exists():
                logger.info(f"⏭️  Aucun paiement à traiter pour {driver.user.full_name}")
                continue
            
            # Calculer le total à payer au driver
            total_driver_amount = today_payments.aggregate(
                Sum('driver_amount')
            )['driver_amount__sum'] or Decimal('0')
            
            if total_driver_amount <= 0:
                logger.warning(f"⚠️  Montant nul pour {driver.user.full_name}")
                continue
            
            # Créer le DailyPayout
            payout = DailyPayout.objects.create(
                driver=driver,
                payout_date=today,
                total_amount=total_driver_amount,
                payment_method='orange_money',  # Par défaut Orange Money
                phone_number=driver.phone_number,
                status='pending'
            )
            
            # Associer les paiements au payout
            today_payments.update(daily_payout=payout)
            
            logger.info(
                f"💰 Payout créé pour {driver.user.full_name}: "
                f"{total_driver_amount} CFA ({today_payments.count()} paiements)"
            )
            
            # Tenter le transfert via Orange Money
            try:
                orange_service = OrangeMoneyService()
                
                # Générer order_id unique pour le transfert
                order_id = f"PAYOUT_{today.strftime('%Y%m%d')}_{driver.id}"
                
                # Effectuer le transfert (disbursement)
                transfer_result = orange_service.transfer_to_driver(
                    order_id=order_id,
                    amount=float(total_driver_amount),
                    receiver_phone=driver.phone_number,
                    reference=f"Paiement journalier {today.strftime('%d/%m/%Y')}"
                )
                
                # Mettre à jour le payout
                payout.status = 'processing'
                payout.provider_reference = transfer_result.get('reference', order_id)
                payout.save()
                
                # Créer entrée TransactionHistory
                TransactionHistory.objects.create(
                    payment=today_payments.first(),  # Lien avec le premier paiement
                    transaction_type='disbursement',
                    amount=total_driver_amount,
                    status='pending',
                    provider_reference=transfer_result.get('reference', order_id)
                )
                
                logger.info(
                    f"✅ Transfert Orange Money initié pour {driver.user.full_name}: "
                    f"{total_driver_amount} CFA"
                )
                
                # Envoyer notification au driver
                NotificationHistory.create_and_send(
                    user=driver.user,
                    notification_type='payment_received',
                    title='💰 Paiement journalier reçu',
                    body=f'Votre paiement de {total_driver_amount} CFA a été transféré vers votre compte Orange Money.',
                    data={
                        'payout_id': str(payout.id),
                        'amount': str(total_driver_amount),
                        'payment_count': today_payments.count(),
                        'date': today.isoformat()
                    },
                    action='view_payout',
                    action_url=f'/payouts/{payout.id}'
                )
                
                total_payouts_created += 1
                total_amount_transferred += total_driver_amount
                
            except Exception as transfer_error:
                logger.error(
                    f"❌ Erreur transfert Orange Money pour {driver.user.full_name}: "
                    f"{str(transfer_error)}"
                )
                
                # Marquer le payout comme échoué
                payout.status = 'failed'
                payout.save()
                
                # Créer entrée TransactionHistory pour l'échec
                TransactionHistory.objects.create(
                    payment=today_payments.first(),
                    transaction_type='disbursement',
                    amount=total_driver_amount,
                    status='failed',
                    error_message=str(transfer_error)[:500]
                )
                
                # Envoyer notification d'échec au driver
                NotificationHistory.create_and_send(
                    user=driver.user,
                    notification_type='payment_failed',
                    title='⚠️ Erreur paiement',
                    body='Une erreur est survenue lors du transfert. Notre équipe est notifiée.',
                    data={
                        'payout_id': str(payout.id),
                        'error': str(transfer_error)[:200]
                    }
                )
                
                failed_payouts.append({
                    'driver': driver.user.full_name,
                    'amount': str(total_driver_amount),
                    'error': str(transfer_error)[:200]
                })
                
        except Exception as e:
            logger.error(
                f"❌ Erreur traitement payout pour {driver.user.full_name}: "
                f"{str(e)}"
            )
            failed_payouts.append({
                'driver': driver.user.full_name,
                'error': str(e)[:200]
            })
    
    # Résumé final
    logger.info("=" * 80)
    logger.info("📊 RÉSUMÉ DES PAIEMENTS QUOTIDIENS (23h59)")
    logger.info(f"✅ Payouts créés: {total_payouts_created}")
    logger.info(f"💰 Montant total transféré: {total_amount_transferred} CFA")
    logger.info(f"❌ Payouts échoués: {len(failed_payouts)}")
    
    if failed_payouts:
        logger.error("⚠️  DÉTAILS DES ÉCHECS:")
        for failure in failed_payouts:
            logger.error(f"  - {failure}")
    
    logger.info("=" * 80)
    
    return {
        'success': True,
        'payouts_created': total_payouts_created,
        'total_amount': str(total_amount_transferred),
        'failed_count': len(failed_payouts),
        'failed_details': failed_payouts
    }


@shared_task(bind=True, max_retries=3)
def check_pending_payouts(self):
    """
    Tâche optionnelle pour vérifier les payouts en attente.
    Peut être exécutée toutes les heures pour vérifier les statuts.
    """
    logger.info("🔍 Vérification des payouts en attente...")
    
    # Récupérer les payouts processing de moins de 24h
    yesterday = timezone.now() - timedelta(days=1)
    pending_payouts = DailyPayout.objects.filter(
        status='processing',
        created_at__gte=yesterday
    )
    
    orange_service = OrangeMoneyService()
    updated_count = 0
    
    for payout in pending_payouts:
        try:
            # Vérifier le statut via Orange Money
            order_id = f"PAYOUT_{payout.payout_date.strftime('%Y%m%d')}_{payout.driver.id}"
            status = orange_service.check_payment_status(order_id)
            
            if status == 'SUCCESS':
                payout.status = 'completed'
                payout.paid_at = timezone.now()
                payout.save()
                
                # Notification de succès
                NotificationHistory.create_and_send(
                    user=payout.driver.user,
                    notification_type='payment_confirmed',
                    title='✅ Paiement confirmé',
                    body=f'Votre paiement de {payout.total_amount} CFA a été confirmé.',
                    data={'payout_id': str(payout.id)}
                )
                
                updated_count += 1
                logger.info(f"✅ Payout {payout.id} marqué comme completed")
                
            elif status == 'FAILED':
                payout.status = 'failed'
                payout.save()
                
                logger.warning(f"❌ Payout {payout.id} a échoué")
                
        except Exception as e:
            logger.error(f"❌ Erreur vérification payout {payout.id}: {str(e)}")
    
    logger.info(f"✅ {updated_count} payouts mis à jour")
    
    return {
        'success': True,
        'checked': pending_payouts.count(),
        'updated': updated_count
    }


@shared_task
def reset_daily_break_durations():
    """
    Tâche exécutée chaque jour à minuit (00:00).
    Reset les durées de pause quotidiennes des drivers.
    """
    logger.info("🔄 Reset des durées de pause quotidiennes...")
    
    today = timezone.now().date()
    
    # Reset pour tous les drivers dont last_break_reset != aujourd'hui
    drivers_to_reset = Driver.objects.exclude(last_break_reset=today)
    
    updated_count = drivers_to_reset.update(
        total_break_duration_today=timedelta(0),
        last_break_reset=today
    )
    
    logger.info(f"✅ {updated_count} drivers - durées de pause réinitialisées")
    
    return {
        'success': True,
        'reset_count': updated_count
    }
