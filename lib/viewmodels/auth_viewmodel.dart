import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';  // Asegúrate de tener este servicio
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService(); // Servicio para manejar datos de usuario
  UserModel? currentUser;

  String? errorMessage;
  bool isLoading = false;

  // Método de inicio de sesión
  Future<bool> signIn(String email, String password) async {
    if (!_validateEmail(email) || !_validatePassword(password)) {
      errorMessage = "Email o contraseña inválidos";
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();

    try {
      currentUser = await _authService.signIn(email, password);
      errorMessage = null;
    } catch (e) {
      errorMessage = "Error al iniciar sesión: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return currentUser != null;
  }

  // Método de registro
  Future<bool> register(String email, String password) async {
    if (!_validateEmail(email) || !_validatePassword(password)) {
      errorMessage = "Email o contraseña inválidos";
      notifyListeners();
      return false;
    }
    isLoading = true;
    notifyListeners();

    try {
      currentUser = await _authService.register(email, password);
      errorMessage = null;
    } catch (e) {
      errorMessage = "Error al registrarse: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }

    return currentUser != null;
  }

  // Método para obtener datos del usuario
  Future<void> fetchUserData(String userId) async {
    isLoading = true;
    notifyListeners();

    try {
      // Llamar al servicio para obtener los datos del usuario desde Firestore
      currentUser = await _userService.getUserProfile(userId); // Asegúrate de implementar este método en UserService
      errorMessage = null;
    } catch (e) {
      errorMessage = "Error al obtener los datos del usuario: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(UserModel updatedUser) async {
    isLoading = true;
    notifyListeners();

    try {
      // Llamar al servicio para actualizar el perfil del usuario en Firestore
      await _userService.updateUserProfile(updatedUser); // Asegúrate de implementar este método en UserService
      currentUser = updatedUser; // Actualizar la referencia del usuario actual
      errorMessage = null;
    } catch (e) {
      errorMessage = "Error al actualizar el perfil: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    isLoading = true;
    notifyListeners();

    try {
      await _authService.signOut();
      currentUser = null;
      errorMessage = null;
    } catch (e) {
      errorMessage = "Error al cerrar sesión: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Método para eliminar la cuenta
  Future<void> deleteAccount() async {
    isLoading = true;
    notifyListeners();

    try {
      if (currentUser != null) {
        // Elimina el usuario de Firestore
        await _userService.deleteUserProfile(currentUser!.id); // Asegúrate de implementar este método
        // Elimina la cuenta de Firebase Authentication
        await _authService.deleteAccount(); 
        currentUser = null;
        errorMessage = null;
      }
    } catch (e) {
      errorMessage = "Error al eliminar la cuenta: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Validación de email
  bool _validateEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegExp.hasMatch(email);
  }

  // Validación de contraseña (mínimo 6 caracteres)
  bool _validatePassword(String password) {
    return password.isNotEmpty && password.length >= 6;
  }

  // Método para limpiar mensajes de error y estado de carga
  void resetError() {
    errorMessage = null;
    notifyListeners();
  }
}
