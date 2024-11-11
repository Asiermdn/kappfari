import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/nutrition_plan_model.dart';

class NutritionPlanService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _apiKey= 'AIzaSyBXYqUKipUHkitLAGjmxZr_yJwB0IF4fws'; // Tu API key de Google
  static const String _apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

 NutritionPlanService(); 

  // Obtener el plan de nutrición del usuario
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

  // Obtener todos los planes
  Future<List<NutritionPlan>> getAllNutritionPlans() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = 
          await _db.collection('nutritionPlans').get();
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

  // Eliminar plan
  Future<void> deleteUserPlan(String userId) async {
    try {
      await _db.collection('nutritionPlans').doc(userId).delete();
    } catch (e) {
      print("Error al eliminar el plan nutricional: ${e.toString()}");
      throw Exception("Error al eliminar el plan nutricional: ${e.toString()}");
    }
  }

  // Crear nuevo plan usando IA
  Future<void> createNutritionPlan(String userId, Map<String, dynamic> userData) async {
    try {
      // Generar el plan usando IA
      final aiResponse = await _generateAIPlan(userData);
      
      // Convertir la respuesta de la IA a nuestro modelo
      final nutritionPlan = await _convertAIResponseToNutritionPlan(
        userId: userId,
        aiResponse: aiResponse,
        goal: userData['goal'],
      );

      // Guardar en Firestore
      await _db.collection('nutritionPlans')
          .doc(userId)
          .set(nutritionPlan.toMap());

    } catch (e) {
      print("Error al crear el plan nutricional: ${e.toString()}");
      throw Exception("Error al crear el plan nutricional: ${e.toString()}");
    }
  }

  Future<String> _generateAIPlan(Map<String, dynamic> userData) async {
    try {
      final prompt = '''
        Actúa como un nutricionista experto y genera un plan nutricional detallado para una persona con las siguientes características:
        - Peso: ${userData['weight']} kg
        - Altura: ${userData['height']} cm
        - Edad: ${userData['age']} años
        - Objetivo: ${userData['goal']}
        - Duración del plan: ${userData['days']} días

        Por favor, genera un plan que incluya:
        1. Calorías diarias recomendadas
        2. 3 comidas principales por día (desayuno, almuerzo y cena)
        3. Lista detallada de comidas para cada día
        4. Considera el objetivo específico al generar las comidas

        IMPORTANTE: Responde en el siguiente formato JSON:
        {
          "calories": número_de_calorías,
          "days": {
            "1": ["desayuno_día_1", "almuerzo_día_1", "cena_día_1"],
            "2": ["desayuno_día_2", "almuerzo_día_2", "cena_día_2"],
            ...
          }
        }
      ''';

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [{
            'parts': [{
              'text': prompt
            }]
          }],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        print('Error de la API: ${response.body}');
        throw Exception('Error al generar el plan nutricional');
      }
    } catch (e) {
      print('Error detallado: $e');
      throw Exception('Error en la generación del plan: $e');
    }
  }

  Future<NutritionPlan> _convertAIResponseToNutritionPlan({
    required String userId,
    required String aiResponse,
    required String goal,
  }) async {
    try {
      // Eliminar cualquier texto antes o después del JSON
      final jsonStr = aiResponse.substring(
        aiResponse.indexOf('{'),
        aiResponse.lastIndexOf('}') + 1
      );
      
      final Map<String, dynamic> aiData = jsonDecode(jsonStr);
      
      // Convertir el formato de días al formato esperado por NutritionPlan
      final Map<int, List<String>> dailyMeals = {};
      
      (aiData['days'] as Map<String, dynamic>).forEach((day, meals) {
        dailyMeals[int.parse(day)] = List<String>.from(meals);
      });

      // Crear y retornar el plan de nutrición
      return NutritionPlan(
        id: userId,
        goal: goal,
        description: 'Plan nutricional personalizado - ${aiData['calories']} calorías diarias',
        dailyMeals: dailyMeals,
      );

    } catch (e) {
      print('Error al convertir la respuesta de la IA: $e');
      throw Exception('Error al procesar la respuesta de la IA');
    }
  }
}