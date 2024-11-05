import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:kappfari/viewmodels/activity_viewmodel.dart';

class ActivityView extends StatefulWidget {
  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final ScreenshotController screenshotController = ScreenshotController();
  Marker? currentMarker;
  List<LatLng> routeCoordinates = [];

  @override
  Widget build(BuildContext context) {
    final activityViewModel = Provider.of<ActivityViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Registrar Actividad")),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child: FlutterMap(
                options: MapOptions(
                  center: activityViewModel.currentPosition != null
                      ? LatLng(
                          activityViewModel.currentPosition!.latitude,
                          activityViewModel.currentPosition!.longitude,
                        )
                      : LatLng(0.0, 0.0),
                  zoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=koSV1RpirFBbtaAGnNrn",
                    subdomains: ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.kappfari',
                  ),
                  MarkerLayer(
                    markers: currentMarker != null ? [currentMarker!] : [],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routeCoordinates,
                        strokeWidth: 4.0,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Distancia: ${activityViewModel.distance.toStringAsFixed(2)} km"),
                Text("Velocidad Promedio: ${activityViewModel.averageSpeed.toStringAsFixed(2)} km/h"),
                Text("Duración: ${activityViewModel.duration.toStringAsFixed(0)} s"),
                ElevatedButton(
                  onPressed: () => activityViewModel.startActivity("userId"),
                  child: Text("Iniciar Actividad"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    activityViewModel.stopActivity("userId");
                    await _captureRouteImage();
                  },
                  child: Text("Detener Actividad"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _updateMarker(Position? position) {
    if (position == null) return;

    setState(() {
      final latLng = LatLng(position.latitude, position.longitude);
      currentMarker = Marker(
        point: latLng,
        builder: (ctx) => Icon(Icons.location_pin, color: Colors.red, size: 40),
      );
      routeCoordinates.add(latLng);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final activityViewModel = Provider.of<ActivityViewModel>(context, listen: false);

    // Escuchar cambios en la posición y actualizar el marcador
    activityViewModel.addListener(() {
      _updateMarker(activityViewModel.currentPosition);
    });
  }

  Future<void> _captureRouteImage() async {
    final image = await screenshotController.capture();
    if (image != null) {
      // Aquí puedes guardar la imagen en el almacenamiento local o subirla a Firebase
      print("Ruta capturada como imagen");
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
