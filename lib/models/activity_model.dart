class ActivityModel {
  final String id;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final double distance; // en kilómetros
  final double averageSpeed; // en km/h
  final double duration; // en segundos
  final List<Map<String, double>> route; // lista de puntos GPS {latitud, longitud}

  ActivityModel({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.endTime,
    required this.distance,
    required this.averageSpeed,
    required this.duration,
    required this.route,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'distance': distance,
      'averageSpeed': averageSpeed,
      'duration': duration,
      'route': route,
    };
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'],
      userId: map['userId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      distance: map['distance'],
      averageSpeed: map['averageSpeed'],
      duration: map['duration'],
      route: List<Map<String, double>>.from(map['route']),
    );
  }
}
