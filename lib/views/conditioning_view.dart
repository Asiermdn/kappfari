import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/conditioning_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class ConditioningView extends StatelessWidget {
  const ConditioningView({Key? key}) : super(key: key);

  void _onGoalSelected(BuildContext context, String goal) async {
    final conditioningViewModel = Provider.of<ConditioningViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userId = authViewModel.currentUser?.id;

    if (userId == null) {
      _showErrorSnackBar(context, 'Error: Usuario no autenticado');
      return;
    }

    try {
      bool hasPlan = await conditioningViewModel.checkExistingPlan(userId);
      if (hasPlan) {
        _showReplacePlanDialog(context, conditioningViewModel, userId, goal);
      } else {
        _navigateToConditioningInput(context, goal);
      }
    } catch (error) {
      _showErrorSnackBar(context, 'Error al verificar el plan: $error');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showReplacePlanDialog(BuildContext context, ConditioningViewModel conditioningViewModel, String userId, String goal) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'Plan Activo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Ya tienes un plan activo. ¿Quieres reemplazarlo?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await conditioningViewModel.deleteExistingPlan(userId);
                Navigator.pop(dialogContext);
                _navigateToConditioningInput(context, goal);
              } catch (e) {
                _showErrorSnackBar(context, 'Error al eliminar el plan: $e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Reemplazar'),
          ),
        ],
      ),
    );
  }

  void _navigateToConditioningInput(BuildContext context, String goal) {
    Navigator.pushNamed(context, '/conditioningInput', arguments: goal);
  }

  Widget _buildGoalCard(BuildContext context, String title, String description, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () => _onGoalSelected(context, title),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan de Entrenamiento'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  '¿Cuál es tu objetivo de entrenamiento?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _buildGoalCard(
                        context,
                        'Pérdida de Grasa',
                        'Ejercicios enfocados en quemar grasa y mejorar la resistencia',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      _buildGoalCard(
                        context,
                        'Ganancia Muscular',
                        'Rutina para desarrollar fuerza y masa muscular',
                        Icons.fitness_center,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildGoalCard(
                        context,
                        'Resistencia',
                        'Plan para mejorar tu capacidad cardiovascular',
                        Icons.speed,
                        Colors.green,
                      ),
                      const SizedBox(height: 16),
                      _buildGoalCard(
                        context,
                        'Tonificación',
                        'Ejercicios para definir y tonificar tu cuerpo',
                        Icons.accessibility_new,
                        Colors.purple,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}