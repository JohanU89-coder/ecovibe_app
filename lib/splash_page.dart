import 'package:flutter/material.dart';
import 'package:recycle_app/home_page.dart';
import 'package:recycle_app/login_page.dart';
import 'package:recycle_app/main.dart';
import 'package:recycle_app/profile_form_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    print("SPLASH_PAGE: initState called.");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print("SPLASH_PAGE: addPostFrameCallback triggered.");
      _redirect();
    });
  }

  /// Inicia el proceso de redirección con un límite de tiempo estricto.
  Future<void> _redirect() async {
    print("SPLASH_PAGE: _redirect started.");
    try {
      // Le damos a todo el proceso un máximo de 10 segundos para completarse.
      await _performCheckAndRedirect().timeout(const Duration(seconds: 10));
      print("SPLASH_PAGE: _redirect finished successfully.");
    } catch (e) {
      print("SPLASH_PAGE: Caught error in _redirect: $e");
      // Si algo falla (un error o el timeout), vamos de forma segura al login.
      if (!mounted) {
        print("SPLASH_PAGE: Not mounted after error, cannot redirect.");
        return;
      }
      print("SPLASH_PAGE: Redirecting to LoginPage due to error.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  /// Contiene la lógica real para verificar sesión y perfil.
  Future<void> _performCheckAndRedirect() async {
    print("SPLASH_PAGE: _performCheckAndRedirect started.");
    // Pequeña demora para que la splash screen sea visible.
    await Future.delayed(const Duration(seconds: 1));
    print("SPLASH_PAGE: Initial 1-second delay finished.");

    if (!mounted) {
      print("SPLASH_PAGE: Not mounted after delay, aborting.");
      return;
    }

    print("SPLASH_PAGE: Checking for current session...");
    final session = supabase.auth.currentSession;

    if (session != null) {
      print("SPLASH_PAGE: Session found for user ${session.user.id}.");
      // Si hay sesión, verificamos si el perfil está completo
      final userId = session.user.id;
      print("SPLASH_PAGE: Fetching profile for user $userId...");
      final profileResponse =
          await supabase
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();
      print("SPLASH_PAGE: Profile fetch complete.");

      if (!mounted) {
        print("SPLASH_PAGE: Not mounted after profile fetch, aborting.");
        return;
      }

      if (profileResponse != null) {
        print("SPLASH_PAGE: Profile found. Redirecting to HomePage.");
        // Perfil completo, vamos a la HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        print(
          "SPLASH_PAGE: Profile NOT found. Redirecting to ProfileFormPage.",
        );
        // Sesión activa pero sin perfil, vamos al formulario de perfil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileFormPage()),
        );
      }
    } else {
      print("SPLASH_PAGE: No session found. Redirecting to LoginPage.");
      // No hay sesión, vamos al Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    print("SPLASH_PAGE: build method called.");
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF16A085), Color(0xFF2ECC71)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
