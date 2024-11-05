class NutritionModel {
  final String id;
  final String userId;
  final List<String> meals;  // Lista de comidas para el plan nutricional
  final int calories;
  final int protein;
  final int carbs;
  final int fats;
  final String objective; // Ejemplo: "Bajar de peso", "Mantener peso", etc.

  NutritionModel({
    required this.id,
    required this.userId,
    required this.meals,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.objective,
  });

  factory NutritionModel.fromMap(Map<String, dynamic> data) {
    return NutritionModel(
      id: data['id'],
      userId: data['userId'],
      meals: List<String>.from(data['meals'] ?? []),
      calories: data['calories'] ?? 0,
      protein: data['protein'] ?? 0,
      carbs: data['carbs'] ?? 0,
      fats: data['fats'] ?? 0,
      objective: data['objective'] ?? 'Desconocido',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'meals': meals,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'objective': objective,
    };
  }
}
