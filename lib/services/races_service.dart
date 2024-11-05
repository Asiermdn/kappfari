import '../models/race_model.dart';
import 'database_service.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class RacesService {
  final DatabaseService _dbService = DatabaseService();

  Future<List<RaceModel>> fetchRaces() async {
    final response = await http.get(Uri.parse("https://example.com/races"));
    var document = parser.parse(response.body);
    List<RaceModel> races = [];

    // Ejemplo de scraping para extraer los datos
    var raceElements = document.getElementsByClassName("race-item");
    for (var element in raceElements) {
      String id = element.attributes['data-id'] ?? '0';
      String name = element.querySelector(".race-name")?.text ?? "Desconocido";
      String location = element.querySelector(".race-location")?.text ?? "Desconocida";
      DateTime date = DateTime.parse(element.querySelector(".race-date")?.text ?? DateTime.now().toString());
      double distance = double.parse(element.querySelector(".race-distance")?.text ?? "0");

      RaceModel race = RaceModel(
        id: id,
        name: name,
        location: location,
        date: date,
        distance: distance,
      );

      await _dbService.saveData("races", id, race.toMap());
      races.add(race);
    }

    return races;
  }
}
