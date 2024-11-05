import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import 'package:image_picker/image_picker.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Método para subir imagen de perfil a Firebase Storage
  Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      // Generar un nombre único para la imagen
      String fileName = 'profile_pictures/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      // Subir la imagen a Firebase Storage
      UploadTask uploadTask = _storage.ref(fileName).putFile(File(imageFile.path));

      // Esperar a que la carga se complete
      TaskSnapshot snapshot = await uploadTask;

      // Obtener la URL de descarga
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl; // Devuelve la URL de la imagen subida
    } catch (e) {
      print("Error al subir la imagen de perfil: ${e.toString()}");
      return null; // En caso de error, devuelve null
    }
  }

  // Crear o actualizar perfil extendido de usuario en Firestore
  Future<void> saveUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
  }

  // Obtener datos del perfil del usuario
   Future<UserModel?> getUserProfile(String uid) async {
    try {
      // Primero intentamos obtener el documento
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) {
        print("No se encontró el usuario con uid: $uid");
        return null;
      }

      // Convertimos los datos y verificamos que no sean nulos
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        print("Los datos del usuario son nulos");
        return null;
      }

      // Aseguramos que el ID esté incluido en los datos
      data['id'] = doc.id;
      
      return UserModel.fromMap(data);
    } catch (e) {
      print("Error al obtener el perfil del usuario: ${e.toString()}");
      throw Exception("Error al obtener el perfil: $e");
    }
  }

  // Añadir método para escuchar cambios en tiempo real
  Stream<UserModel?> getUserProfileStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (!doc.exists || doc.data() == null) return null;
          final data = doc.data()!;
          data['id'] = doc.id;
          return UserModel.fromMap(data);
        });
  }

  // Actualizar información de perfil como photoURL y displayName
  Future<void> updateProfile(String userId, String displayName, String? profilePictureUrl, int? age, double? height, double? weight) async {
    // Crear un mapa con los campos a actualizar
    final Map<String, dynamic> updatedData = {};
    
    if (displayName.isNotEmpty) {
      updatedData['displayName'] = displayName;
    }
    if (profilePictureUrl != null) {
      updatedData['profilePictureUrl'] = profilePictureUrl;
    }
    if (age != null) {
      updatedData['age'] = age;
    }
    if (height != null) {
      updatedData['height'] = height;
    }
    if (weight != null) {
      updatedData['weight'] = weight;
    }

    // Actualizar solo los campos que han sido proporcionados
    await _firestore.collection('users').doc(userId).update(updatedData);
  }

  Future<void> createUserProfile(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set({
      'email': user.email,
      'name': user.name,
      'age': user.age,
      'height': user.height,
      'weight': user.weight,
    });
  }
Future<void> updateUserProfile(UserModel user) async {
  try {
    // Crear un mapa con los campos a actualizar
    final updateData = <String, dynamic>{
      'displayName': user.displayName,
      'age': user.age,
      'height': user.height,
      'weight': user.weight,
      // Agregar el campo de la foto de perfil
      'profilePicture': user.profilePicture,
      // Puedes agregar otros campos aquí según sea necesario
    };

    // Filtrar campos nulos para evitar actualizaciones innecesarias
    updateData.removeWhere((key, value) => value == null);

    // Actualizar el documento del usuario en Firestore
    await _firestore.collection('users').doc(user.id).update(updateData);
  } catch (e) {
    throw Exception("Error al actualizar el perfil: ${e.toString()}");
  }
}

  // Método para eliminar el perfil del usuario en Firestore
  Future<void> deleteUserProfile(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception("Error al eliminar el perfil: ${e.toString()}");
    }
  }
}
