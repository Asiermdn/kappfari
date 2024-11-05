import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import '../models/race_model.dart';

class WebScrapingService {
  final String url = 'https://example-race-website.com/upcoming-races'; // Reemplaza con la URL de carreras

  Future<List<RaceModel>> fetchRaces() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);

        // Ajusta los selectores según la estructura del HTML de la página de carreras
        final raceElements = document.querySelectorAll('.race-item'); 
        List<RaceModel> races = [];

        for (var element in raceElements) {
          final id = element.querySelector('.race-id')?.text ?? '';
          final name = element.querySelector('.race-name')?.text ?? 'Carrera';
          final location = element.querySelector('.race-location')?.text ?? 'Desconocida';
          final dateText = element.querySelector('.race-date')?.text ?? '';
          final distanceText = element.querySelector('.race-distance')?.text ?? '0';
          
          // Parseamos la fecha y distancia
          final date = DateTime.tryParse(dateText) ?? DateTime.now();
          final distance = double.tryParse(distanceText.replaceAll('km', '').trim()) ?? 0.0;

          final race = RaceModel(
            id: id,
            name: name,
            location: location,
            date: date,
            distance: distance,
            description: element.querySelector('.race-description')?.text,
          );

          races.add(race);
        }

        return races;
      } else {
        throw Exception('Error al cargar datos de carreras');
      }
    } catch (e) {
      throw Exception('Fallo en el scraping: $e');
    }
  }
}
