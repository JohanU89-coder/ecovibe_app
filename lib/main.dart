import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:recycle_app/splash_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  // Asegura que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Supabase
  await Supabase.initialize(
    // Reemplaza con tus propios datos de Supabase
    url: 'https://vrlkwdihwiscincrdiew.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZybGt3ZGlod2lzY2luY3JkaWV3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5NTM3MjcsImV4cCI6MjA3MDUyOTcyN30.NoGlVX6IPZ3wzNiYVRITn2wY2BdGPLgfLcgHXkSifuc',
  );

  runApp(const MyApp());
}

// Cliente global de Supabase para un fácil acceso
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2ECC71);

    return MaterialApp(
      title: 'Ecovibe',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', '')],
      locale: const Locale('es', ''),

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          floatingLabelStyle: const TextStyle(color: Colors.grey),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
