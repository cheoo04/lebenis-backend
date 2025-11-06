# PDF Reports System - Complete Guide

## Overview
This guide covers the complete PDF Reports implementation for generating, downloading, and sharing analytics reports.

## Architecture

### Backend Components

#### 1. PDF Service (`apps/deliveries/pdf_service.py`)
```python
PDFReportService
├── generate_analytics_report()  # Main PDF generation
├── generate_filename()          # Standardized filenames
└── _get_css()                   # PDF styling
```

**Features:**
- WeasyPrint for HTML to PDF conversion
- Professional styling with CSS
- Comprehensive analytics data inclusion
- Font configuration support

**Generated Report Includes:**
1. Driver information header
2. Summary statistics (6 metrics)
3. Earnings breakdown
4. Status distribution table
5. Distance distribution table
6. Peak hours (top 10)
7. Top delivery locations (top 10)
8. Daily timeline table

#### 2. HTML Template (`templates/reports/analytics_report.html`)
**Structure:**
- Header with title and branding
- Driver info section (name, phone, email, period)
- Stats grid (3x2 cards)
- Earnings breakdown card
- Multiple data tables
- Footer with branding

**Styling:**
- A4 page format with 1.5cm margins
- Color-coded badges (success, warning, danger, info)
- Responsive grid layouts
- Professional typography

#### 3. API Views (`apps/deliveries/pdf_views.py`)

**Endpoints:**

**POST** `/api/v1/deliveries/reports/analytics-pdf/`
- Generate custom date range PDF
- Request body: `{period, start_date, end_date}`
- Returns: PDF file download

**GET** `/api/v1/deliveries/reports/test-pdf/`
- Generate test PDF (last 7 days)
- No parameters required
- Returns: PDF file download

**Security:**
- `IsAuthenticated` permission
- Driver profile required
- Date range validation (max 365 days)

### Frontend Components

#### 1. PDF Service (`core/services/pdf_report_service.dart`)

**Methods:**
```dart
downloadAnalyticsPDF()    // Custom period
downloadTestPDF()         // Test report
sharePDF()               // Share via system
openPDF()                // Open in viewer
getDownloadedPDFs()      // List saved PDFs
deletePDF()              // Delete single PDF
clearAllPDFs()           // Clear all PDFs
```

**Features:**
- Progress tracking callbacks
- Platform-specific storage
- Error handling
- File management

**Storage Locations:**
- **Android:** `/data/user/0/com.example/app_flutter/PDFs/`
- **iOS:** `Documents/PDFs/`
- **Other:** Temporary directory

#### 2. Provider (`features/analytics/providers/pdf_report_provider.dart`)

**State:**
```dart
class PDFDownloadState {
  final bool isDownloading;
  final double progress;      // 0.0 to 1.0
  final String? error;
  final String? filePath;     // Downloaded file path
}
```

**Provider Methods:**
- `downloadReport()` - Custom date range
- `downloadTestReport()` - Test report
- `shareReport()` - Share PDF
- `openReport()` - Open PDF
- `resetState()` - Clear state

#### 3. UI Screen (`features/analytics/screens/pdf_reports_screen.dart`)

**Features:**
- Current date range display
- Generate button
- Progress indicator with percentage
- Success card with Open/Share buttons
- Error card with retry
- Test report button
- Info card with instructions

**User Flow:**
1. View current date range (from analytics dashboard)
2. Tap "Generate PDF Report"
3. See progress bar (0-100%)
4. On success: Open or Share
5. On error: View message and retry

## Installation

### Backend

**1. Install Dependencies:**
```bash
cd backend
pip install WeasyPrint==62.3 reportlab==4.2.5
```

**2. System Requirements (Linux):**
```bash
# WeasyPrint dependencies
sudo apt-get install python3-dev python3-pip python3-setuptools python3-wheel python3-cffi libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf2.0-0 libffi-dev shared-mime-info
```

**3. Run Migrations:**
```bash
python manage.py migrate
```

### Frontend

**1. Install Dependencies:**
```bash
cd driver_app
flutter pub get
```

