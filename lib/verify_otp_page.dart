// lib/verify_otp_page.dart
import 'package:flutter/material.dart';
import 'package:recycle_app/main.dart';
import 'package:recycle_app/update_password_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyOtpPage extends StatefulWidget {
  final String email;
  const VerifyOtpPage({super.key, required this.email});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _tokenController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final response = await supabase.auth.verifyOTP(
        email: widget.email,
        token: _tokenController.text.trim(),
        type: OtpType.recovery,
      );

      if (mounted && response.session != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const UpdatePasswordPage()),
          (route) => false,
        );
      } else {
        throw 'La sesión no se pudo establecer. El código podría ser incorrecto.';
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
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
      body: Stack(
        children: [
          // 1. Fondo con gradiente
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
                        // 3. Título y subtítulo con fuentes relativas
                        Text(
                          'Verificar Código',
                          style: TextStyle(
                            fontSize: (screenWidth * 0.06).clamp(22.0, 28.0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Text(
                          'Ingresa el código de 6 dígitos enviado a:\n${widget.email}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),
                        // Campo para el código
                        TextFormField(
                          controller: _tokenController,
                          decoration: const InputDecoration(
                            labelText: 'Código de Verificación',
                          ),
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (screenWidth * 0.05).clamp(18.0, 22.0),
                            letterSpacing: 8,
                          ),
                          validator: (value) {
                            if (value == null || value.length != 6) {
                              return 'Ingresa un código de 6 dígitos.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        // Botón de verificación
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOtp,
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text('Verificar y Continuar'),
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
          // 4. Botón para regresar, posicionado respetando el safe area
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
