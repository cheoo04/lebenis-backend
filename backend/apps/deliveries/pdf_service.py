"""
PDF Report Generation Service
Generates professional PDF reports for driver analytics and delivery receipts
"""
from datetime import datetime
from io import BytesIO
from django.template.loader import render_to_string
from django.utils import timezone
# ReportLab used as a robust fallback when WeasyPrint fails in this environment
from weasyprint import HTML, CSS
from weasyprint.text.fonts import FontConfiguration
try:
    from reportlab.pdfgen import canvas as reportlab_canvas
    from reportlab.lib.pagesizes import A4 as REPORTLAB_A4
except Exception:
    reportlab_canvas = None
    REPORTLAB_A4 = None
import importlib
import pkgutil
import pydyf as _pydyf

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
        
        # Log report generation request (minimal info)
        try:
            logger.info("generate_analytics_report requested", extra={
                'driver_id': getattr(driver, 'id', None),
                'start_date': str(start_date),
                'end_date': str(end_date),
                'period': period,
            })
        except Exception:
            logger.info("generate_analytics_report requested driver=%s start=%s end=%s period=%s", getattr(driver, 'id', None), start_date, end_date, period)

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
        # Build a safe context dict for the template to avoid template errors
        # when related objects or fields are missing or lazily loaded.
        def safe_get(obj, path, default=None):
            try:
                cur = obj
                for part in path.split('.'):
                    if cur is None:
                        return default
                    cur = getattr(cur, part)
                return cur
            except Exception:
                return default

        delivery_ctx = {
            'tracking_number': safe_get(delivery, 'tracking_number', ''),
            'status': safe_get(delivery, 'status', ''),
            'created_at': safe_get(delivery, 'created_at', None),
            'delivered_at': safe_get(delivery, 'delivered_at', None),
            'merchant': {
                'business_name': safe_get(delivery, 'merchant.business_name', ''),
                'email': safe_get(delivery, 'merchant.user.email', ''),
            },
            'pickup_address': {
                'street_address': safe_get(delivery, 'pickup_address.street_address', ''),
                'commune': safe_get(delivery, 'pickup_address.commune', ''),
                'quartier': safe_get(delivery, 'pickup_address.quartier', ''),
            },
            'pickup_address_details': safe_get(delivery, 'pickup_address_details', ''),
            'recipient_name': safe_get(delivery, 'recipient_name', ''),
            'recipient_phone': safe_get(delivery, 'recipient_phone', ''),
            'delivery_address': safe_get(delivery, 'delivery_address', ''),
            'delivery_commune': safe_get(delivery, 'delivery_commune', ''),
            'delivery_quartier': safe_get(delivery, 'delivery_quartier', ''),
            'is_fragile': safe_get(delivery, 'is_fragile', False),
            'package_weight_kg': safe_get(delivery, 'package_weight_kg', None),
            'package_description': safe_get(delivery, 'package_description', ''),
            'driver': {
                'first_name': safe_get(delivery, 'driver.user.first_name', ''),
                'last_name': safe_get(delivery, 'driver.user.last_name', ''),
                'phone_number': safe_get(delivery, 'driver.phone_number', ''),
                'vehicle_type': safe_get(delivery, 'driver.vehicle_type', ''),
                'license_plate': safe_get(delivery, 'driver.license_plate', ''),
            },
            'distance_km': safe_get(delivery, 'distance_km', None),
            'calculated_price': safe_get(delivery, 'calculated_price', None),
            'special_instructions': safe_get(delivery, 'delivery_notes', ''),
            'rating': safe_get(delivery, 'rating', None),
        }

        context = {
            'delivery': delivery_ctx,
            'generated_at': timezone.now(),
        }

        # Log we are about to generate a delivery PDF with minimal identifiers
        try:
            delivery_id = getattr(delivery, 'id', None)
            tracking_number = getattr(delivery, 'tracking_number', None)
            coords_info = None
            if hasattr(delivery, 'get_coords'):
                try:
                    coords_info = {
                        'pickup': delivery.get_coords('pickup'),
                        'delivery': delivery.get_coords('delivery')
                    }
                except Exception:
                    coords_info = None

            logger.info("generate_delivery_report requested", extra={
                'delivery_id': delivery_id,
                'tracking_number': tracking_number,
                'coords': coords_info,
            })
        except Exception:
            logger.info("generate_delivery_report requested delivery=%s tracking=%s", getattr(delivery, 'id', None), getattr(delivery, 'tracking_number', None))
        
        # Render HTML template and generate PDF. If WeasyPrint or template
        # rendering fails (occasionally due to CSS/font issues), log the full
        # exception and attempt a minimal fallback PDF to avoid a 500.
        try:
            html_string = render_to_string('reports/delivery_report.html', context)

            # Generate PDF
            pdf_file = BytesIO()

            # Configure fonts
            font_config = FontConfiguration()
            # Defensive check: some pydyf versions used by WeasyPrint lack
            # the expected Stream.transform implementation which triggers
            # an AttributeError inside WeasyPrint during rendering. If the
            # runtime pydyf does not expose `transform` on its Stream class,
            # skip WeasyPrint and use the ReportLab fallback to avoid a 500.
            try:
                pydyf_stream_has_transform = hasattr(_pydyf.Stream, 'transform')
                pydyf_version = getattr(_pydyf, '__version__', 'unknown')
            except Exception:
                pydyf_stream_has_transform = False
                pydyf_version = 'unknown'

            if not pydyf_stream_has_transform:
                logger.error("Incompatible pydyf detected for WeasyPrint rendering", extra={
                    'pydyf_version': pydyf_version,
                    'delivery_id': getattr(delivery, 'id', None),
                    'tracking_number': getattr(delivery, 'tracking_number', None),
                })
                # Also capture a Sentry message if available so the ops team
                # can be alerted about the environment mismatch.
                try:
                    import sentry_sdk
                    sentry_sdk.capture_message(f"Incompatible pydyf for WeasyPrint: {pydyf_version} (delivery={getattr(delivery, 'id', None)})")
                except Exception:
                    pass
                # Immediately use ReportLab fallback (avoids repeated WeasyPrint failures)
                if reportlab_canvas is None or REPORTLAB_A4 is None:
                    logger.error("ReportLab not available for immediate fallback — will attempt WeasyPrint anyway")
                else:
                    try:
                        c = reportlab_canvas.Canvas(pdf_file, pagesize=REPORTLAB_A4)
                        width, height = REPORTLAB_A4
                        c.setFont('Helvetica', 14)
                        c.drawString(50, height - 50, f"Delivery {getattr(delivery, 'tracking_number', '')}")
                        c.setFont('Helvetica', 11)
                        c.drawString(50, height - 80, f"Status: {getattr(delivery, 'status', '')}")
                        c.drawString(50, height - 100, f"Merchant: {getattr(getattr(delivery, 'merchant', None), 'business_name', '')}")
                        c.drawString(50, height - 120, f"Recipient: {getattr(delivery, 'recipient_name', '')} - {getattr(delivery, 'recipient_phone', '')}")
                        c.showPage()
                        c.save()
                        pdf_file.seek(0)
                        logger.info("Immediate ReportLab fallback PDF generated due to pydyf incompatibility", extra={'delivery_id': getattr(delivery, 'id', None)})
                        return pdf_file
                    except Exception:
                        logger.exception("Immediate ReportLab fallback failed; will attempt WeasyPrint as last resort")

            HTML(string=html_string).write_pdf(
                pdf_file,
                stylesheets=[CSS(string=PDFReportService._get_delivery_css())],
                font_config=font_config
            )

            pdf_file.seek(0)
            logger.info("generate_delivery_report: PDF generated", extra={'delivery_id': getattr(delivery, 'id', None), 'tracking_number': getattr(delivery, 'tracking_number', None)})
            return pdf_file

        except Exception:
            # Log full traceback for diagnosis
            try:
                logger.exception("Error generating delivery PDF", extra={'delivery_id': getattr(delivery, 'id', None), 'tracking_number': getattr(delivery, 'tracking_number', None)})
            except Exception:
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
                # If fallback fails, try to generate a very small PDF using
                # ReportLab (pure-Python, does not depend on Cairo/Pango).
                logger.exception("Fallback PDF generation also failed — attempting ReportLab fallback")

                if reportlab_canvas is None or REPORTLAB_A4 is None:
                    logger.error("ReportLab not available for fallback — re-raising")
                    raise

                try:
                    pdf_file = BytesIO()
                    c = reportlab_canvas.Canvas(pdf_file, pagesize=REPORTLAB_A4)
                    width, height = REPORTLAB_A4
                    # Simple textual layout — safe and unlikely to fail
                    tracking = getattr(delivery, 'tracking_number', '')
                    status = getattr(delivery, 'status', '')
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

                    c.setFont('Helvetica', 14)
                    c.drawString(50, height - 50, f"Delivery {tracking}")
                    c.setFont('Helvetica', 11)
                    c.drawString(50, height - 80, f"Status: {status}")
                    c.drawString(50, height - 100, f"Merchant: {merchant_name}")
                    c.drawString(50, height - 120, f"Recipient: {getattr(delivery, 'recipient_name', '')} - {getattr(delivery, 'recipient_phone', '')}")
                    c.drawString(50, height - 140, f"Price: {getattr(delivery, 'calculated_price', '')}")
                    c.drawString(50, height - 160, f"Distance (km): {getattr(delivery, 'distance_km', '')}")
                    c.drawString(50, height - 180, f"Driver: {driver_name}")
                    c.showPage()
                    c.save()
                    pdf_file.seek(0)
                    logger.info("ReportLab fallback PDF generated", extra={'delivery_id': getattr(delivery, 'id', None), 'tracking_number': getattr(delivery, 'tracking_number', None)})
                    return pdf_file
                except Exception:
                    logger.exception("ReportLab fallback also failed — re-raising")
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
