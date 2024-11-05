import 'package:flutter/material.dart';
import 'package:kappfari/services/activity_service.dart';
import 'package:kappfari/services/geolocation_service.dart';
import 'package:geolocator/geolocator.dart';

class ActivityViewModel extends ChangeNotifier {
  final ActivityService _activityService;
  final GeolocationService _geolocationService;

  Position? currentPosition;
  double distance = 0.0;
  double averageSpeed = 0.0;
  double duration = 0.0;

  ActivityViewModel(this._activityService, this._geolocationService) {
    _initializeTracking();
  }

  void _initializeTracking() {
    // Escucha el flujo de posiciones y actualiza currentPosition, distancia y velocidad
    _geolocationService.getPositionStream().listen((position) {
      currentPosition = position;
      if (_activityService.startTime != null) {
        // Actualiza la distancia, velocidad promedio y duración en tiempo real
        distance = _activityService.distance / 1000; // Convertimos a km
        duration = DateTime.now().difference(_activityService.startTime!).inSeconds.toDouble();
        averageSpeed = (distance) / (duration / 3600); // km/h
      }
      notifyListeners();
    });
  }

  Future<void> startActivity(String userId) async {
    await _activityService.startActivity();
    // Reinicia valores para una nueva actividad
    distance = 0.0;
    averageSpeed = 0.0;
    duration = 0.0;
    notifyListeners();
  }

  void stopActivity(String userId) {
    final activity = _activityService.stopActivity(userId);
    // Actualiza los valores finales tras detener la actividad
    distance = activity.distance;
    averageSpeed = activity.averageSpeed;
    duration = activity.duration;
    notifyListeners();
  }
}
