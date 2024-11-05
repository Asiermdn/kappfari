class RaceModel {
  final String id;
  final String name;
  final String location;
  final DateTime date;
  final double distance; // Distancia en kilómetros
  final String? description;

  RaceModel({
    required this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.distance,
    this.description,
  });

  // Getter para verificar si la carrera ya ha pasado
  bool get isPast => date.isBefore(DateTime.now());

  // Constructor desde un Map de datos, útil para parsear JSON
  factory RaceModel.fromMap(Map<String, dynamic> data) {
    return RaceModel(
      id: data['id'] ?? '',
      name: data['name'] ?? 'Carrera',
      location: data['location'] ?? 'Desconocida',
      date: DateTime.parse(data['date']),
      distance: (data['distance'] as num).toDouble(), // Asegura que sea tipo double
      description: data['description'],
    );
  }

  // Convierte un objeto RaceModel a un Map, útil para serialización o almacenamiento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'date': date.toIso8601String(), // Formato de fecha ISO 8601
      'distance': distance,
      'description': description,
    };
  }
}
