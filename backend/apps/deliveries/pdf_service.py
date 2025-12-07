"""
PDF Report Generation Service
Generates professional PDF reports for driver analytics and delivery receipts
"""
from datetime import datetime
from io import BytesIO
from django.template.loader import render_to_string
from django.utils import timezone
from weasyprint import HTML, CSS
from weasyprint.text.fonts import FontConfiguration
from .analytics_service import AnalyticsService
import logging

logger = logging.getLogger(__name__)


class PDFReportService:
    """Service for generating PDF reports from analytics data"""

    @staticmethod
    def generate_analytics_report(driver, start_date, end_date, period='custom'):
        """
        Generate a comprehensive analytics PDF report
        
        Args:
            driver: Driver instance
            start_date: Report start date
            end_date: Report end date
            period: Period label for display
            
        Returns:
            BytesIO: PDF file content
        """
        # Fetch all analytics data
        summary = AnalyticsService.get_driver_stats_summary(
            driver, start_date, end_date
        )
        
        timeline = AnalyticsService.get_deliveries_timeline(
            driver, start_date, end_date, granularity='day'
        )
        
        status_distribution = AnalyticsService.get_deliveries_by_status(
            driver, start_date, end_date
        )
        
        peak_hours = AnalyticsService.get_peak_hours_stats(
            driver, start_date, end_date
        )
        
        earnings_breakdown = AnalyticsService.get_earnings_breakdown(
            driver, start_date, end_date
        )
        
        commune_stats = AnalyticsService.get_deliveries_by_commune(
            driver, start_date, end_date
        )
        
        distance_distribution = AnalyticsService.get_distance_distribution(
            driver, start_date, end_date
        )
        
        # Prepare context for template
        context = {
            'driver': driver,
            'driver_name': f"{driver.user.first_name} {driver.user.last_name}",
            'driver_phone': driver.user.phone_number,
            'driver_email': driver.user.email,
            'period': period,
            'start_date': start_date,
            'end_date': end_date,
            'generated_at': datetime.now(),
            'summary': summary,
            'timeline': timeline,
            'status_distribution': status_distribution,
            'peak_hours': peak_hours,
            'earnings_breakdown': earnings_breakdown,
            'commune_stats': commune_stats[:10],  # Top 10 communes
            'distance_distribution': distance_distribution,
        }
        
        # Render HTML template
        html_string = render_to_string('reports/analytics_report.html', context)
        
        # Generate PDF
        pdf_file = BytesIO()
        font_config = FontConfiguration()
        
        HTML(string=html_string).write_pdf(
            pdf_file,
            stylesheets=[CSS(string=PDFReportService._get_css())],
            font_config=font_config
        )
        
        pdf_file.seek(0)
        return pdf_file
    
    @staticmethod
    def generate_filename(driver, start_date, end_date):
        """Generate a standardized filename for the PDF report"""
        driver_id = driver.id
        date_str = datetime.now().strftime('%Y%m%d_%H%M%S')
        return f'analytics_report_driver_{driver_id}_{start_date}_{end_date}_{date_str}.pdf'
    
    @staticmethod
    def _get_css():
        """Return CSS styles for the PDF report"""
        return """
        @page {
            size: A4;
            margin: 1.5cm;
        }
        
        body {
            font-family: Arial, Helvetica, sans-serif;
            font-size: 11pt;
            line-height: 1.6;
            color: #333;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 3px solid #2196F3;
        }
        
        .header h1 {
            color: #2196F3;
            font-size: 24pt;
            margin: 0;
            padding: 0;
        }
        
        .header .subtitle {
            color: #666;
            font-size: 12pt;
            margin-top: 5px;
        }
        
        .driver-info {
            background: #f5f5f5;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        
        .driver-info p {
            margin: 5px 0;
        }
        
        .section {
            margin-bottom: 25px;
            page-break-inside: avoid;
        }
        
        .section-title {
            color: #2196F3;
            font-size: 16pt;
            font-weight: bold;
            margin-bottom: 15px;
            padding-bottom: 8px;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 15px;
            margin-bottom: 20px;
        }
        
        .stat-card {
            background: #fff;
            border: 2px solid #e0e0e0;
            border-radius: 5px;
            padding: 15px;
            text-align: center;
        }
        
        .stat-card.highlight {
            border-color: #2196F3;
            background: #E3F2FD;
        }
        
        .stat-value {
            font-size: 20pt;
            font-weight: bold;
            color: #2196F3;
            display: block;
            margin-bottom: 5px;
        }
        
        .stat-label {
            font-size: 10pt;
            color: #666;
            text-transform: uppercase;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
        }
        
        table th {
            background: #2196F3;
            color: white;
            padding: 10px;
            text-align: left;
            font-weight: bold;
        }
        
        table td {
            padding: 8px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        table tr:nth-child(even) {
            background: #f9f9f9;
        }
        
        .earnings-breakdown {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 5px;
            padding: 15px;
        }
        
        .earning-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        
        .earning-row.total {
            font-weight: bold;
            font-size: 14pt;
            border-top: 2px solid #2196F3;
            margin-top: 10px;
            padding-top: 10px;
        }
        
        .footer {
            margin-top: 30px;
            padding-top: 15px;
            border-top: 2px solid #e0e0e0;
            text-align: center;
            font-size: 9pt;
            color: #999;
        }
        
        .badge {
            display: inline-block;
            padding: 3px 8px;
            border-radius: 3px;
            font-size: 9pt;
            font-weight: bold;
        }
        
        .badge.success {
            background: #4CAF50;
            color: white;
        }
        
        .badge.warning {
            background: #FF9800;
            color: white;
        }
        
        .badge.danger {
            background: #F44336;
            color: white;
        }
        
        .badge.info {
            background: #2196F3;
            color: white;
        }
        """
    
    @staticmethod
    def generate_delivery_report(delivery):
        """
        Generate a delivery receipt/report PDF
        
        Args:
            delivery: Delivery instance
            
        Returns:
            BytesIO: PDF file content
        """
        # Prepare context data
        context = {
            'delivery': delivery,
            'generated_at': timezone.now(),
        }
        
        # Render HTML template and generate PDF. If WeasyPrint or template
        # rendering fails (occasionally due to CSS/font issues), log the full
        # exception and attempt a minimal fallback PDF to avoid a 500.
        try:
            html_string = render_to_string('reports/delivery_report.html', context)

            # Generate PDF
            pdf_file = BytesIO()

            # Configure fonts
            font_config = FontConfiguration()
            HTML(string=html_string).write_pdf(
                pdf_file,
                stylesheets=[CSS(string=PDFReportService._get_delivery_css())],
                font_config=font_config
            )

            pdf_file.seek(0)
            return pdf_file

        except Exception:
            # Log full traceback for diagnosis
            logger.exception(f"Error generating delivery PDF for delivery={getattr(delivery, 'id', None)}")

            # Minimal fallback HTML (plain, no advanced CSS) using safe attribute access
            def safe(obj, attr, default=''):
                try:
                    return getattr(obj, attr)
                except Exception:
                    return default

            merchant_name = ''
            try:
                merchant_name = delivery.merchant.business_name
            except Exception:
                merchant_name = ''

            driver_name = ''
            try:
                driver_name = f"{delivery.driver.user.first_name} {delivery.driver.user.last_name}"
            except Exception:
                driver_name = ''

            minimal_html = f"""
            <html><body>
            <h1>Delivery {getattr(delivery, 'tracking_number', '')}</h1>
            <p>Status: {getattr(delivery, 'status', '')}</p>
            <p>Merchant: {merchant_name}</p>
            <p>Recipient: {getattr(delivery, 'recipient_name', '')} - {getattr(delivery, 'recipient_phone', '')}</p>
            <p>Price: {getattr(delivery, 'calculated_price', '')}</p>
            <p>Distance (km): {getattr(delivery, 'distance_km', '')}</p>
            <p>Driver: {driver_name}</p>
            </body></html>
            """

            # Try to generate a very small PDF without custom fonts/styles
            pdf_file = BytesIO()
            try:
                HTML(string=minimal_html).write_pdf(pdf_file)
                pdf_file.seek(0)
                return pdf_file
            except Exception:
                # If fallback fails, re-raise to be handled by caller
                logger.exception("Fallback PDF generation also failed")
                raise
    
    @staticmethod
    def generate_delivery_filename(delivery):
        """Generate a standardized filename for the delivery PDF"""
        date_str = timezone.now().strftime('%Y%m%d_%H%M%S')
        return f'delivery_{delivery.tracking_number}_{date_str}.pdf'
    
    @staticmethod
    def _get_delivery_css():
        """Return CSS styles for the delivery PDF report"""
        return """
        @page {
            size: A4;
            margin: 1.5cm;
        }
        
        body {
            font-family: 'DejaVu Sans', Arial, sans-serif;
            font-size: 11pt;
            line-height: 1.6;
            color: #333;
        }
        
        .header {
            text-align: center;
            margin-bottom: 30px;
            padding-bottom: 15px;
            border-bottom: 3px solid #4CAF50;
        }
        
        .header h1 {
            margin: 0;
            color: #4CAF50;
            font-size: 24pt;
        }
        
        .header .subtitle {
            color: #666;
            font-size: 12pt;
            margin-top: 5px;
        }
        
        .info-section {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        
        .info-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .info-row:last-child {
            border-bottom: none;
        }
        
        .label {
            font-weight: bold;
            color: #555;
        }
        
        .value {
            color: #333;
        }
        
        .tracking-number {
            font-family: 'Courier New', monospace;
            font-size: 12pt;
            font-weight: bold;
            color: #4CAF50;
        }
        
        .section {
            margin-bottom: 25px;
            page-break-inside: avoid;
        }
        
        .section-title {
            color: #4CAF50;
            font-size: 14pt;
            margin-bottom: 15px;
            padding-bottom: 8px;
            border-bottom: 2px solid #e0e0e0;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        .info-item {
            padding: 10px;
            background: #f8f9fa;
            border-radius: 5px;
        }
        
        .info-item.full-width {
            grid-column: 1 / -1;
        }
        
        .item-label {
            display: block;
            font-size: 9pt;
            color: #666;
            margin-bottom: 5px;
            text-transform: uppercase;
        }
        
        .item-value {
            display: block;
            font-size: 11pt;
            font-weight: bold;
            color: #333;
        }
        
        .pricing-table {
            background: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            overflow: hidden;
        }
        
        .pricing-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 15px;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .pricing-row:last-child {
            border-bottom: none;
        }
        
        .pricing-row.total {
            background: #4CAF50;
            color: white;
            font-size: 12pt;
        }
        
        .instructions-box {
            background: #fff3cd;
            border: 1px solid #ffc107;
            border-radius: 5px;
            padding: 15px;
            color: #856404;
        }
        
        .rating-container {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 8px;
        }
        
        .rating-row {
            display: flex;
            justify-content: space-between;
            padding: 8px 0;
            border-bottom: 1px solid #e0e0e0;
        }
        
        .rating-row:last-child {
            border-bottom: none;
        }
        
        .rating-stars {
            color: #FFC107;
            font-size: 12pt;
            font-weight: bold;
        }
        
        .rating-comment {
            margin-top: 15px;
            padding: 10px;
            background: white;
            border-left: 4px solid #4CAF50;
            font-style: italic;
        }
        
        .badge {
            display: inline-block;
            padding: 5px 12px;
            border-radius: 12px;
            font-size: 9pt;
            font-weight: bold;
            text-transform: uppercase;
        }
        
        .badge.success {
            background: #4CAF50;
            color: white;
        }
        
        .badge.warning {
            background: #FF9800;
            color: white;
        }
        
        .badge.danger {
            background: #F44336;
            color: white;
        }
        
        .badge.info {
            background: #2196F3;
            color: white;
        }
        
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 2px solid #e0e0e0;
            text-align: center;
            color: #666;
            font-size: 10pt;
        }
        
        .footer p {
            margin: 5px 0;
        }
        """
