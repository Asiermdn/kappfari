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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userId = authViewModel.currentUser?.id;
      if (userId == null) {
        throw Exception('No hay usuario autenticado');
      }

      await authViewModel.fetchUserData(userId);
      
      if (!mounted) return;
      
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
    await _fetchUserData();
  }

  String _formatValue(dynamic value, String unit) {
    if (value == null || value == 0) return 'No especificado';
    return '$value $unit';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final safeHeight = screenSize.height - padding.top - padding.bottom;
    
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final UserModel? user = authViewModel.currentUser;

        // Procesamiento de datos del usuario
        final age = user?.age != null && user!.age! > 0 ? user.age.toString() : 'No especificado';
        final height = user?.height != null && user!.height! > 0 ? '${user.height} m' : 'No especificado';
        final weight = user?.weight != null && user!.weight! > 0 ? '${user.weight} kg' : 'No especificado';

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _handleRefresh,
              ),
            ],
          ),
          extendBodyBehindAppBar: true,
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
                        child: Column(
                          children: [
                            // Header con gradiente
                            Container(
                              height: safeHeight * 0.3,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Theme.of(context).primaryColor,
                                    Theme.of(context).primaryColor.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(30),
                                  bottomRight: Radius.circular(30),
                                ),
                              ),
                            ),
                            
                            // Contenido principal
                            Transform.translate(
                              offset: Offset(0, -safeHeight * 0.1),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenSize.width * 0.05,
                                ),
                                child: Column(
                                  children: [
                                    // Foto de perfil
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(context).scaffoldBackgroundColor,
                                          width: 4,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: screenSize.width * 0.15,
                                        backgroundImage: user?.profilePicture != null
                                            ? NetworkImage(user!.profilePicture!)
                                            : null,
                                        child: user?.profilePicture == null
                                            ? Icon(Icons.person, size: screenSize.width * 0.15)
                                            : null,
                                      ),
                                    ),
                                    
                                    SizedBox(height: safeHeight * 0.02),
                                    
                                    // Información del usuario
                                    Text(
                                      user?.displayName ?? 'Nombre no especificado',
                                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: safeHeight * 0.01),
                                    Text(
                                      user?.email ?? '',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    
                                    SizedBox(height: safeHeight * 0.03),
                                    
                                    // Tarjetas de información
                                    Container(
                                      height: screenSize.height * 0.15,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: _buildInfoCard(
                                              context,
                                              'Edad',
                                              age,
                                              Icons.cake,
                                            ),
                                          ),
                                          SizedBox(width: screenSize.width * 0.02),
                                          Expanded(
                                            child: _buildInfoCard(
                                              context,
                                              'Altura',
                                              height,
                                              Icons.height,
                                            ),
                                          ),
                                          SizedBox(width: screenSize.width * 0.02),
                                          Expanded(
                                            child: _buildInfoCard(
                                              context,
                                              'Peso',
                                              weight,
                                              Icons.monitor_weight,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    
                                    SizedBox(height: safeHeight * 0.03),
                                    
                                    // Botones de acción
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenSize.width * 0.1,
                                      ),
                                      child: Column(
                                        children: [
                                          _buildActionButton(
                                            context: context,
                                            icon: Icons.edit,
                                            label: 'Editar perfil',
                                            onPressed: () async {
                                              await Navigator.pushNamed(context, '/editProfile');
                                              _handleRefresh();
                                            },
                                          ),
                                          SizedBox(height: safeHeight * 0.015),
                                          _buildActionButton(
                                            context: context,
                                            icon: Icons.logout,
                                            label: 'Cerrar sesión',
                                            onPressed: () async {
                                              await authViewModel.signOut();
                                              if (!mounted) return;
                                              Navigator.pushReplacementNamed(context, '/login');
                                            },
                                          ),
                                          SizedBox(height: safeHeight * 0.015),
                                          _buildActionButton(
                                            context: context,
                                            icon: Icons.delete_forever,
                                            label: 'Eliminar cuenta',
                                            color: Colors.red,
                                            onPressed: () async {
                                              await authViewModel.deleteAccount();
                                              if (!mounted) return;
                                              Navigator.pushReplacementNamed(context, '/login');
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: safeHeight * 0.02),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Center(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    );
  }
}