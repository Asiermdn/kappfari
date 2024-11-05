import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import 'package:image_picker/image_picker.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? currentUser;

  // Método para cargar el perfil del usuario desde la base de datos
  Future<void> loadUserProfile(String userId) async {
    currentUser = await _userService.getUserProfile(userId);
    notifyListeners();
  }

  // Método para actualizar el perfil
  Future<void> updateProfile(
    String displayName,
    XFile? profileImageFile, // Añadir argumento para la imagen de perfil
    int? age,
    double? height,
    double? weight,
  ) async {
    if (currentUser != null) {
      String? profilePictureUrl = currentUser!.profilePicture; // Mantener la imagen de perfil actual

      // Si hay una nueva imagen, subirla y obtener la URL
      if (profileImageFile != null) {
        profilePictureUrl = await _userService.uploadProfileImage(profileImageFile);
      }

      // Actualizar el perfil en Firestore
      await _userService.updateProfile(
        currentUser!.id,
        displayName,
        profilePictureUrl, // Usar la URL actual o la nueva
        age,
        height,
        weight,
      );

      // Cargar los datos actualizados desde Firestore
      await loadUserProfile(currentUser!.id); // Carga los nuevos datos

      notifyListeners();
    }
  }

  Future<void> deleteUser() async {
    if (currentUser != null) {
      await _userService.deleteUserProfile(currentUser!.id);
      currentUser = null;
      notifyListeners();
    }
  }

  void signOut() {
    currentUser = null;
    notifyListeners();
  }
}
