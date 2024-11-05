import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final String? Function(String?)? validator;
  final String? initialValue;
  final ValueChanged<String>? onChanged; // Agregado para manejar los cambios

  const InputField({
    Key? key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.validator,
    this.initialValue,
    this.onChanged, // Asegúrate de incluir el nuevo parámetro
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (initialValue != null) {
      controller.text = initialValue!; // Establece el valor inicial si se proporciona
    }

    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  // Cambia el ícono dependiendo del estado de la visibilidad
                  controller.text.isEmpty || controller.text == '****'
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  // Alterna la visibilidad de la contraseña
                  // Aquí puedes implementar lógica para cambiar el estado del widget
                },
              )
            : null,
      ),
      validator: validator,
      onChanged: onChanged, // Agregado para manejar el cambio
      onFieldSubmitted: (_) {
        // Cierra el teclado al enviar
        FocusScope.of(context).unfocus();
      },
    );
  }
}
