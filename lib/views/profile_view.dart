import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../models/user_model.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Llamamos a _fetchUserData después de que el widget esté completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Esto asegura que los datos se actualicen cuando el widget se reconstruye
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return; // Verificamos si el widget está montado

    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Obtenemos el ID del usuario actual
      final userId = authViewModel.currentUser?.id;
      if (userId == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Actualizamos los datos del usuario
      await authViewModel.fetchUserData(userId);
      
      if (!mounted) return; // Verificamos nuevamente si el widget está montado
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _errorMessage = "Error al cargar los datos del perfil: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    // Función para actualizar manualmente los datos
    await _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final UserModel? user = authViewModel.currentUser;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Perfil'),
            actions: [
              // Botón de actualización manual
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _handleRefresh,
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_errorMessage!),
                          ElevatedButton(
                            onPressed: _handleRefresh,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Foto de perfil
                              Center(
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundImage: user?.profilePicture != null
                                      ? NetworkImage(user!.profilePicture!)
                                      : null,
                                  child: user?.profilePicture == null
                                      ? const Icon(Icons.person, size: 50)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Datos del usuario
                              Text(
                                user?.displayName ?? 'Nombre no especificado',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(user?.email ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium),
                              const SizedBox(height: 8),

                              // Mostrar más datos del usuario
                              Text(
                                'Edad: ${user?.age != null ? user!.age.toString() : 'No especificada'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Altura: ${user?.height != null ? user!.height.toString() : 'No especificada'} m',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Text(
                                'Peso: ${user?.weight != null ? user!.weight.toString() : 'No especificado'} kg',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),

                              const SizedBox(height: 16),

                              // Opciones de edición
                              ElevatedButton(
                                onPressed: () async {
                                  await Navigator.pushNamed(context, '/editProfile');
                                  // Actualizar datos después de editar
                                  _handleRefresh();
                                },
                                child: const Text('Editar perfil'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await authViewModel.signOut();
                                  if (!mounted) return;
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                child: const Text('Cerrar sesión'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await authViewModel.deleteAccount();
                                  if (!mounted) return;
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                child: const Text('Eliminar cuenta'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        );
      },
    );
  }
}