**Packages added:**
- `share_plus: ^10.1.3` - Share files
- `open_file: ^3.5.10` - Open PDF viewer

**2. Platform Configuration:**

**Android (`android/app/src/main/AndroidManifest.xml`):**
```xml
<!-- Add before </application> -->
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.fileprovider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

**Create `android/app/src/main/res/xml/file_paths.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<paths>
    <files-path name="files" path="." />
    <external-path name="external_files" path="." />
</paths>
```

**iOS (`ios/Runner/Info.plist`):**
```xml
<!-- Add before </dict> -->
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
```

## Usage

### Backend API

**Generate Custom PDF:**
```bash
curl -X POST http://localhost:8000/api/v1/deliveries/reports/analytics-pdf/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "period": "custom",
    "start_date": "2024-01-01",
    "end_date": "2024-12-31"
  }' \
  --output report.pdf
```

**Generate Test PDF:**
```bash
curl -X GET http://localhost:8000/api/v1/deliveries/reports/test-pdf/ \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  --output test_report.pdf
```

**Response:**
- **Success:** PDF file download (application/pdf)
- **Headers:** `Content-Disposition: attachment; filename="..."`
- **Error 404:** Driver profile not found
- **Error 400:** Invalid date range
- **Error 500:** PDF generation failed

### Flutter App

**1. Access from Analytics Dashboard:**
```dart
// Dashboard AppBar has PDF icon
IconButton(
  icon: Icon(Icons.picture_as_pdf),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFReportsScreen(),
      ),
    );
  },
)
```

**2. Generate Report:**
```dart
// Using current date range from analytics
ref.read(pdfDownloadProvider.notifier).downloadReport(
  period: 'week',
  startDate: '2024-01-01',  // optional
  endDate: '2024-12-31',    // optional
);
```

**3. Monitor Progress:**
```dart
final pdfState = ref.watch(pdfDownloadProvider);

if (pdfState.isDownloading) {
  print('Progress: ${(pdfState.progress * 100).toStringAsFixed(0)}%');
}

if (pdfState.filePath != null) {
  print('PDF saved to: ${pdfState.filePath}');
}

if (pdfState.error != null) {
  print('Error: ${pdfState.error}');
}
```

**4. Open PDF:**
```dart
// Programmatically
ref.read(pdfDownloadProvider.notifier).openReport(filePath);

// Or from UI button
ElevatedButton(
  onPressed: () => _openPDF(pdfState.filePath!),
  child: Text('Open'),
)
```

**5. Share PDF:**
```dart
// Programmatically
ref.read(pdfDownloadProvider.notifier).shareReport(filePath);

// Or from UI button
ElevatedButton(
  onPressed: () => _sharePDF(pdfState.filePath!),
  child: Text('Share'),
)
```

## PDF Report Content

### Page 1: Summary
- **Header:** Report title, driver name
- **Driver Info:** Name, phone, email, period, generation date
- **Summary Stats:** 6 key metrics in grid
- **Earnings Breakdown:** 4 earning types + total

### Page 2-3: Detailed Analytics
- **Status Distribution:** Count and percentage per status
- **Distance Distribution:** Deliveries by distance range
- **Peak Hours:** Top 10 busiest hours
- **Top Locations:** Top 10 communes with delivery counts

### Page N: Timeline
- **Daily Timeline:** Date, deliveries, earnings per day

### Footer
- Branding (Lebenis Delivery System)
- Copyright notice
- Support contact

## Customization

### Backend PDF Styling

**Modify CSS in `pdf_service.py`:**
```python
@staticmethod
def _get_css():
    return """
    /* Change primary color */
    .header h1 { color: #YOUR_COLOR; }
    
    /* Adjust page margins */
    @page { margin: 2cm; }
    
    /* Custom card styling */
    .stat-card { background: #f0f0f0; }
    """
