# Analytics Dashboard - Flutter Integration Guide

## Overview
This guide covers the complete Analytics Dashboard implementation for the driver app, including charts, heatmap visualization, and real-time statistics.

## Architecture

### Models (Freezed + JSON Serializable)
```
lib/data/models/analytics/
├── stats_summary_model.dart          # Overall statistics
├── timeline_data_model.dart          # Time-series data
├── heatmap_point_model.dart          # GPS coordinates
├── status_distribution_model.dart    # Status breakdown
├── peak_hours_model.dart             # Hourly statistics
└── earnings_breakdown_model.dart     # Revenue details
```

### Repository Layer
```dart
lib/data/repositories/analytics_repository.dart
```

**Methods:**
- `getStatsSummary()` - Overall stats (deliveries, earnings, success rate)
- `getTimeline()` - Time-series data with day/hour granularity
- `getStatusDistribution()` - Count by status
- `getHeatmap()` - GPS points for map visualization
- `getPeakHours()` - Hourly statistics (0-23)
- `getEarningsBreakdown()` - Revenue by type

### Provider Layer
```dart
lib/features/analytics/providers/analytics_provider.dart
```

**Providers:**
- `analyticsRepositoryProvider` - Repository instance
- `dateRangeProvider` - Date range state management
- `analyticsProvider` - Analytics data state

### UI Components

#### Screens
```
lib/features/analytics/screens/
├── analytics_dashboard_screen.dart   # Main dashboard
└── heatmap_screen.dart              # Google Maps heatmap
```

#### Widgets
```
lib/features/analytics/widgets/
├── stats_summary_cards.dart          # 6 summary cards
├── date_range_selector.dart          # Period selector
├── timeline_chart.dart               # Line chart
├── peak_hours_chart.dart             # Bar chart
├── status_distribution_chart.dart    # Pie chart
└── earnings_breakdown_card.dart      # Revenue details
```

## Features

### 1. Date Range Filtering

**Predefined Periods:**
- Today
- Week (last 7 days)
- Month (last 30 days)
- Year (last 365 days)
- Custom (date range picker)

**Usage:**
```dart
// Select predefined period
ref.read(dateRangeProvider.notifier).setPeriod('week');

// Custom date range
ref.read(dateRangeProvider.notifier).setCustomRange(
  DateTime(2024, 1, 1),
  DateTime(2024, 12, 31),
);

// Load analytics
final dateRange = ref.read(dateRangeProvider);
ref.read(analyticsProvider.notifier).refresh(dateRange);
```

### 2. Summary Cards

**Metrics Displayed:**
1. Total Deliveries - Count of all deliveries
2. Completed - Successful deliveries
3. Total Earnings - Sum of all earnings (DA)
4. Success Rate - Percentage of completed deliveries
5. Distance - Total kilometers traveled
6. Average Value - Average earnings per delivery

**Features:**
- Color-coded icons
- Responsive grid layout (2x3)
- Auto-updates on date range change

### 3. Timeline Chart (fl_chart)

**Type:** Line Chart
**Data:** Deliveries count over time
**Granularity:** Day or Hour
**Features:**
- Curved line with gradient fill
- Auto-scaling Y-axis
- Smart X-axis labels (avoids crowding)
- Interactive touch tooltips

**Customization:**
```dart
// Change granularity
await _repository.getTimeline(
  period: 'week',
  granularity: 'hour', // or 'day'
);
```

### 4. Peak Hours Chart (fl_chart)

**Type:** Bar Chart
**Data:** Deliveries per hour (0-23)
**Features:**
- Color-coded bars
- Touch tooltips showing hour and count
- Auto-scaling based on max value
- X-axis shows every 3rd hour

**Use Case:** Identify busiest hours for optimal scheduling

### 5. Status Distribution Chart (fl_chart)

**Type:** Pie Chart
**Data:** Count by status (Pending, Accepted, Picked Up, Delivered, Cancelled)
**Features:**
- Color-coded sections
- Percentage labels on chart
- Legend with counts
- Auto-calculated percentages

**Status Colors:**
- Pending: Orange
- Accepted: Blue
- Picked Up: Indigo
- Delivered: Green
- Cancelled: Red

### 6. Earnings Breakdown Card

