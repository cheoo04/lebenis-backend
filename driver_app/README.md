# driver_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Navigation Fallback (Driver App)

The driver app attempts to open external navigation apps (Google Maps, Waze) first.
If no external navigation app is available on the device, the app falls back to an
internal navigation screen powered by the backend routing API and `flutter_map` (OSM).

Key files:
- `lib/core/utils/navigation_utils.dart` — builds and launches external URLs (Google Maps / Waze).
- `lib/features/deliveries/presentation/screens/delivery_navigation_screen.dart` — internal fallback screen.
- `lib/features/deliveries/presentation/widgets/delivery_map.dart` — map widget using `flutter_map`.
- `lib/core/services/routing_service.dart` — client for the backend `/api/v1/locations/delivery-route/` endpoint that returns a `DeliveryRouteResult`.

Dependencies used for navigation fallback:
- `url_launcher` — for opening external apps (Google Maps / Waze).
- `flutter_map` and `latlong2` — for rendering OSM maps and polylines.

How it works:
1. By default the app opens the internal `/delivery-map` screen to show the route and map.
2. An optional utility `openNavigationApp(...)` exists to explicitly open external apps (Google Maps / Waze) for users who prefer that behavior.
3. The internal screen requests the route from the backend and displays:
	- total distance and duration,
	- a polyline on the map,
	- per-leg distance/duration breakdown when available.

How to test:
- On a device with Google Maps installed: if a caller explicitly uses `openNavigationApp(...)`, it will launch the external app.
- On an emulator without Google Maps, the app uses the internal map and route by default.

Notes:
- Ensure backend routing endpoints are reachable in your environment (OSRM/ORS on server side).
- The fallback keeps the app usable even on devices without Google services.
