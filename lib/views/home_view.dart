import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/menu_card.dart';
import '../services/nutrition_plan_service.dart';
import '../services/conditioning_plan_service.dart';
import '../models/nutrition_plan_model.dart';
import '../models/conditioning_plan_model.dart';
import '../viewmodels/auth_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final NutritionPlanService _nutritionPlanService = NutritionPlanService();
  final ConditioningPlanService _conditioningPlanService = ConditioningPlanService();
  NutritionPlan? _userNutritionPlan;
  ConditioningPlan? _userConditioningPlan;
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchUserPlans();
  }

  Future<void> _fetchUserPlans() async {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final userId = authViewModel.currentUser?.id;

    if (userId != null) {
      final nutritionPlan = await _nutritionPlanService.getUserPlan(userId);
      final conditioningPlan = await _conditioningPlanService.getUserPlan(userId);

      if (mounted) {
        setState(() {
          _userNutritionPlan = nutritionPlan;
          _userConditioningPlan = conditioningPlan;
        });
      }
    }
  }

  Widget _buildPlanCard(String title, Map<int, List<String>> dailyItems, String goal) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title, 
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold
                )
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context, 
                    title == 'Plan Nutricional' ? '/nutrition' : '/conditioning'
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                ),
                child: const Text('Ver más', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dailyItems.entries.take(3).length,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemBuilder: (context, index) {
              final entry = dailyItems.entries.elementAt(index);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: theme.primaryColor.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                elevation: 2,
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Día ${entry.key}', 
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold
                        )
                      ),
                      Divider(color: theme.primaryColor.withOpacity(0.2)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: entry.value.length,
                          itemBuilder: (context, idx) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    title == 'Plan Nutricional' 
                                      ? Icons.restaurant_menu 
                                      : Icons.fitness_center,
                                    size: 16,
                                    color: theme.primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.value[idx],
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.black87
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
   appBar: AppBar(
  elevation: 0,
  title: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      Image.asset(
        'assets/logo.png', // Asegúrate de que esta ruta corresponda al logo en tus assets
        height: 24,
        fit: BoxFit.contain,
      ),
      const SizedBox(width: 8),
    
    ],
  ),
  centerTitle: true, // Esto centra el contenido del AppBar
  actions: [
    Consumer<AuthViewModel>(
      builder: (context, authViewModel, _) {
        final profilePicture = authViewModel.currentUser?.profilePicture;

        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: profilePicture != null
                  ? NetworkImage(profilePicture)
                  : null,
              child: profilePicture == null
                  ? const Icon(Icons.person, color: Colors.pinkAccent, size: 20)
                  : null,
            ),
          ),
        );
      },
    ),
  ],
),


      body: RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: _fetchUserPlans,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userNutritionPlan != null)
                _buildPlanCard(
                  'Plan Nutricional',
                  _userNutritionPlan!.dailyMeals,
                  _userNutritionPlan!.goal,
                ),
              if (_userConditioningPlan != null)
                _buildPlanCard(
                  'Plan de Acondicionamiento',
                  _userConditioningPlan!.dailyMeals,
                  _userConditioningPlan!.goal,
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            switch (index) {
              case 0: break;
              case 1:
                Navigator.pushNamed(context, '/nutrition');
                break;
              case 2:
                Navigator.pushNamed(context, '/activity');
                break;
              case 3:
                Navigator.pushNamed(context, '/conditioning');
                break;
              case 4:
                Navigator.pushNamed(context, '/races');
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.primaryColor,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant),
              label: 'Nutrición',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.run_circle_outlined),
              activeIcon: Icon(Icons.run_circle),
              label: 'Actividad',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Acondicionamiento',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Carreras',
            ),
          ],
        ),
      ),
    );
  }
}