**Revenue Types:**
1. Delivery Earnings - Base delivery fees
2. Bonus Earnings - Performance bonuses
3. Tip Earnings - Customer tips
4. Adjustments - Manual adjustments

**Features:**
- Icon per earning type
- Itemized list with dividers
- Total earnings highlighted
- Currency formatted (DA)

### 7. Heatmap Visualization

**Technology:** Google Maps Flutter
**Data:** GPS coordinates with weights

**Features:**
- Circle-based heatmap effect
- Color intensity based on delivery count
- Radius scaling (50-200m)
- Opacity gradient (0.3-0.7)
- Markers for high-density zones (top 20%)
- Auto-fit to bounds
- Legend and stats overlay

**Heatmap Algorithm:**
```dart
// Normalized weight determines color intensity
final normalizedWeight = point.weight / maxWeight;
final radius = 50.0 + (normalizedWeight * 150.0);
final opacity = 0.3 + (normalizedWeight * 0.4);
```

**Controls:**
- Fit to bounds button
- My location button
- Zoom/pan controls

## Navigation

### Access Analytics Dashboard

**Option 1: From Main Navigation**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AnalyticsDashboardScreen(),
  ),
);
```

**Option 2: Add to Bottom Navigation**
```dart
// In main navigation screen
BottomNavigationBarItem(
  icon: Icon(Icons.analytics),
  label: 'Analytics',
),
```

### Access Heatmap

**From Dashboard:**
- Tap map icon in AppBar
- Navigates to HeatmapScreen with current heatmap data

## Data Loading

### Initial Load
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadAnalytics();
  });
}

void _loadAnalytics() {
  final dateRange = ref.read(dateRangeProvider);
  ref.read(analyticsProvider.notifier).refresh(dateRange);
}
```

### Pull-to-Refresh
```dart
Future<void> _handleRefresh() async {
  final dateRange = ref.read(dateRangeProvider);
  await ref.read(analyticsProvider.notifier).refresh(dateRange);
}

// In build method
RefreshIndicator(
  onRefresh: _handleRefresh,
  child: SingleChildScrollView(...),
)
```

### Parallel Loading
All analytics endpoints are called in parallel for performance:
```dart
final results = await Future.wait([
  _repository.getStatsSummary(...),
  _repository.getTimeline(...),
  _repository.getStatusDistribution(...),
  _repository.getHeatmap(...),
  _repository.getPeakHours(...),
  _repository.getEarningsBreakdown(...),
]);
```

## State Management

### Analytics State
```dart
class AnalyticsState {
  final bool isLoading;
  final String? error;
  final StatsSummaryModel? summary;
  final TimelineResponseModel? timeline;
  final StatusDistributionResponseModel? statusDistribution;
  final HeatmapResponseModel? heatmap;
  final PeakHoursResponseModel? peakHours;
  final EarningsBreakdownModel? earningsBreakdown;
}
```

### State Lifecycle
1. **Initial State:** isLoading = false, all data = null
2. **Loading:** isLoading = true, existing data preserved
3. **Success:** isLoading = false, data populated, error = null
4. **Error:** isLoading = false, error set, existing data preserved

### Watching State
```dart
final analyticsState = ref.watch(analyticsProvider);

// Check loading
if (analyticsState.isLoading) { ... }

// Check error
if (analyticsState.error != null) { ... }

// Use data
if (analyticsState.summary != null) {
  StatsSummaryCards(summary: analyticsState.summary!)
}
```

## Error Handling

### Repository Level
```dart
String _handleError(DioException e) {
  if (e.response?.statusCode == 404) {
    return 'Driver profile not found';
  } else if (e.response?.statusCode == 400) {
    return e.response?.data['error'] ?? 'Invalid request';
  } else if (e.response?.statusCode == 401) {
    return 'Authentication required';
  }
  return 'Failed to load analytics: ${e.message}';
}
```

### UI Level
```dart
analyticsState.error != null && analyticsState.summary == null
  ? Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red),
          Text(analyticsState.error!),
          ElevatedButton(
            onPressed: _loadAnalytics,
            child: const Text('Retry'),
          ),
        ],
      ),
    )
  : // Normal UI
```

## Performance Optimizations

