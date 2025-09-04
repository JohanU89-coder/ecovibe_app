// lib/profile_form_page.dart
import 'package:flutter/material.dart';
import 'package:recycle_app/main.dart'; // Para acceder a supabase
import 'package:recycle_app/home_page.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _dniController = TextEditingController();
  final _jefeInmediatoController = TextEditingController();
  final _cargoController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidoController.dispose();
    _dniController.dispose();
    _jefeInmediatoController.dispose();
    _cargoController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final userId = supabase.auth.currentUser!.id;
        await supabase.from('profiles').insert({
          'id': userId,
          'nombres': _nombresController.text.trim(),
          'apellido': _apellidoController.text.trim(),
          'dni': _dniController.text.trim(),
          'jefe_inmediato': _jefeInmediatoController.text.trim(),
          'cargo': _cargoController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil guardado con éxito')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar el perfil: ${error.toString()}'),
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
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos dimensiones para el diseño responsivo
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        // 1. Fondo con gradiente
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF16A085), Color(0xFF2ECC71)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08, // Padding horizontal relativo
              vertical: screenHeight * 0.05, // Padding vertical relativo
            ),
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
                        'Completa tu Perfil',
                        style: TextStyle(
                          fontSize: (screenWidth * 0.06).clamp(22.0, 28.0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        'Necesitamos estos datos para continuar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (screenWidth * 0.04).clamp(14.0, 18.0),
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      // --- Campos del Formulario ---
                      TextFormField(
                        controller: _nombresController,
                        decoration: const InputDecoration(labelText: 'Nombres'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        controller: _apellidoController,
                        decoration: const InputDecoration(
                          labelText: 'Apellido',
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        controller: _dniController,
                        decoration: const InputDecoration(labelText: 'DNI'),
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        controller: _jefeInmediatoController,
                        decoration: const InputDecoration(
                          labelText: 'Jefe Inmediato',
                        ),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextFormField(
                        controller: _cargoController,
                        decoration: const InputDecoration(labelText: 'Cargo'),
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Campo requerido' : null,
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      // --- Botón para Guardar ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          child:
                              _isLoading
                                  ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : const Text('Guardar y Continuar'),
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
      ),
    );
  }
}
