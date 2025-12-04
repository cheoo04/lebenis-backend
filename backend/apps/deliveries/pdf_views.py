"""
PDF Report Views
API endpoints for generating and downloading PDF reports
"""
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.http import HttpResponse
from django.shortcuts import get_object_or_404
from datetime import datetime, timedelta
from .analytics_serializers import DateRangeSerializer
from .pdf_service import PDFReportService
from .models import Delivery
from core.permissions import IsMerchant


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_analytics_pdf(request):
    """
    Generate and download analytics PDF report
    
    POST /api/v1/deliveries/reports/analytics-pdf/
    
    Request Body:
    {
        "period": "week",  // 'today', 'week', 'month', 'year', 'custom'
        "start_date": "2024-01-01",  // required if period='custom'
        "end_date": "2024-12-31"     // required if period='custom'
    }
    
    Returns:
        PDF file download
    """
    # Check if user is a driver
    try:
        driver = request.user.driver_profile
    except AttributeError:
        return Response(
            {'error': 'Driver profile not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Validate date range
    serializer = DateRangeSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    # Get date range
    period = serializer.validated_data.get('period', 'week')
    start_date = serializer.validated_data['start_date']
    end_date = serializer.validated_data['end_date']
    
    # Validate date range
    if start_date > end_date:
        return Response(
            {'error': 'start_date must be before end_date'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    if (end_date - start_date).days > 365:
        return Response(
            {'error': 'Date range cannot exceed 365 days'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        # Generate PDF
        pdf_file = PDFReportService.generate_analytics_report(
            driver=driver,
            start_date=start_date,
            end_date=end_date,
            period=period
        )
        
        # Generate filename
        filename = PDFReportService.generate_filename(
            driver=driver,
            start_date=start_date,
            end_date=end_date
        )
        
        # Create HTTP response with PDF
        response = HttpResponse(pdf_file.read(), content_type='application/pdf')
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        response['Access-Control-Expose-Headers'] = 'Content-Disposition'
        
        return response
        
    except Exception as e:
        return Response(
            {'error': f'Failed to generate PDF: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def test_pdf_generation(request):
    """
    Test endpoint to verify PDF generation works
    
    GET /api/v1/deliveries/reports/test-pdf/
    
    Generates a sample PDF for the last 7 days
    """
    # Check if user is a driver
    try:
        driver = request.user.driver_profile
    except AttributeError:
        return Response(
            {'error': 'Driver profile not found'},
            status=status.HTTP_404_NOT_FOUND
        )
    
    # Generate PDF for last 7 days
    end_date = datetime.now().date()
    start_date = end_date - timedelta(days=7)
    
    try:
        pdf_file = PDFReportService.generate_analytics_report(
            driver=driver,
            start_date=start_date,
            end_date=end_date,
            period='week'
        )
        
        filename = f'test_report_{driver.id}.pdf'
        
        response = HttpResponse(pdf_file.read(), content_type='application/pdf')
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        response['Access-Control-Expose-Headers'] = 'Content-Disposition'
        
        return response
        
    except Exception as e:
        return Response(
            {'error': f'Failed to generate PDF: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated, IsMerchant])
def generate_delivery_pdf(request, delivery_id):
    """
    Generate and download a delivery receipt/report PDF
    
    GET /api/v1/deliveries/{delivery_id}/generate-pdf/
    
    Response: PDF file download
    
    Permissions:
    - Only the merchant who owns the delivery can download it
    """
    # Get the delivery
    delivery = get_object_or_404(Delivery, id=delivery_id)
    
    # Check if the merchant owns this delivery
    if not hasattr(request.user, 'merchant_profile'):
        return Response(
            {'error': 'Only merchants can download delivery reports'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    if delivery.merchant.id != request.user.merchant_profile.id:
        return Response(
            {'error': 'You can only download reports for your own deliveries'},
            status=status.HTTP_403_FORBIDDEN
        )
    
    try:
        # Generate PDF
        pdf_file = PDFReportService.generate_delivery_report(delivery)
        filename = PDFReportService.generate_delivery_filename(delivery)
        
        # Return PDF response
        response = HttpResponse(pdf_file.read(), content_type='application/pdf')
        response['Content-Disposition'] = f'attachment; filename="{filename}"'
        response['Access-Control-Expose-Headers'] = 'Content-Disposition'
        
        return response
        
    except Exception as e:
        return Response(
            {'error': f'Failed to generate PDF: {str(e)}'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )
