class ExerciseModel {
  final String id;
  final String name;
  final String category; // Ejemplo: "Cardio", "Fuerza", etc.
  final int sets;
  final int reps;
  final String? instructions; // Opcional: Instrucciones para el ejercicio

  ExerciseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.sets,
    required this.reps,
    this.instructions,
  });

  factory ExerciseModel.fromMap(Map<String, dynamic> data) {
    return ExerciseModel(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? 'General',
      sets: data['sets'] ?? 0,
      reps: data['reps'] ?? 0,
      instructions: data['instructions'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'sets': sets,
      'reps': reps,
      'instructions': instructions,
    };
  }
}
