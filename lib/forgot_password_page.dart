// lib/forgot_password_page.dart
import 'package:flutter/material.dart';
import 'package:recycle_app/main.dart'; // Para acceder a la instancia de supabase
import 'package:recycle_app/verify_otp_page.dart'; // La nueva página que creamos

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Solicita a Supabase que envíe un correo con un código de recuperación (OTP).
  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      await supabase.auth.resetPasswordForEmail(_emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correo con código de recuperación enviado.'),
          ),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => VerifyOtpPage(email: _emailController.text.trim()),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al enviar el correo de recuperación.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos dimensiones para el diseño responsivo
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safeArea = MediaQuery.of(context).padding;

    return Scaffold(
      // Usamos un Stack para poner el botón de regreso sobre el fondo
      body: Stack(
        children: [
          // 1. Fondo con gradiente, igual que en el login
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF16A085), Color(0xFF2ECC71)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Contenido principal
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Container(
                  // 2. Tarjeta blanca central
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        // 3. Título de la pantalla con fuente relativa
                        Text(
                          'Recuperar Contraseña',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.06).clamp(22.0, 28.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Ingresa tu correo para recibir un código de 6 dígitos.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        // Campo de Email
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                !value.contains('@')) {
                              return 'Por favor, ingresa un email válido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        // Botón de Enviar Código
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _sendResetEmail,
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text('Enviar Código'),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 4. Botón para regresar a la pantalla de login, respetando safe area
          Positioned(
            top: safeArea.top + 10,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
