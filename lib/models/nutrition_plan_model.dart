class NutritionPlan {
  final String id;
  final String goal; // Ejemplo: "Bajar de Peso", "Subir de Peso"
  final String? description;
  final Map<int, List<String>> dailyMeals; // Clave: día, Valor: lista de comidas

  NutritionPlan({
    required this.id,
    required this.goal,
    this.description,
    required this.dailyMeals,
  });

  // Método para crear una instancia de NutritionPlan a partir de un Map (Firestore)
  factory NutritionPlan.fromMap(Map<String, dynamic> data) {
    // Convertir el Map de comidas a un Map con int y List<String>
    final Map<int, List<String>> meals = {};
    data['dailyMeals'].forEach((key, value) {
      meals[int.parse(key)] = List<String>.from(value);
    });

    return NutritionPlan(
      id: data['id'],
      goal: data['goal'],
      description: data['description'],
      dailyMeals: meals,
    );
  }

  // Método para convertir la instancia a un Map (Firestore)
  Map<String, dynamic> toMap() {
    // Convertir el Map de comidas a un Map con String y List<dynamic>
    final Map<String, dynamic> meals = {};
    dailyMeals.forEach((key, value) {
      meals[key.toString()] = value; // Convertir la clave a String
    });

    return {
      'id': id,
      'goal': goal,
      'description': description,
      'dailyMeals': meals,
    };
  }
}
