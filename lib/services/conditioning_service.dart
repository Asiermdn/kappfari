import '../models/conditioning_model.dart';
import 'database_service.dart';

class ConditioningService {
  final DatabaseService _dbService = DatabaseService();

  Future<List<ExerciseModel>> generateWorkoutPlan(String userId, String objective) async {
    List<ExerciseModel> exercises = [
      ExerciseModel(id: "1", name: "Push-ups", category: "Strength", sets: 3, reps: 15),
      ExerciseModel(id: "2", name: "Running", category: "Cardio", sets: 1, reps: 1, instructions: "Run 5km")
    ];

    for (var exercise in exercises) {
      await _dbService.saveData("workout_plans", "$userId-${exercise.id}", exercise.toMap());
    }
    return exercises;
  }

  Future<List<ExerciseModel>> getWorkoutPlan(String userId) async {
    var dataList = await _dbService.getCollection("workout_plans");
    return dataList.map((data) => ExerciseModel.fromMap(data)).toList();
  }
}
