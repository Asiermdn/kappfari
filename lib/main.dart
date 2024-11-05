import 'package:flutter/material.dart';
import 'package:kappfari/viewmodels/conditioning_viewmodel.dart';
import 'package:kappfari/views/conditioning_input_view.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Importación de vistas y servicios
import 'package:kappfari/views/login_view.dart';
import 'package:kappfari/views/register_view.dart';
import 'package:kappfari/views/home_view.dart';
import 'package:kappfari/views/nutrition_view.dart';
import 'package:kappfari/views/conditioning_view.dart';
import 'package:kappfari/views/activity_view.dart';
import 'package:kappfari/views/races_view.dart';
import 'package:kappfari/views/profile_view.dart';
import 'package:kappfari/views/edit_profile_view.dart';
import 'package:kappfari/views/nutrition_input_view.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/nutrition_viewmodel.dart';
import 'viewmodels/activity_viewmodel.dart';
import 'services/geolocation_service.dart';
import 'services/activity_service.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => NutritionViewModel()), 
         ChangeNotifierProvider(create: (context) => ConditioningViewModel()), 
        Provider(create: (_) => GeolocationService()),

        // Pasa GeolocationService como parámetro al crear ActivityService
        ProxyProvider<GeolocationService, ActivityService>(
          update: (_, geolocationService, __) => ActivityService(geolocationService),
        ),

        ChangeNotifierProvider(
          create: (context) => ActivityViewModel(
            context.read<ActivityService>(),
            context.read<GeolocationService>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Kappfari',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
          '/home': (context) => const HomeView(),
          '/nutrition': (context) => const NutritionView(),
          '/conditioning': (context) => const ConditioningView(),
          '/activity': (context) => ActivityView(),
          '/races': (context) => const RacesView(),
          '/profile': (context) => const ProfileView(),
          '/editProfile': (context) => const EditProfileView(),
          '/nutritionInput': (context) {
            final goal = ModalRoute.of(context)!.settings.arguments as String;
            return NutritionInputView(goal: goal);
            
          }, 
          '/conditioningInput': (context) {
            final goal = ModalRoute.of(context)!.settings.arguments as String;
            return ConditioningInputView(goal: goal);
            
          },
        
          
        },
      ),
    );
  }
}
