import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Registrar un nuevo usuario
  Future<UserModel?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel(id: userCredential.user!.uid, email: email);
    } catch (e) {
      print("Error en el registro: $e");
      return null;
    }
  }

  // Iniciar sesión
  Future<UserModel?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel(id: userCredential.user!.uid, email: email);
    } catch (e) {
      print("Error al iniciar sesión: $e");
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Eliminar la cuenta del usuario
  Future<void> deleteAccount() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.delete(); // Elimina la cuenta del usuario
    }
  }
}
