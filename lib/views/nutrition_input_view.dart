import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/nutrition_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/user_model.dart';

class NutritionInputView extends StatefulWidget {
  final String goal;

  const NutritionInputView({Key? key, required this.goal}) : super(key: key);

  @override
  _NutritionInputViewState createState() => _NutritionInputViewState();
}

class _NutritionInputViewState extends State<NutritionInputView> {
  final _formKey = GlobalKey<FormState>();
  int? _days;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Llamar al método para cargar los datos del usuario
  }

  Future<void> _fetchUserData() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userId = authViewModel.currentUser?.id;

    if (userId != null) {
      try {
        // Obtener los datos del usuario desde la base de datos
        await authViewModel.fetchUserData(userId);
      } catch (e) {
        setState(() {
          _errorMessage = "Error al cargar los datos del perfil: ${e.toString()}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context);
    final UserModel? user = authViewModel.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text('Datos para ${widget.goal}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_errorMessage != null) 
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              _buildDaysField(),
              const SizedBox(height: 20),
              _buildGenerateButton(user),
              const SizedBox(height: 20),
              _buildDeleteButton(user),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildDaysField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Días del plan'),
      keyboardType: TextInputType.number,
      onSaved: (value) => _days = int.tryParse(value ?? ''),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor, introduce el número de días';
        }
        if (int.tryParse(value) == null || int.parse(value) <= 0) {
          return 'Introduce un número de días válido';
        }
        return null;
      },
    );
  }

  ElevatedButton _buildGenerateButton(UserModel? user) {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          if (user != null) {
            try {
              print('Generando plan para el usuario:');
              print('ID: ${user.id}');
              print('Altura: ${user.height}');
              print('Peso: ${user.weight}');
              print('Edad: ${user.age}');
              print('Días: $_days');

              if (_days != null) {
                await Provider.of<NutritionViewModel>(context, listen: false).generatePlan(
                  userId: 'J23mxDm6REUc8ZNJOLPJc2VXPF83',
                  goal: widget.goal,
                  height: user.height!,
                  weight: user.weight!,
                  age: user.age!,
                  days: _days!,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Plan generado exitosamente!')),
                );
                Navigator.pop(context);
              } else {
                print('Error: _days es nulo');
              }
            } catch (error) {
              print('Error al generar el plan: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al generar el plan: $error')),
              );
            }
          } else {
            print('Error: Usuario no autenticado');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Usuario no autenticado')),
            );
          }
        }
      },
      child: const Text('Generar Plan'),
    );
  }

  ElevatedButton _buildDeleteButton(UserModel? user) {
    return ElevatedButton(
      onPressed: () async {
        if (user != null) {
          try {
            await Provider.of<NutritionViewModel>(context, listen: false)
                .deleteExistingPlan(user.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plan eliminado exitosamente!')),
            );
          } catch (error) {
            print('Error al eliminar el plan: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al eliminar el plan: $error')),
            );
          }
        } else {
          print('Error: Usuario no autenticado al intentar eliminar plan');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Usuario no autenticado')),
          );
        }
      },
      child: const Text('Eliminar Plan'),
    );
  }
}
