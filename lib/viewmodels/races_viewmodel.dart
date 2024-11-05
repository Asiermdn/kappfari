import 'package:flutter/material.dart';
import '../services/web_scraping_service.dart';
import '../models/race_model.dart';

class RacesViewModel extends ChangeNotifier {
  final WebScrapingService _scrapingService = WebScrapingService();
  List<RaceModel> races = [];
  List<RaceModel> filteredRaces = [];
  bool loading = true;
  String? errorMessage;
   String locationFilter = 'Albacete'; // Filtro inicial por provincia
  bool showOnlyUpcoming = true; // Filtro inicial para carreras futuras

  // Variables para almacenar el estado de los filtros
  String? selectedProvince;
  int? selectedYear;
  bool showOnlyPastRaces = false;

  // Constructor que inicia la carga de carreras
  RacesViewModel() {
    fetchRaces();
  }

   // Método para obtener carreras y aplicar filtros iniciales
  Future<void> fetchRaces() async {
    try {
      loading = true; 
      errorMessage = null;
      races = await _scrapingService.fetchRaces(); // Carga las carreras desde el servicio
      applyDefaultFilters(); // Aplica los filtros iniciales
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
 // Método para aplicar los filtros iniciales
  void applyDefaultFilters() {
    filteredRaces = races.where((race) {
      // Filtra carreras que están en Albacete y no han sido celebradas
      return race.location == locationFilter && (showOnlyUpcoming ? !race.isPast : true);
    }).toList();
  }


  // Método para actualizar la consulta de búsqueda
  void updateSearchQuery(String query, {String? province, int? year, bool? onlyUpcoming}) {
    locationFilter = province ?? locationFilter;
    showOnlyUpcoming = onlyUpcoming ?? showOnlyUpcoming;

    filteredRaces = races.where((race) {
      final matchesName = race.name.toLowerCase().contains(query.toLowerCase());
      final matchesLocation = race.location.toLowerCase() == locationFilter.toLowerCase();
      final matchesYear = year == null || race.date.year == year;
      final matchesUpcoming = !showOnlyUpcoming || !race.isPast;
      return matchesName && matchesLocation && matchesYear && matchesUpcoming;
    }).toList();

    notifyListeners();
  }


  // Método para actualizar el filtro de provincia
  void updateProvinceFilter(String? province) {
    selectedProvince = province;
    notifyListeners();
  }

  // Método para actualizar el filtro de año
  void updateYearFilter(int? year) {
    selectedYear = year;
    notifyListeners();
  }

  // Método para actualizar el filtro de carreras celebradas
  void updateShowOnlyPastRaces(bool value) {
    showOnlyPastRaces = value;
    notifyListeners();
  }

  // Método para aplicar todos los filtros
  void applyFilters() {
    DateTime now = DateTime.now();
    filteredRaces = races.where((race) {
      // Filtrar por provincia
      bool matchesProvince = selectedProvince == null || race.location == selectedProvince;

      // Filtrar por año
      bool matchesYear = selectedYear == null || race.date.year == selectedYear;

      // Filtrar por estado de celebración
      bool matchesPastState = !showOnlyPastRaces || race.date.isBefore(now);

      // Retorna true solo si la carrera cumple con todos los filtros
      return matchesProvince && matchesYear && matchesPastState;
    }).toList();

    notifyListeners();
  }

  // Lista de provincias y años disponibles para los filtros
  List<String> get provinces => races.map((race) => race.location).toSet().toList();
  List<int> get years => races.map((race) => race.date.year).toSet().toList();

 
}
 