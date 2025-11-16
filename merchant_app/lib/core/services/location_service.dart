import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('La localisation est désactivée.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permission localisation refusée.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permission localisation refusée définitivement.');
    }
    return await Geolocator.getCurrentPosition();
  }
}
