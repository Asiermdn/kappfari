import 'package:flutter/material.dart';
import '../models/conditioning_plan_model.dart';
import '../services/conditioning_plan_service.dart';

class ConditioningViewModel extends ChangeNotifier {
  final ConditioningPlanService _planService = ConditioningPlanService();
  ConditioningPlan? userPlan;

  // Verificar si ya existe un plan nutricional para el usuario
  Future<bool> checkExistingPlan(String userId) async {
    try {
      userPlan = await _planService.getUserPlan(userId);
      return userPlan != null;
    } catch (e) {
      debugPrint('Error al verificar el plan existente: $e');
      return false;
    }
  }

  // Eliminar un plan nutricional existente
  Future<void> deleteExistingPlan(String userId) async {
    try {
      await _planService.deleteUserPlan(userId);
      userPlan = null; // Limpiar el plan en el ViewModel
      notifyListeners(); // Notificar que se ha eliminado el plan
    } catch (e) {
      debugPrint('Error al eliminar el plan: $e');
    }
  }

  // Generar un nuevo plan nutricional según los datos y objetivo del usuario
  Future<void> generatePlan({
    required String userId, // ID del usuario (uid de Firebase)
    required String goal, // Objetivo del plan (ej: perder peso)
    required int age, // Edad del usuario
    required double height, // Altura del usuario
    required double weight, // Peso del usuario
    required int days, // Días para el plan
  }) async {
    try {
      // Verificar si ya existe un plan y eliminarlo si es necesario
      bool planExists = await checkExistingPlan(userId);
      if (planExists) {
        await deleteExistingPlan(userId);
      }

      // Preparar los datos de entrada para el servicio de IA
      Map<String, dynamic> inputData = {
        'height': height,
        'weight': weight,
        'age': age,
        'goal': goal,
        'days': days,
      };

      // Crear un nuevo plan nutricional utilizando IA
      await _planService.createConditioningPlan(userId, inputData);

      // Actualizar el plan en el ViewModel
      userPlan = await _planService.getUserPlan(userId);
      
      // Notificar cambios
      notifyListeners();
    } catch (e) {
      debugPrint('Error al generar el plan: $e');
      throw Exception('Error al generar el plan: $e'); // Lanzar excepción para manejar errores más arriba si es necesario
    }
  }
}
