class Validators {
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'El email no puede estar vacío';
    final emailRegExp = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegExp.hasMatch(value)) return 'Por favor, ingrese un email válido';
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }
}
