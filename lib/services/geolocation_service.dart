import 'package:geolocator/geolocator.dart';

class GeolocationService {
  Future<void> initialize() async {
    await Geolocator.requestPermission();
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10),
    );
  }
}