### Backend
- DB-level aggregations (no in-memory processing)
- Indexed queries on driver, status, dates
- Heatmap point limit (default 500)
- Efficient grouping (TruncDate, TruncHour)

### Frontend
- Parallel API calls (Future.wait)
- Lazy loading (only render if data exists)
- Optimistic UI (preserve data during refresh)
- Chart memoization (fl_chart built-in)

### Heatmap
- Circle-based rendering (faster than polygons)
- Limited markers (top 20% only)
- Auto-fit bounds after map load
- Dispose controller on exit

## Testing

### Test Analytics Loading
```bash
# Run backend server
cd backend
python manage.py runserver

# Ensure driver has deliveries
# Access dashboard from app
```

### Test Date Filters
1. Tap "Today" - should show today's data
2. Tap "Week" - should show last 7 days
3. Tap "Custom" - date picker appears
4. Select range - data updates

### Test Charts
1. Timeline chart - verify line follows data
2. Peak hours - bars show correct heights
3. Status distribution - percentages add to 100%
4. Earnings - total matches sum of parts

### Test Heatmap
1. Tap map icon in AppBar
2. Verify circles appear at delivery locations
3. Tap "Fit to bounds" - map zooms to show all points
4. Verify legend and stats card

## Common Issues

### Issue: "Driver profile not found"
**Cause:** Current user doesn't have a driver profile
**Solution:** Create driver profile via admin or API

### Issue: Charts not rendering
**Cause:** Data is empty or null
**Solution:** Check backend returns data, verify date range includes deliveries

### Issue: Heatmap blank
**Cause:** No GPS coordinates in deliveries
**Solution:** Ensure deliveries have pickup/dropoff coordinates

### Issue: Build runner errors
**Cause:** Freezed code not generated
**Solution:**
```bash
cd driver_app
dart run build_runner build --delete-conflicting-outputs
```

## API Endpoints Used

All endpoints require JWT authentication and driver profile.

**Base URL:** `/api/v1/deliveries/analytics/`

1. `GET /summary/` - Stats summary
2. `GET /timeline/` - Time-series data
3. `GET /status_distribution/` - Status counts
4. `GET /heatmap/` - GPS points
5. `GET /peak_hours/` - Hourly stats
6. `GET /earnings_breakdown/` - Revenue details

**Common Query Parameters:**
- `period` - 'today', 'week', 'month', 'year', 'custom'
- `start_date` - YYYY-MM-DD (required if period=custom)
- `end_date` - YYYY-MM-DD (required if period=custom)
- `granularity` - 'day' or 'hour' (timeline only)
- `max_points` - int (heatmap only, default 500)

## Next Steps

1. **Add Export to PDF**
   - Generate PDF reports from analytics data
   - Download and share functionality

2. **Add Real-time Updates**
   - WebSocket integration
   - Auto-refresh every N minutes
   - Live delivery counter

3. **Add Comparison Mode**
   - Compare two date ranges
   - Show growth percentages
   - Trend indicators

4. **Add Goals/Targets**
   - Set monthly earnings targets
   - Track progress bars
   - Motivational badges

## Dependencies

Required packages (already in pubspec.yaml):
```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  freezed_annotation: ^2.5.8
  json_annotation: ^4.9.0
  dio: ^5.7.0
  fl_chart: ^1.1.1
  google_maps_flutter: ^2.5.0
  intl: ^0.19.0

dev_dependencies:
  freezed: ^2.5.8
  build_runner: ^2.4.15
  json_serializable: ^6.9.5
```

## File Summary

**Total Files Created:** 17

**Models:** 6 files
- stats_summary_model.dart
- timeline_data_model.dart
- heatmap_point_model.dart
- status_distribution_model.dart
- peak_hours_model.dart
- earnings_breakdown_model.dart

**Repository:** 1 file
- analytics_repository.dart

**Provider:** 1 file
- analytics_provider.dart

**Screens:** 2 files
- analytics_dashboard_screen.dart
- heatmap_screen.dart

**Widgets:** 5 files
- stats_summary_cards.dart
- date_range_selector.dart
- timeline_chart.dart
- peak_hours_chart.dart
- status_distribution_chart.dart
- earnings_breakdown_card.dart

**Documentation:** 1 file (this file)

---

**Status:** ✅ Complete and ready for integration
**Last Updated:** November 6, 2025
