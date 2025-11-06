#!/usr/bin/env python
"""
Script de test pour les tâches Celery.
Permet de tester manuellement les tâches sans attendre 23h59.

Usage:
    python test_celery_tasks.py
"""

import os
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from apps.payments.tasks import (
    process_daily_payouts,
    check_pending_payouts,
    reset_daily_break_durations
)


def test_process_daily_payouts():
    """Test de la tâche de paiement quotidien"""
    print("\n" + "="*80)
    print("🧪 TEST: process_daily_payouts")
    print("="*80)
    
    try:
        # Exécuter la tâche (synchrone)
        result = process_daily_payouts()
        
        print("\n✅ RÉSULTAT:")
        print(f"  - Payouts créés: {result['payouts_created']}")
        print(f"  - Montant total: {result['total_amount']} CFA")
        print(f"  - Échecs: {result['failed_count']}")
        
        if result['failed_details']:
            print("\n⚠️  ÉCHECS DÉTAILLÉS:")
            for failure in result['failed_details']:
                print(f"  - {failure}")
        
        print("\n✅ Test terminé avec succès!")
        
    except Exception as e:
        print(f"\n❌ ERREUR: {str(e)}")
        import traceback
        traceback.print_exc()


def test_check_pending_payouts():
    """Test de la vérification des payouts en attente"""
    print("\n" + "="*80)
    print("🧪 TEST: check_pending_payouts")
    print("="*80)
    
    try:
        result = check_pending_payouts()
        
        print("\n✅ RÉSULTAT:")
        print(f"  - Payouts vérifiés: {result['checked']}")
        print(f"  - Payouts mis à jour: {result['updated']}")
        
        print("\n✅ Test terminé avec succès!")
        
    except Exception as e:
        print(f"\n❌ ERREUR: {str(e)}")
        import traceback
        traceback.print_exc()


def test_reset_daily_break_durations():
    """Test du reset des durées de pause"""
    print("\n" + "="*80)
    print("🧪 TEST: reset_daily_break_durations")
    print("="*80)
    
    try:
        result = reset_daily_break_durations()
        
        print("\n✅ RÉSULTAT:")
        print(f"  - Drivers réinitialisés: {result['reset_count']}")
        
        print("\n✅ Test terminé avec succès!")
        
    except Exception as e:
        print(f"\n❌ ERREUR: {str(e)}")
        import traceback
        traceback.print_exc()


def test_async_execution():
    """Test de l'exécution asynchrone avec Celery"""
    print("\n" + "="*80)
    print("🧪 TEST: Exécution Asynchrone (Celery Worker requis)")
    print("="*80)
    
    try:
        # Vérifier si Celery Worker est actif
        from celery import current_app
        
        print("\n📡 Envoi de la tâche au worker...")
        
        # Envoyer la tâche de manière asynchrone
        task = process_daily_payouts.delay()
        
        print(f"✅ Tâche envoyée!")
        print(f"  - Task ID: {task.id}")
        print(f"  - Status: {task.status}")
        
        print("\n⏳ Attente du résultat (timeout: 60s)...")
        result = task.get(timeout=60)
        
        print("\n✅ RÉSULTAT:")
        print(f"  - Payouts créés: {result['payouts_created']}")
        print(f"  - Montant total: {result['total_amount']} CFA")
        
        print("\n✅ Test asynchrone terminé avec succès!")
        
    except Exception as e:
        print(f"\n⚠️  ERREUR: {str(e)}")
        print("\n💡 Assurez-vous que:")
        print("  1. Redis est démarré: redis-server")
        print("  2. Celery Worker est actif: celery -A config worker -l info")


def main():
    """Fonction principale"""
    print("\n" + "="*80)
    print("🎯 TESTS DES TÂCHES CELERY - LEBENI'S PLATFORM")
    print("="*80)
    
    print("\nChoisissez un test:")
    print("1. Test process_daily_payouts (paiements quotidiens)")
    print("2. Test check_pending_payouts (vérification payouts)")
    print("3. Test reset_daily_break_durations (reset pauses)")
    print("4. Test exécution asynchrone (Celery Worker requis)")
    print("5. Tous les tests (synchrones)")
    
    choice = input("\nVotre choix (1-5): ").strip()
    
    if choice == '1':
        test_process_daily_payouts()
    elif choice == '2':
        test_check_pending_payouts()
    elif choice == '3':
        test_reset_daily_break_durations()
    elif choice == '4':
        test_async_execution()
    elif choice == '5':
        test_process_daily_payouts()
        test_check_pending_payouts()
        test_reset_daily_break_durations()
    else:
        print("\n❌ Choix invalide!")
    
    print("\n" + "="*80)
    print("🏁 TESTS TERMINÉS")
    print("="*80 + "\n")


if __name__ == '__main__':
    main()
