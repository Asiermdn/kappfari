import '../models/nutrition_model.dart';
import 'database_service.dart';

class NutritionService {
  final DatabaseService _dbService = DatabaseService();

  Future<NutritionModel> generatePlan(String userId, String objective, int dailyCalories) async {
    // Logica básica de ejemplo para un plan nutricional
    List<String> meals = ["Desayuno", "Almuerzo", "Cena"];
    NutritionModel nutritionPlan = NutritionModel(
      id: userId,
      userId: userId,
      meals: meals,
      calories: dailyCalories,
      protein: (dailyCalories * 0.3 / 4).round(),
      carbs: (dailyCalories * 0.4 / 4).round(),
      fats: (dailyCalories * 0.3 / 9).round(),
      objective: objective,
    );

    // Guardar plan en la base de datos
    await _dbService.saveData("nutrition_plans", userId, nutritionPlan.toMap());
    return nutritionPlan;
  }

  Future<NutritionModel?> getPlan(String userId) async {
    var data = await _dbService.getData("nutrition_plans", userId);
    return data != null ? NutritionModel.fromMap(data) : null;
  }
}