```

### Frontend Date Formats

**Modify in `pdf_reports_screen.dart`:**
```dart
String _formatDate(DateTime date) {
  // Change format here
  return '${date.day}/${date.month}/${date.year}';
}
```

## Error Handling

### Backend Errors

| Error Code | Message | Solution |
|------------|---------|----------|
| 404 | Driver profile not found | Ensure user has driver profile |
| 400 | Invalid date range | Check start_date < end_date |
| 400 | Date range > 365 days | Reduce date range |
| 500 | PDF generation failed | Check WeasyPrint installation |

### Frontend Errors

**Common Issues:**

**1. "Failed to download PDF"**
- Check network connection
- Verify JWT token is valid
- Ensure backend is running

**2. "Failed to open PDF"**
- Check file exists
- Verify PDF viewer installed
- Check file permissions

**3. "Failed to share PDF"**
- Check file exists
- Verify share_plus configuration
- Check platform permissions

## Testing

### Backend Tests

**Test PDF Generation:**
```bash
# Start server
python manage.py runserver

# Access test endpoint
curl http://localhost:8000/api/v1/deliveries/reports/test-pdf/ \
  -H "Authorization: Bearer TOKEN" \
  -o test.pdf

# Verify PDF opens
xdg-open test.pdf  # Linux
open test.pdf      # macOS
```

### Frontend Tests

**1. Test Download:**
- Open analytics dashboard
- Tap PDF icon
- Tap "Generate Test Report"
- Verify progress bar shows
- Verify success card appears

**2. Test Open:**
- After successful download
- Tap "Open" button
- Verify PDF opens in viewer

**3. Test Share:**
- After successful download
- Tap "Share" button
- Verify share sheet appears
- Share via email/messaging

**4. Test Error Handling:**
- Turn off WiFi
- Try to generate report
- Verify error message shows
- Turn on WiFi
- Tap "Dismiss"
- Retry generation

## Performance

### Backend Optimization
- Database queries use select_related
- Aggregations done at DB level
- HTML template cached by Django
- PDF generated on-demand (no storage)

### Frontend Optimization
- Progress callbacks prevent UI freeze
- Files saved asynchronously
- State management prevents rebuilds
- Platform-specific storage optimized

### Recommended Limits
- Max date range: 365 days
- Max report size: ~2MB (typical)
- Max deliveries: ~10,000 per report

## Troubleshooting

### WeasyPrint Installation Issues

**Ubuntu/Debian:**
```bash
sudo apt-get install libpango-1.0-0 libpangocairo-1.0-0
pip install --upgrade WeasyPrint
```

**macOS:**
```bash
brew install cairo pango gdk-pixbuf libffi
pip install WeasyPrint
```

**Windows:**
```bash
# Use GTK+ installer
# Download from: https://github.com/tschoonj/GTK-for-Windows-Runtime-Environment-Installer
pip install WeasyPrint
```

### File Permission Issues (Android)

**Add to `AndroidManifest.xml`:**
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

**Request at runtime:**
```dart
import 'package:permission_handler/permission_handler.dart';

final status = await Permission.storage.request();
if (status.isGranted) {
  // Proceed with download
}
```

## Next Steps

**Potential Enhancements:**
1. **Email Reports** - Send PDF via email directly
2. **Scheduled Reports** - Auto-generate weekly/monthly
3. **Custom Templates** - Multiple report styles
4. **Charts in PDF** - Include visual charts
5. **Batch Download** - Multiple periods at once
6. **Cloud Storage** - Save to Google Drive/Dropbox

## API Reference

**Base URL:** `/api/v1/deliveries/reports/`

### POST /analytics-pdf/

**Request:**
```json
{
  "period": "week",         // required
  "start_date": "2024-01-01",  // optional
  "end_date": "2024-12-31"     // optional
}
```

**Response:** PDF file download

**Headers:**
- `Authorization: Bearer JWT_TOKEN`
- `Content-Type: application/json`

### GET /test-pdf/

**Request:** None (uses last 7 days)

**Response:** PDF file download

**Headers:**
- `Authorization: Bearer JWT_TOKEN`

---

**Status:** ✅ Complete and ready for production
**Last Updated:** November 6, 2025
**Dependencies:** WeasyPrint 62.3, share_plus 10.1.3, open_file 3.5.10
