import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final IconData icon; // Agregamos este parámetro

  const MenuCard({
    Key? key,
    required this.title,
    required this.onTap,
    required this.icon, // Requiere el ícono
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.pinkAccent), // Mostramos el ícono
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
