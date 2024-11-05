import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nutrition_plan_model.dart';

class NutritionPlanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener el plan de nutrición del usuario desde Firestore
  Future<NutritionPlan?> getUserPlan(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _db
          .collection('nutritionPlans')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return NutritionPlan.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print("Error al obtener el plan nutricional: ${e.toString()}");
      return null;
    }
  }

  // Obtener todos los planes de nutrición
  Future<List<NutritionPlan>> getAllNutritionPlans() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _db.collection('nutritionPlans').get();
      List<NutritionPlan> plans = [];

      for (var doc in querySnapshot.docs) {
        plans.add(NutritionPlan.fromMap(doc.data()));
      }

      return plans;
    } catch (e) {
      print("Error al obtener todos los planes nutricionales: ${e.toString()}");
      return [];
    }
  }

  // Eliminar el plan de nutrición del usuario en Firestore
  Future<void> deleteUserPlan(String userId) async {
    try {
      await _db.collection('nutritionPlans').doc(userId).delete();
    } catch (e) {
      print("Error al eliminar el plan nutricional: ${e.toString()}");
    }
  }

  // Crear un nuevo plan nutricional para el usuario
  Future<void> createNutritionPlan(String userId, Map<String, dynamic> inputData) async {
    try {
      // Aquí iría la llamada a la API de IA para generar el plan
      Map<String, dynamic> generatedPlan = await _callAIService(inputData);

      // Crear una instancia de NutritionPlan para estructurar los datos
      NutritionPlan nutritionPlan = NutritionPlan(
        id: userId,
        goal: generatedPlan['goal'],
        description: null, // Puedes agregar una descripción si lo deseas
        dailyMeals: _formatMealPlan(generatedPlan),
      );

      // Guardar el plan generado en Firestore, usando el userId como ID del documento
      await _db.collection('nutritionPlans').doc(userId).set(nutritionPlan.toMap());
    } catch (e) {
      print("Error al crear el plan nutricional: ${e.toString()}");
    }
  }

  // Simulación de llamada a un servicio de IA para generar el plan de nutrición
  Future<Map<String, dynamic>> _callAIService(Map<String, dynamic> inputData) async {
    // Lógica simulada o llamada real a API de IA
    await Future.delayed(const Duration(seconds: 2)); // Simula tiempo de espera de la IA

    // Resultado simulado de la IA
    return {
      'goal': inputData['goal'],
      'days': inputData['days'],
      'dailyCalories': 2000,
      'mealPlan': [
        {'meal': 'Desayuno', 'description': 'Avena con frutas y yogurt'},
        {'meal': 'Almuerzo', 'description': 'Pechuga de pollo con verduras'},
        {'meal': 'Cena', 'description': 'Sopa de verduras y pescado'},
      ],
    };
  }

  // Formatear el plan de comidas al nuevo formato de dailyMeals
  Map<int, List<String>> _formatMealPlan(Map<String, dynamic> generatedPlan) {
    final Map<int, List<String>> meals = {};
    final List<dynamic> mealPlan = generatedPlan['mealPlan'];

    for (int day = 1; day <= generatedPlan['days']; day++) {
      meals[day] = mealPlan.map<String>((meal) => meal['description'] as String).toList();
    }

    return meals;
  }
}
