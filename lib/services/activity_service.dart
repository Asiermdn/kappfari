import 'package:geolocator/geolocator.dart';
import 'package:kappfari/models/activity_model.dart';
import 'package:kappfari/services/geolocation_service.dart';

class ActivityService {
  final GeolocationService _geolocationService;

  ActivityService(this._geolocationService);

  // Variables para almacenar información en tiempo real
  List<Map<String, double>> route = [];
  DateTime? startTime;
  DateTime? endTime;
  double distance = 0;

  // Inicia la actividad y comienza a rastrear la ubicación
  Future<void> startActivity() async {
    startTime = DateTime.now();
    route.clear();
    distance = 0;

    _geolocationService.getPositionStream().listen((position) {
      // Guarda cada punto GPS
      route.add({'latitude': position.latitude, 'longitude': position.longitude});
      // Calcula la distancia acumulada entre puntos
      if (route.length > 1) {
        distance += Geolocator.distanceBetween(
          route[route.length - 2]['latitude']!,
          route[route.length - 2]['longitude']!,
          route.last['latitude']!,
          route.last['longitude']!,
        );
      }
    });
  }

  // Finaliza la actividad, calcula la duración y la velocidad promedio
  ActivityModel stopActivity(String userId) {
    endTime = DateTime.now();
    final duration = endTime!.difference(startTime!).inSeconds;
    final averageSpeed = (distance / 1000) / (duration / 3600); // km/h

    return ActivityModel(
      id: '', // Generar ID único
      userId: userId,
      startTime: startTime!,
      endTime: endTime!,
      distance: distance / 1000, // Convierte a km
      averageSpeed: averageSpeed,
      duration: duration.toDouble(),
      route: route,
    );
  }
}
