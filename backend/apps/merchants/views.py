from rest_framework import viewsets, permissions, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from django.db.models import Count, Sum, Avg, Q
from django.utils import timezone
from datetime import timedelta
from .models import Merchant
from .serializers import MerchantSerializer
from .utils import notify_merchant_approved, notify_merchant_rejected, notify_merchant_documents_received
from apps.deliveries.models import Delivery
from apps.payments.models import Invoice
from core.permissions import IsAdmin, IsMerchant
import logging

logger = logging.getLogger(__name__)


class MerchantViewSet(viewsets.ModelViewSet):
    queryset = Merchant.objects.all()
    serializer_class = MerchantSerializer
    
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['business_name', 'user__email']
    ordering_fields = ['created_at']
    
    def get_permissions(self):
        """
        Permissions adaptées :
        - Actions merchant: update, partial_update, update_documents, my_stats
        - Actions admin: approve, reject, pending_verification
        - list/retrieve : Authentifié
        - create/delete : Admin uniquement
        """
        if self.action in ['update', 'partial_update', 'update_documents', 'my_stats']:
            permission_classes = [permissions.IsAuthenticated, IsMerchant]
        elif self.action in ['approve', 'reject', 'pending_verification']:
            permission_classes = [permissions.IsAuthenticated, IsAdmin]
        elif self.action in ['list', 'retrieve']:
            permission_classes = [permissions.IsAuthenticated]
        else:
            permission_classes = [permissions.IsAdminUser]
        return [permission() for permission in permission_classes]
    
    def get_queryset(self):
        """Support Swagger"""
        if getattr(self, 'swagger_fake_view', False):
            return Merchant.objects.none()
        
        user = self.request.user
        
        if not user.is_authenticated:
            return Merchant.objects.none()
        
        # Les merchants voient uniquement leur propre profil
        if user.user_type == 'merchant':
            return Merchant.objects.filter(user=user)
        
        # Admins et autres voient tout
        return Merchant.objects.all()
    
    @action(detail=True, methods=['POST'], permission_classes=[IsAdmin])
    def approve(self, request, pk=None):
        """
        POST /api/v1/merchants/{id}/approve/
        
        Approuver un commerçant (admin uniquement).
        
        Ceci active le compte du commerçant et lui permet de créer des livraisons.
        """
        merchant = self.get_object()
        
        if merchant.verification_status == 'approved':
            return Response(
                {'error': 'Ce commerçant est déjà approuvé'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Approuver le merchant
        merchant.verification_status = 'approved'
        merchant.rejection_reason = ''  # Réinitialiser le motif de rejet
        merchant.save()
        
        # Activer le compte utilisateur
        merchant.user.is_active = True
        merchant.user.save()
        
        logger.info(f"✅ Merchant approuvé: {merchant.business_name} ({merchant.user.email})")
        
        # Envoyer notification push au merchant
        notify_merchant_approved(merchant)
        
        serializer = MerchantSerializer(merchant)
        return Response({
            'success': True,
            'message': 'Commerçant approuvé avec succès',
            'merchant': serializer.data
        })
    
    @action(detail=True, methods=['POST'], permission_classes=[IsAdmin])
    def reject(self, request, pk=None):
        """
        POST /api/v1/merchants/{id}/reject/
        
        Rejeter un commerçant (admin uniquement).
        
        Body: {
            "rejection_reason": "Documents invalides / Informations incorrectes / ..."
        }
        """
        merchant = self.get_object()
        
        rejection_reason = request.data.get('rejection_reason', '')
        
        if not rejection_reason:
            return Response(
                {'error': 'Le champ rejection_reason est requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Rejeter le merchant
        merchant.verification_status = 'rejected'
        merchant.rejection_reason = rejection_reason
        merchant.save()
        
        # Désactiver le compte utilisateur
        merchant.user.is_active = False
        merchant.user.save()
        
        logger.info(f"❌ Merchant rejeté: {merchant.business_name} - Raison: {rejection_reason}")
        
        # Envoyer notification push au merchant
        notify_merchant_rejected(merchant, rejection_reason)
        
        serializer = MerchantSerializer(merchant)
        return Response({
            'success': True,
            'message': 'Commerçant rejeté',
            'merchant': serializer.data
        })
    
    @action(detail=False, methods=['GET'], permission_classes=[IsAdmin])
    def pending_verification(self, request):
        """
        GET /api/v1/merchants/pending-verification/
        
        Lister tous les commerçants en attente de vérification (admin uniquement).
        """
        pending_merchants = Merchant.objects.filter(
            verification_status='pending'
        ).order_by('-created_at')
        
        page = self.paginate_queryset(pending_merchants)
        if page is not None:
            serializer = MerchantSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = MerchantSerializer(pending_merchants, many=True)
        return Response(serializer.data)
    
    def perform_update(self, serializer):
        """
        Surcharge pour s'assurer qu'un merchant ne peut modifier QUE son propre profil
        """
        # Vérifier que l'utilisateur modifie bien son propre profil
        merchant = self.get_object()
        if hasattr(self.request.user, 'merchant_profile') and self.request.user.merchant_profile == merchant:
            # Empêcher la modification du statut de vérification par le merchant
            if 'verification_status' in serializer.validated_data:
                del serializer.validated_data['verification_status']
            serializer.save()
        else:
            raise ValidationError("Vous ne pouvez modifier que votre propre profil")
    
    @action(detail=False, methods=['PATCH'])
    def update_documents(self, request):
        """
        PATCH /api/v1/merchants/update-documents/
        
        Mettre à jour les documents du merchant connecté.
        
        Body: {
            "rccm_document": "https://cloudinary.com/...",
            "id_document": "https://cloudinary.com/..."
        }
        """
        try:
            merchant = Merchant.objects.get(user=request.user)
        except Merchant.DoesNotExist:
            return Response(
                {'error': 'Profil merchant introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        rccm_document = request.data.get('rccm_document')
        id_document = request.data.get('id_document')
        
        if rccm_document:
            merchant.rccm_document = rccm_document
        if id_document:
            merchant.id_document = id_document
        
        merchant.save()
        
        # Notifier que les documents ont été reçus
        if rccm_document or id_document:
            notify_merchant_documents_received(merchant)
        
        serializer = MerchantSerializer(merchant)
        return Response({
            'success': True,
            'message': 'Documents mis à jour avec succès',
            'merchant': serializer.data
        })
    
    @action(detail=False, methods=['GET'], permission_classes=[IsMerchant])
    def my_stats(self, request):
        """
        GET /api/v1/merchants/my-stats/?period=30
        
        Statistiques du merchant connecté.
        Query params: period (jours, défaut 30)
        """
        try:
            merchant = Merchant.objects.get(user=request.user)
        except Merchant.DoesNotExist:
            return Response(
                {'error': 'Profil merchant introuvable'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        period_days = int(request.query_params.get('period', 30))
        period_start = timezone.now() - timedelta(days=period_days)
        
        # Statistiques des livraisons
        deliveries = Delivery.objects.filter(merchant=merchant)
        period_deliveries = deliveries.filter(created_at__gte=period_start)
        
        total_deliveries = deliveries.count()
        period_count = period_deliveries.count()
        delivered_count = period_deliveries.filter(status='delivered').count()
        cancelled_count = period_deliveries.filter(status='cancelled').count()
        pending_count = period_deliveries.filter(status='pending').count()
        in_progress_count = period_deliveries.filter(
            status__in=['assigned', 'picked_up', 'in_transit']
        ).count()
        
        # Chiffre d'affaires (montant total livré)
        revenue = period_deliveries.filter(
            status='delivered'
        ).aggregate(total=Sum('calculated_price'))['total'] or 0
        
        # Factures
        invoices = Invoice.objects.filter(merchant=merchant)
        period_invoices = invoices.filter(created_at__gte=period_start)
        
        total_billed = period_invoices.aggregate(total=Sum('total_amount'))['total'] or 0
        paid_amount = period_invoices.filter(status='paid').aggregate(total=Sum('total_amount'))['total'] or 0
        pending_amount = period_invoices.filter(status='sent').aggregate(total=Sum('total_amount'))['total'] or 0
        
        # Taux de succès
        success_rate = (delivered_count / period_count * 100) if period_count > 0 else 0
        
        return Response({
            'merchant': {
                'id': str(merchant.id),
                'business_name': merchant.business_name,
                'verification_status': merchant.verification_status
            },
            'period_days': period_days,
            'deliveries': {
                'total_all_time': total_deliveries,
                'period_total': period_count,
                'delivered': delivered_count,
                'in_progress': in_progress_count,
                'pending': pending_count,
                'cancelled': cancelled_count,
                'success_rate': round(success_rate, 2)
            },
            'revenue': {
                'period_revenue': str(revenue),
                'total_billed': str(total_billed),
                'paid': str(paid_amount),
                'pending_payment': str(pending_amount)
            },
            'invoices': {
                'total': period_invoices.count(),
                'paid': period_invoices.filter(status='paid').count(),
                'pending': period_invoices.filter(status='sent').count()
            }
        })
    
    @action(detail=True, methods=['GET'], permission_classes=[IsAdmin])
    def stats(self, request, pk=None):
        """
        GET /api/v1/merchants/{id}/stats/?period=30
        
        Statistiques d'un merchant (admin).
        """
        merchant = self.get_object()
        period_days = int(request.query_params.get('period', 30))
        period_start = timezone.now() - timedelta(days=period_days)
        
        deliveries = Delivery.objects.filter(merchant=merchant)
        period_deliveries = deliveries.filter(created_at__gte=period_start)
        
        stats = {
            'merchant': {
                'id': str(merchant.id),
                'business_name': merchant.business_name,
                'commission_rate': str(merchant.commission_rate),
                'verification_status': merchant.verification_status
            },
            'period_days': period_days,
            'deliveries': {
                'total': period_deliveries.count(),
                'by_status': {
                    'pending': period_deliveries.filter(status='pending').count(),
                    'assigned': period_deliveries.filter(status='assigned').count(),
                    'picked_up': period_deliveries.filter(status='picked_up').count(),
                    'delivered': period_deliveries.filter(status='delivered').count(),
                    'cancelled': period_deliveries.filter(status='cancelled').count()
                }
            },
            'revenue': {
                'total': str(period_deliveries.filter(status='delivered').aggregate(
                    total=Sum('calculated_price'))['total'] or 0)
            }
        }
        
        return Response(stats)

