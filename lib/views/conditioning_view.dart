import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/conditioning_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';

class ConditioningView extends StatelessWidget {
  const ConditioningView({Key? key}) : super(key: key);

  void _onGoalSelected(BuildContext context, String goal) async {
    // Obtener instancias de los viewmodels
    final conditioningViewModel = Provider.of<ConditioningViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    // Obtener el ID del usuario actual
    final userId = authViewModel.currentUser?.id;

    // Verificar si el usuario está autenticado
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Usuario no autenticado')),
      );
      return;
    }

    try {
      // Verificar si ya existe un plan nutricional
      bool hasPlan = await conditioningViewModel.checkExistingPlan(userId);

      if (hasPlan) {
        _showReplacePlanDialog(context, conditioningViewModel, userId, goal);
      } else {
        _navigateToConditioningInput(context, goal);
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar el plan: $error')),
      );
    }
  }

  void _showReplacePlanDialog(BuildContext context, ConditioningViewModel conditioningViewModel, String userId, String goal) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Plan Activo'),
          content: const Text('Ya tienes un plan activo. ¿Quieres reemplazarlo?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Cierra el diálogo sin hacer nada
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  // Eliminar el plan existente
                  await conditioningViewModel.deleteExistingPlan(userId);
                  Navigator.pop(dialogContext); // Cierra el diálogo
                  _navigateToConditioningInput(context, goal);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al eliminar el plan: $e')),
                  );
                }
              },
              child: const Text('Reemplazar'),
            ),
          ],
        );
      },
    );
  }

  void _navigateToConditioningInput(BuildContext context, String goal) {
    // Navegar a la vista de entrada de nutrición
    Navigator.pushNamed(context, '/conditioningInput', arguments: goal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrición')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Selecciona tu objetivo:'),
            ElevatedButton(
              onPressed: () => _onGoalSelected(context, 'Bajar de Peso'),
              child: const Text('Bajar de Peso'),
            ),
            ElevatedButton(
              onPressed: () => _onGoalSelected(context, 'Subir de Peso'),
              child: const Text('Subir de Peso'),
            ),
            ElevatedButton(
              onPressed: () => _onGoalSelected(context, 'Mantener Peso'),
              child: const Text('Mantener Peso'),
            ),
          ],
        ),
      ),
    );
  }
}
