import 'package:url_launcher/url_launcher.dart';

Future<void> openNavigationApp({required double latitude, required double longitude, String? label}) async {
  final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude${label != null ? '&destination_place_id=$label' : ''}';
  final wazeUrl = 'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes';

  if (await canLaunch(googleMapsUrl)) {
    await launch(googleMapsUrl);
  } else if (await canLaunch(wazeUrl)) {
    await launch(wazeUrl);
  } else {
    throw 'Aucune application de navigation trouvée';
  }
}
