import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/races_viewmodel.dart';

class RacesView extends StatelessWidget {
  const RacesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RacesViewModel()..fetchRaces(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Carreras'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Aquí puedes agregar la lógica para abrir el menú de filtros
                _showFilterDialog(context);
              },
            ),
          ],
        ),
        body: Consumer<RacesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.errorMessage != null) {
              return Center(child: Text(viewModel.errorMessage!));
            }

            return Column(
              children: [
                // Campo de búsqueda
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      viewModel.updateSearchQuery(value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Buscar carreras...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                // Lista de carreras
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.filteredRaces.take(4).length, // Mostrar solo 4 carreras aleatorias
                    itemBuilder: (context, index) {
                      final race = viewModel.filteredRaces[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          title: Text(race.name),
                          subtitle: Text(
                            '${race.date.toLocal().toString().split(' ')[0]} - ${race.location}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${race.distance} km'),
                              Text(race.isPast ? 'Celebrada' : 'Pendiente', 
                                style: TextStyle(
                                  color: race.isPast ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                )),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Widget para opciones de filtro
class FilterOptions extends StatelessWidget{ 
  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<RacesViewModel>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Filtro por provincia
          DropdownButton<String>(
            value: viewModel.selectedProvince,
            items: viewModel.provinces.map((String province) {
              return DropdownMenuItem<String>(
                value: province,
                child: Text(province),
              );
            }).toList(),
            onChanged: (value) {
              viewModel.updateProvinceFilter(value);
            },
            hint: const Text('Selecciona una provincia'),
          ),
          // Filtro por año
          DropdownButton<int>(
            value: viewModel.selectedYear,
            items: viewModel.years.map((int year) {
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
            onChanged: (value) {
              viewModel.updateYearFilter(value);
            },
            hint: const Text('Selecciona un año'),
          ),
          // Filtro de estado (celebrada o pendiente)
          CheckboxListTile(
            title: const Text('Mostrar solo celebradas'),
            value: viewModel.showOnlyPastRaces,
            onChanged: (value) {
              viewModel.updateShowOnlyPastRaces(value ?? false);
            },
          ),
          // Botón para aplicar filtros
          ElevatedButton(
            onPressed: () {
              viewModel.applyFilters();
              Navigator.pop(context); // Cerrar el modal después de aplicar los filtros
            },
            child: const Text('Aplicar filtros'),
          ),
        ],
      ),
    );
  }
}
 void _showFilterDialog(BuildContext context) {
    final viewModel = Provider.of<RacesViewModel>(context, listen: false);
    final provinceController = TextEditingController(text: viewModel.locationFilter);
    int? selectedYear;
    bool showUpcoming = viewModel.showOnlyUpcoming;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtros'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: provinceController,
                decoration: const InputDecoration(labelText: 'Provincia'),
              ),
              CheckboxListTile(
                value: showUpcoming,
                onChanged: (value) {
                  showUpcoming = value ?? true;
                },
                title: const Text('Mostrar solo próximas carreras'),
              ),
              TextField(
                onChanged: (value) {
                  selectedYear = int.tryParse(value);
                },
                decoration: const InputDecoration(labelText: 'Año'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                viewModel.updateSearchQuery(
                  '',
                  province: provinceController.text,
                  year: selectedYear,
                  onlyUpcoming: showUpcoming,
                );
                Navigator.of(context).pop();
              },
              child: const Text('Aplicar'),
            ),
          ],
        );
      },
    );
 }