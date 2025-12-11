# apps/payments/views.py

import logging
from decimal import Decimal
from datetime import datetime, timedelta
from django.db.models import Sum, Q, Count
from django.utils import timezone
from rest_framework import viewsets, status, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import ValidationError

from .models import Invoice, InvoiceItem, DriverEarning, DriverPayment
from .serializers import (
    InvoiceSerializer, InvoiceCreateSerializer, InvoicePaymentSerializer,
    InvoiceItemSerializer,
    DriverEarningSerializer, DriverEarningCreateSerializer, DriverEarningSummarySerializer,
    DriverPaymentSerializer, DriverPaymentCreateSerializer
)
from apps.merchants.models import Merchant
from apps.drivers.models import Driver
from apps.deliveries.models import Delivery
from core.permissions import IsMerchant, IsDriver, IsAdmin

logger = logging.getLogger(__name__)


# ==============================================================================
# VIEWSETS POUR FACTURES (MERCHANTS)
# ==============================================================================

class InvoiceViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour gérer les factures des commerçants.
    """
    queryset = Invoice.objects.select_related('merchant__user').all()
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['invoice_number', 'merchant__business_name']
    ordering_fields = ['created_at', 'due_date', 'total_amount']
    
    def get_serializer_class(self):
        if self.action == 'create':
            return InvoiceCreateSerializer
        elif self.action == 'mark_as_paid':
            return InvoicePaymentSerializer
        return InvoiceSerializer
    
    def get_permissions(self):
        """
        Permissions :
        - Merchants : Voir leurs factures uniquement
        - Admins : Créer, modifier, tout voir
        """
        if self.action in ['create', 'update', 'partial_update', 'destroy', 'generate_monthly']:
            return [IsAdmin()]
        elif self.action in ['list', 'retrieve', 'my_invoices']:
            return [IsAuthenticated()]
        return [IsAdmin()]
    
    def get_queryset(self):
        """Filtre par rôle"""
        # Support Swagger
        if getattr(self, 'swagger_fake_view', False):
            return Invoice.objects.none()
        
        user = self.request.user
        
        if not user.is_authenticated:
            return Invoice.objects.none()
        
        if user.user_type == 'merchant':
            try:
                merchant = Merchant.objects.get(user=user)
                return Invoice.objects.filter(merchant=merchant)
            except Merchant.DoesNotExist:
                return Invoice.objects.none()
        
        # Admins voient tout
        return Invoice.objects.all()
    
    def perform_create(self, serializer):
        """Crée une facture et génère les items automatiquement"""
        merchant = serializer.validated_data['merchant']
        period_start = serializer.validated_data['period_start']
        period_end = serializer.validated_data['period_end']
        
        # Générer le numéro de facture
        invoice_number = self._generate_invoice_number(merchant, period_start)
        
        # Créer la facture
        invoice = serializer.save(invoice_number=invoice_number)
        
        # Récupérer les livraisons de la période
        deliveries = Delivery.objects.filter(
            merchant=merchant,
            status='delivered',
            delivered_at__gte=period_start,
            delivered_at__lte=period_end
        ).exclude(
            invoice_item__isnull=False  # Exclure celles déjà facturées
        )
        
        # Créer les items
        for delivery in deliveries:
            InvoiceItem.objects.create(
                invoice=invoice,
                delivery=delivery,
                description=f"Livraison {delivery.tracking_number} - {delivery.delivery_commune}",
                amount=delivery.calculated_price
            )
        
        # Calculer les totaux
        invoice.calculate_totals()
        
        logger.info(f"✅ Facture créée: {invoice.invoice_number} | Merchant: {merchant.business_name} | {invoice.total_deliveries} livraisons")
    
    def _generate_invoice_number(self, merchant, period_start):
        """Génère un numéro de facture unique"""
        year = period_start.year
        month = period_start.month
        
        # Compter les factures existantes pour ce mois
        count = Invoice.objects.filter(
            period_start__year=year,
            period_start__month=month
        ).count() + 1
        
        return f"INV-{year}{month:02d}-{count:04d}"
    
    @action(detail=False, methods=['GET'], permission_classes=[IsMerchant])
    def my_invoices(self, request):
        """
        GET /api/v1/payments/invoices/my-invoices/
        
        Mes factures (merchant uniquement).
        """
        try:
            merchant = Merchant.objects.get(user=request.user)
        except Merchant.DoesNotExist:
            return Response(
                {'error': 'Profil merchant introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        invoices = Invoice.objects.filter(merchant=merchant).order_by('-created_at')
        
        # Filtres optionnels
        status_filter = request.query_params.get('status')
        if status_filter:
            invoices = invoices.filter(status=status_filter)
        
        page = self.paginate_queryset(invoices)
        if page is not None:
            serializer = InvoiceSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = InvoiceSerializer(invoices, many=True)
        return Response(serializer.data)
    
    @action(detail=True, methods=['POST'], permission_classes=[IsAdmin])
    def mark_as_paid(self, request, pk=None):
        """
        POST /api/v1/payments/invoices/{id}/mark-as-paid/
        
        Marque une facture comme payée (admin uniquement).
        
        Body: {
            "payment_method": "mobile_money",
            "payment_reference": "TRX123456"
        }
        """
        invoice = self.get_object()
        
        if invoice.status == 'paid':
            return Response(
                {'error': 'Cette facture est déjà payée'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = InvoicePaymentSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        invoice.mark_as_paid(
            payment_method=serializer.validated_data['payment_method'],
            payment_reference=serializer.validated_data.get('payment_reference', '')
        )
        
        logger.info(f"💰 Facture payée: {invoice.invoice_number} | Montant: {invoice.total_amount} CFA")
        
        return Response({
            'success': True,
            'invoice_number': invoice.invoice_number,
            'paid_at': invoice.paid_at,
            'amount': str(invoice.total_amount)
        })
    
    @action(detail=False, methods=['POST'], permission_classes=[IsAdmin])
    def generate_monthly(self, request):
        """
        POST /api/v1/payments/invoices/generate-monthly/
        
        Génère toutes les factures mensuelles pour tous les merchants (admin).
        
        Body: {
            "year": 2025,
            "month": 11
        }
        """
        year = request.data.get('year')
        month = request.data.get('month')
        
        if not year or not month:
            return Response(
                {'error': 'Les champs year et month sont requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Période du mois
        period_start = datetime(year, month, 1).date()
        if month == 12:
            period_end = datetime(year + 1, 1, 1).date() - timedelta(days=1)
        else:
            period_end = datetime(year, month + 1, 1).date() - timedelta(days=1)
        
        # Due date : 15 jours après la fin du mois
        due_date = period_end + timedelta(days=15)
        
        # Générer une facture pour chaque merchant ayant des livraisons
        merchants_with_deliveries = Merchant.objects.filter(
            deliveries__status='delivered',
            deliveries__delivered_at__gte=period_start,
            deliveries__delivered_at__lte=period_end
        ).distinct()
        
        invoices_created = []
        
        for merchant in merchants_with_deliveries:
            # Vérifier si facture existe déjà
            existing = Invoice.objects.filter(
                merchant=merchant,
                period_start=period_start,
                period_end=period_end
            ).exists()
            
            if existing:
                continue
            
            # Créer la facture
            invoice_number = self._generate_invoice_number(merchant, period_start)
            
            invoice = Invoice.objects.create(
                invoice_number=invoice_number,
                merchant=merchant,
                period_start=period_start,
                period_end=period_end,
                commission_rate=merchant.commission_rate,
                due_date=due_date,
                status='sent'
            )
            
            # Créer les items
            deliveries = Delivery.objects.filter(
                merchant=merchant,
                status='delivered',
                delivered_at__gte=period_start,
                delivered_at__lte=period_end
            ).exclude(invoice_item__isnull=False)
            
            for delivery in deliveries:
                InvoiceItem.objects.create(
                    invoice=invoice,
                    delivery=delivery,
                    description=f"Livraison {delivery.tracking_number}",
                    amount=delivery.calculated_price
                )
            
            invoice.calculate_totals()
            invoices_created.append(invoice)
        
        logger.info(f"📊 {len(invoices_created)} factures générées pour {year}-{month}")
        
        serializer = InvoiceSerializer(invoices_created, many=True)
        return Response({
            'success': True,
            'count': len(invoices_created),
            'invoices': serializer.data
        })


# ==============================================================================
# VIEWSETS POUR REVENUS LIVREURS
# ==============================================================================

class DriverEarningViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour gérer les gains des livreurs.
    """
    queryset = DriverEarning.objects.select_related('driver__user', 'delivery').all()
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['driver__user__first_name', 'driver__user__last_name', 'delivery__tracking_number']
    ordering_fields = ['created_at', 'total_earning']
    
    def get_serializer_class(self):
        if self.action == 'create':
            return DriverEarningCreateSerializer
        elif self.action == 'summary':
            return DriverEarningSummarySerializer
        return DriverEarningSerializer
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'approve', 'bulk_approve']:
            return [IsAdmin()]
        elif self.action in ['list', 'retrieve', 'my_earnings', 'summary']:
            return [IsAuthenticated()]
        return [IsAdmin()]
    
    def get_queryset(self):
        """Filtre par rôle avec optimisation des requêtes"""
        if getattr(self, 'swagger_fake_view', False):
            return DriverEarning.objects.none()
        
        user = self.request.user
        
        if not user.is_authenticated:
            return DriverEarning.objects.none()
        
        base_qs = DriverEarning.objects.select_related('driver__user', 'delivery')
        
        if user.user_type == 'driver':
            try:
                driver = Driver.objects.get(user=user)
                return base_qs.filter(driver=driver)
            except Driver.DoesNotExist:
                return DriverEarning.objects.none()
        
        return base_qs.all()
    
    def perform_create(self, serializer):
        """Crée un gain et calcule le total"""
        earning = serializer.save()
        earning.calculate_total()
        
        logger.info(f"💵 Gain créé: {earning.driver.user.full_name} | Livraison: {earning.delivery.tracking_number} | {earning.total_earning} CFA")
    
    @action(detail=False, methods=['GET'], url_path='my-earnings')
    def my_earnings(self, request):
        """
        GET /api/v1/payments/earnings/my-earnings/?period=week|month
        Mes gains (driver uniquement).
        """
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil driver introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )

        earnings = DriverEarning.objects.filter(driver=driver).order_by('-created_at')

        # Filtre par période
        period = request.query_params.get('period')
        if period:
            now = datetime.now()
            if period == 'week':
                start = now - timedelta(days=now.weekday())  # début de la semaine
                end = start + timedelta(days=6)
                earnings = earnings.filter(created_at__date__gte=start.date(), created_at__date__lte=end.date())
            elif period == 'month':
                start = now.replace(day=1)
                next_month = (start.replace(day=28) + timedelta(days=4)).replace(day=1)
                end = next_month - timedelta(days=1)
                earnings = earnings.filter(created_at__date__gte=start.date(), created_at__date__lte=end.date())
            # Ajoute d'autres périodes si besoin

        # Filtres supplémentaires
        status_filter = request.query_params.get('status')
        if status_filter:
            earnings = earnings.filter(status=status_filter)

        page = self.paginate_queryset(earnings)
        if page is not None:
            serializer = DriverEarningSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = DriverEarningSerializer(earnings, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['GET'], permission_classes=[IsDriver])
    def summary(self, request):
        """
        GET /api/v1/payments/earnings/summary/
        
        Résumé des gains du driver connecté.
        """
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil driver introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        earnings = DriverEarning.objects.filter(driver=driver)
        
        summary = {
            'total_earnings': earnings.aggregate(Sum('total_earning'))['total_earning__sum'] or Decimal('0'),
            'pending_amount': earnings.filter(status='pending').aggregate(Sum('total_earning'))['total_earning__sum'] or Decimal('0'),
            'approved_amount': earnings.filter(status='approved').aggregate(Sum('total_earning'))['total_earning__sum'] or Decimal('0'),
            'paid_amount': earnings.filter(status='paid').aggregate(Sum('total_earning'))['total_earning__sum'] or Decimal('0'),
            'total_deliveries': earnings.count(),
            'pending_deliveries': earnings.filter(status='pending').count()
        }
        
        serializer = DriverEarningSummarySerializer(summary)
        return Response(serializer.data)

    @action(detail=False, methods=['POST'], permission_classes=[IsAdmin])
    def bulk_approve(self, request):
        """
        POST /api/v1/payments/earnings/bulk-approve/
        
        Approuve en masse les gains sélectionnés (admin uniquement).
        Body: { "earning_ids": [1,2,3] }
        """
        earning_ids = request.data.get('earning_ids')
        if not earning_ids:
            return Response(
                {'error': 'Le champ earning_ids est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        earnings = DriverEarning.objects.filter(
            id__in=earning_ids,
            status='pending'
        )
        
        approved_count = 0
        for earning in earnings:
            earning.approve()
            approved_count += 1
        
        logger.info(f"✅ {approved_count} gains approuvés en masse")
        
        return Response({
            'success': True,
            'approved_count': approved_count
        })


class DriverPaymentViewSet(viewsets.ModelViewSet):
    """
    ViewSet pour gérer les paiements groupés aux livreurs.
    """
    queryset = DriverPayment.objects.select_related('driver__user').prefetch_related('items').all()

    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy', 'mark_as_paid']:
            return [IsAdmin()]
        elif self.action in ['my_payouts']:
            return [IsDriver()]
        return [IsAdmin()]
    
    def get_serializer_class(self):
        if self.action == 'create':
            return DriverPaymentCreateSerializer
        return DriverPaymentSerializer
    
    def perform_create(self, serializer):
        """Crée un paiement et calcule le total"""
        driver = serializer.validated_data['driver']
        period_start = serializer.validated_data['period_start']
        
        # Générer le numéro de paiement
        payment_number = self._generate_payment_number(driver, period_start)
        
        payment = serializer.save(payment_number=payment_number)
        payment.calculate_total()
        
        logger.info(f"💳 Paiement créé: {payment.payment_number} | Driver: {driver.user.full_name} | {payment.total_amount} CFA")
    
    def _generate_payment_number(self, driver, period_start):
        """Génère un numéro de paiement unique"""
        year = period_start.year
        month = period_start.month
        
        count = DriverPayment.objects.filter(
            period_start__year=year,
            period_start__month=month
        ).count() + 1
        
        return f"PAY-{year}{month:02d}-{count:04d}"
    
    @action(detail=True, methods=['POST'])
    def mark_as_paid(self, request, pk=None):
        """
        POST /api/v1/payments/driver-payments/{id}/mark-as-paid/
        
        Marque un paiement comme payé.
        """
        payment = self.get_object()
        
        if payment.status == 'paid':
            return Response(
                {'error': 'Ce paiement est déjà marqué comme payé'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        payment.mark_as_paid()
        
        logger.info(f"💰 Paiement effectué: {payment.payment_number} | {payment.total_amount} CFA")
        
        return Response({
            'success': True,
            'payment_number': payment.payment_number,
            'paid_at': payment.paid_at
        })
    
    @action(detail=False, methods=['GET'], url_path='my-payouts')
    def my_payouts(self, request):
        """
        GET /api/v1/payments/driver-payments/my-payouts/?page=1&page_size=20
        
        Affiche les versements journaliers du driver connecté.
        """
        from .models import DailyPayout
        
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil driver introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Pagination optionnelle
        page = request.query_params.get('page')
        page_size = request.query_params.get('page_size', 20)
        
        payouts = DailyPayout.objects.filter(
            driver=driver
        ).order_by('-payout_date')
        
        # Si pagination demandée
        if page:
            paginated = self.paginate_queryset(payouts)
            if paginated is not None:
                from .serializers import DailyPayoutSerializer
                serializer = DailyPayoutSerializer(paginated, many=True)
                return self.get_paginated_response(serializer.data)
        
        # Sinon limiter à 30 par défaut
        limit = int(request.query_params.get('limit', 30))
        payouts = payouts[:limit]
        
        from .serializers import DailyPayoutSerializer
        serializer = DailyPayoutSerializer(payouts, many=True)
        
        return Response({
            'payouts': serializer.data if serializer.data is not None else [],
            'count': payouts.count()
        })


# ==============================================================================
# VIEWSETS POUR PAIEMENTS MOBILE MONEY (PHASE 2)
# ==============================================================================

class PaymentViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet pour les paiements Mobile Money des drivers.
    Endpoints pour voir les gains, paiements, et statistiques.
    """
    permission_classes = [IsDriver]
    serializer_class = None  # Défini dynamiquement dans get_serializer_class

    @action(detail=False, methods=['POST'], url_path='wave-session')
    def create_wave_session(self, request):
        """
        Crée une session de paiement Wave et retourne l'URL de paiement.

        **POST** `/api/v1/payments/wave-session/`

        ### Corps attendu (JSON):
        ```json
        {
          "amount": 1000.00,
          "currency": "XOF",
          "error_url": "https://votre-app.com/echec",
          "success_url": "https://votre-app.com/succes"
        }
        ```

        ### Réponse (succès):
        ```json
        {
          "payment_url": "https://checkout.wave.com/session/abc123"
        }
        ```

        ### Réponse (erreur):
        ```json
        {
          "error": "Message d'erreur explicite."
        }
        ```
        """
        from .services.wave_service import create_wave_payment_session, WaveAPIError
        from .serializers import WaveSessionInputSerializer

        serializer = WaveSessionInputSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data
        try:
            result = create_wave_payment_session(
                amount=data['amount'],
                currency=data['currency'],
                error_url=data['error_url'],
                success_url=data['success_url']
            )
            payment_url = result.get('payment_url') or result.get('redirect_url') or result.get('url')
            if not payment_url:
                return Response({'error': 'URL de paiement non trouvée dans la réponse Wave.'}, status=500)
            return Response({'payment_url': payment_url})
        except WaveAPIError as e:
            return Response({'error': str(e)}, status=502)
        except Exception as e:
            return Response({'error': f'Erreur inattendue: {e}'}, status=500)
    
    def get_serializer_class(self):
        """Retourne le serializer approprié selon l'action"""
        # Pour Swagger: retourner un serializer par défaut
        from .serializers import PaymentSerializer
        return PaymentSerializer
    
    def get_queryset(self):
        """Filtre les paiements du driver connecté"""
        if getattr(self, 'swagger_fake_view', False):
            from .models import Payment
            return Payment.objects.none()
        
        user = self.request.user
        
        if not user.is_authenticated or user.user_type != 'driver':
            from .models import Payment
            return Payment.objects.none()
        
        try:
            driver = Driver.objects.get(user=user)
            from .models import Payment
            return Payment.objects.filter(driver=driver)
        except Driver.DoesNotExist:
            from .models import Payment
            return Payment.objects.none()
    
    @action(detail=False, methods=['GET'], url_path='earnings-summary')
    def earnings_summary(self, request):
        """
        GET /api/v1/payments/earnings-summary/?period=today|week|month
        
        Affiche le résumé des paiements Mobile Money du driver pour la période demandée.
        
        Réponse: {
            "period": "today",
            "total_amount": 15000.00,
            "driver_amount": 12000.00,
            "platform_commission": 3000.00,
            "payment_count": 5,
            "payments": [...]
        }
        """
        from .models import Payment
        
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil driver introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Période demandée (par défaut: today)
        period = request.query_params.get('period', 'today')
        now = timezone.now()
        
        if period == 'today':
            start_date = now.replace(hour=0, minute=0, second=0, microsecond=0)
            period_label = "Aujourd'hui"
        elif period == 'week':
            start_date = now - timedelta(days=7)
            period_label = "Cette semaine"
        elif period == 'month':
            start_date = now - timedelta(days=30)
            period_label = "Ce mois"
        else:
            return Response(
                {'error': 'Période invalide. Utilisez: today, week, ou month'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Récupérer les paiements complétés
        payments = Payment.objects.filter(
            driver=driver,
            status='completed',
            created_at__gte=start_date
        ).order_by('-created_at')
        
        # Calculer les totaux
        # Le modèle `Payment` utilise `total_amount`, `driver_amount` et `platform_commission`
        total_amount = payments.aggregate(Sum('total_amount'))['total_amount__sum'] or Decimal('0')
        driver_amount = payments.aggregate(Sum('driver_amount'))['driver_amount__sum'] or Decimal('0')
        platform_commission_sum = payments.aggregate(Sum('platform_commission'))['platform_commission__sum'] or Decimal('0')
        
        from .serializers import PaymentSerializer
        serializer = PaymentSerializer(payments, many=True)
        
        return Response({
            'period': period,
            'period_label': period_label,
            'total_amount': str(total_amount),
            'driver_amount': str(driver_amount),
            'platform_commission': str(platform_commission_sum),
            'payment_count': payments.count(),
            'payments': serializer.data
        })
    
    @action(detail=False, methods=['GET'], url_path='my-payouts')
    def my_payouts(self, request):
        """
        GET /api/v1/payments/my-payouts/?limit=30
        
        Affiche les paiements journaliers du driver.
        
        Réponse: {
            "payouts": [
                {
                    "date": "2025-01-24",
                    "total_amount": 25000.00,
                    "payment_count": 10,
                    "status": "pending"
                }
            ]
        }
        """
        from .models import DailyPayout
        
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil driver introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        limit = int(request.query_params.get('limit', 30))
        
        payouts = DailyPayout.objects.filter(
            driver=driver
        ).order_by('-payout_date')[:limit]
        
        from .serializers import DailyPayoutSerializer
        serializer = DailyPayoutSerializer(payouts, many=True)
        
        return Response({
            'payouts': serializer.data if serializer.data is not None else [],
            'count': payouts.count()
        })
    
    @action(detail=False, methods=['GET'])
    def stats(self, request):
        """
        GET /api/v1/payments/stats/
        
        Statistiques globales des paiements du driver.
        
        Réponse: {
            "lifetime": {
                "total_earnings": 500000.00,
                "total_deliveries": 150
            },
            "this_month": {
                "earnings": 85000.00,
                "deliveries": 28
            },
            "last_month": {
                "earnings": 120000.00,
                "deliveries": 35
            },
            "payment_methods": {
                "orange_money": 250000.00,
                "mtn_money": 150000.00,
                "cash": 100000.00
            }
        }
        """
        from .models import Payment
        
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil driver introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        now = timezone.now()
        
        # Lifetime stats
        all_payments = Payment.objects.filter(driver=driver, status='completed')
        lifetime_earnings = all_payments.aggregate(Sum('driver_amount'))['driver_amount__sum'] or Decimal('0')
        lifetime_deliveries = all_payments.count()
        
        # This month
        month_start = now.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        this_month = all_payments.filter(created_at__gte=month_start)
        month_earnings = this_month.aggregate(Sum('driver_amount'))['driver_amount__sum'] or Decimal('0')
        month_deliveries = this_month.count()
        
        # Last month
        if now.month == 1:
            last_month_start = now.replace(year=now.year - 1, month=12, day=1, hour=0, minute=0, second=0, microsecond=0)
        else:
            last_month_start = now.replace(month=now.month - 1, day=1, hour=0, minute=0, second=0, microsecond=0)
        
        last_month = all_payments.filter(
            created_at__gte=last_month_start,
            created_at__lt=month_start
        )
        last_month_earnings = last_month.aggregate(Sum('driver_amount'))['driver_amount__sum'] or Decimal('0')
        last_month_deliveries = last_month.count()
        
        # By payment method
        payment_methods = {}
        for method in ['orange_money', 'mtn_money', 'moov_money', 'wave', 'cash']:
            method_total = all_payments.filter(
                payment_method=method
            ).aggregate(Sum('driver_amount'))['driver_amount__sum'] or Decimal('0')
            payment_methods[method] = str(method_total)
        
        return Response({
            'lifetime': {
                'total_earnings': str(lifetime_earnings),
                'total_deliveries': lifetime_deliveries
            },
            'this_month': {
                'earnings': str(month_earnings),
                'deliveries': month_deliveries
            },
            'last_month': {
                'earnings': str(last_month_earnings),
                'deliveries': last_month_deliveries
            },
            'payment_methods': payment_methods
        })
    
    @action(detail=False, methods=['GET'])
    def transactions(self, request):
        """
        GET /api/v1/payments/transactions/?limit=50
        
        Historique des transactions (audit trail).
        
        Réponse: {
            "transactions": [
                {
                    "id": "uuid",
                    "payment_id": "uuid",
                    "transaction_type": "collection",
                    "amount": 10000.00,
                    "status": "success",
                    "provider_reference": "TRX123",
                    "created_at": "2025-01-24T10:30:00Z"
                }
            ]
        }
        """
        from .models import TransactionHistory
        
        try:
            driver = Driver.objects.get(user=request.user)
        except Driver.DoesNotExist:
            return Response(
                {'error': 'Profil driver introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        limit = int(request.query_params.get('limit', 50))
        
        transactions = TransactionHistory.objects.filter(
            payment__driver=driver
        ).select_related('payment').order_by('-created_at')[:limit]
        
        from .serializers import TransactionHistorySerializer
        serializer = TransactionHistorySerializer(transactions, many=True)
        
        return Response({
            'transactions': serializer.data if serializer.data is not None else [],
            'count': transactions.count()
        })

