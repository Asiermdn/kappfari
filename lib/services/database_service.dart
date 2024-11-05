import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Guardar datos en la colección especificada
  Future<void> saveData(String collection, String docId, Map<String, dynamic> data) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  // Obtener datos de la colección especificada
  Future<Map<String, dynamic>?> getData(String collection, String docId) async {
    DocumentSnapshot doc = await _firestore.collection(collection).doc(docId).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // Obtener una lista de documentos de una colección
  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    QuerySnapshot querySnapshot = await _firestore.collection(collection).get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}
