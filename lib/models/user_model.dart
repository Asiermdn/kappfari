class UserModel {
  final String id;
  final String email;
  final String? name;
  final int? age;
  final double? height; // Cambiado a double
  final double? weight; // Cambiado a double
  final String? displayName;
  final String? profilePicture;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.age,
    this.height,
    this.weight,
    this.displayName,
    this.profilePicture,
  });

  // Método para crear una instancia de UserModel a partir de un Map
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'] ?? '',
      email: data['email'] ?? '',
      name: data['name'],
      age: data['age'],
      height: data['height'] != null ? (data['height'] as num).toDouble() : null, // Asegurando conversión a double
      weight: data['weight'] != null ? (data['weight'] as num).toDouble() : null, // Asegurando conversión a double
      displayName: data['displayName'],
      profilePicture: data['profilePicture'],
    );
  }

  // Método para convertir una instancia de UserModel a un Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
      'displayName': displayName,
      'profilePicture': profilePicture,
    };
  }
}
