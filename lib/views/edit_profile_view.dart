import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/user_model.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  String? _displayName;
  int? _age;
  double? _height;
  double? _weight;
  String? _profilePicture; // Agregar campo para almacenar la nueva foto de perfil
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
      final UserModel? user = authViewModel.currentUser;

      if (user != null) {
        _displayName = user.displayName;
        _age = user.age;
        _height = user.height;
        _weight = user.weight;
        _profilePicture = user.profilePicture; // Obtener la foto de perfil actual
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostrar foto de perfil actual
              GestureDetector(
                onTap: _selectProfilePicture, // Al hacer tap, llamar a la función para seleccionar imagen
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profilePicture != null
                      ? NetworkImage(_profilePicture!) // Mostrar imagen de red si existe
                      : null,
                  child: _profilePicture == null
                      ? const Icon(Icons.person, size: 50) // Icono por defecto si no hay imagen
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              // Campo para el nombre
              TextFormField(
                initialValue: _displayName,
                decoration: const InputDecoration(labelText: 'Nombre'),
                onSaved: (value) {
                  _displayName = value;
                },
              ),
              const SizedBox(height: 16),

              // Campo para la edad
              TextFormField(
                initialValue: _age?.toString(),
                decoration: const InputDecoration(labelText: 'Edad'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _age = int.tryParse(value ?? '');
                },
              ),
              const SizedBox(height: 16),

              // Campo para la altura
              TextFormField(
                initialValue: _height?.toString(),
                decoration: const InputDecoration(labelText: 'Altura (m)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _height = double.tryParse(value ?? '');
                },
              ),
              const SizedBox(height: 16),

              // Campo para el peso
              TextFormField(
                initialValue: _weight?.toString(),
                decoration: const InputDecoration(labelText: 'Peso (kg)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _weight = double.tryParse(value ?? '');
                },
              ),
              const SizedBox(height: 16),

              // Botón para guardar cambios
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _updateProfile();
                  }
                },
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectProfilePicture() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery); // Seleccionar imagen desde la galería

    if (image != null) {
      setState(() {
        _profilePicture = image.path; // Actualizar la foto de perfil con la nueva imagen seleccionada
      });
    }
  }

  Future<void> _updateProfile() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    UserModel updatedUser = UserModel(
      id: authViewModel.currentUser!.id,
      email: authViewModel.currentUser!.email,
      displayName: _displayName,
      age: _age,
      height: _height,
      weight: _weight,
      profilePicture: _profilePicture ?? authViewModel.currentUser!.profilePicture, // Mantener la foto anterior si no hay nueva
    );

    await authViewModel.updateUser(updatedUser); // Llama al método para actualizar el perfil
    Navigator.pop(context); // Regresar a la vista de perfil
  }
}
