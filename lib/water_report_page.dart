import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recycle_app/main.dart'; // Import for supabase client
import 'package:supabase_flutter/supabase_flutter.dart'; // Import for PostgrestException

// Enum para gestionar la vista del formulario
enum RegistroTipo { ingreso, salida }

// Modelo de datos para el campamento
class CampamentoData {
  final String nombre;
  final String e;
  final String n;
  final String resolucion;
  final String fuenteDeAgua;
  final String tipoDeUso;
  final String claseDeDerecho;

  CampamentoData({
    required this.nombre,
    required this.e,
    required this.n,
    required this.resolucion,
    required this.fuenteDeAgua,
    required this.tipoDeUso,
    required this.claseDeDerecho,
  });
}

class WaterReportPage extends StatefulWidget {
  final Map<String, dynamic>? existingReport;
  const WaterReportPage({super.key, this.existingReport});

  @override
  State<WaterReportPage> createState() => _WaterReportPageState();
}

class _WaterReportPageState extends State<WaterReportPage> {
  final _formKey = GlobalKey<FormState>();

  // Lista de datos de los campamentos
  final List<CampamentoData> campamentos = [
    CampamentoData(
      nombre: 'Pagoreni 1X',
      e: '728686',
      n: '8705401.18',
      resolucion: 'RD N° 299-2017-ANA-AAA.XII.UV',
      fuenteDeAgua: 'Superficial / Quebrada Sin Nombre (S/N)',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Saniri',
      e: '708696',
      n: '8717709',
      resolucion: 'RD N° 269-2017-ANA-AAA-XII.UV',
      fuenteDeAgua: 'Superficial / Quebrada Pocaruro',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Km 24+700 Mipaya',
      e: '717895',
      n: '8710539',
      resolucion: 'RD N° 294-2017-ANA-AAA.XII.UV',
      fuenteDeAgua: 'Superficial / Quebrada Sin Nombre (S/N)',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Km 20 San Martin',
      e: '738001',
      n: '8694929',
      resolucion: 'RD N° 387-2022-ANA-AAA.UV',
      fuenteDeAgua: 'Superficial / Quebrada Sin Nombre (S/N)',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Km 19 Cashiriari',
      e: '737211',
      n: '8685727',
      resolucion: 'RD N°006-2018-ANA-AAA-XII.UV',
      fuenteDeAgua: 'Superficial / Rio Casfiriari',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Km 39 Cashiriari',
      e: '751698',
      n: '8683217',
      resolucion: 'RD 686-2017-ANA-AAA-XII.UV',
      fuenteDeAgua: 'Superficial / Quebrada Surucari',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Km 3.75 San Martin',
      e: '745501',
      n: '8697381',
      resolucion: 'RD N° 403-2022-ANA-AAA.UV',
      fuenteDeAgua: 'Superficial / Quebrada Tsonqori',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Campamento Km 9 + 600',
      e: '738985',
      n: '8684531',
      resolucion: 'RD N° 0363-2022-ANA-AAA.UV',
      fuenteDeAgua: 'Superficial / Rio Casfiriari',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Kp 17+500',
      e: '731969',
      n: '8494843',
      resolucion: 'RD N° 0107-2023-ANA-AAA.UV',
      fuenteDeAgua: 'Superficial S/N N°3',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Kp 23+500',
      e: '726988',
      n: '8688512',
      resolucion: 'RD N° 0262-2024-ANA-AAA.UV',
      fuenteDeAgua: 'Superficial / Quebrada Porocari',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Cashiriari 1',
      e: '747819',
      n: '8687110',
      resolucion: 'RD N° 297-2016-ANA/AAA.XII.UV',
      fuenteDeAgua: 'Superficial / Quebrada Tornillo',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
    CampamentoData(
      nombre: 'Pagoreni B',
      e: '723045',
      n: '8705884',
      resolucion: 'RD N° 251-2016-ANA/AAA.XII.UV',
      fuenteDeAgua: 'Superficial - Rio Urubamba',
      tipoDeUso: 'Poblacional',
      claseDeDerecho: 'Licencia',
    ),
  ];

  // Controladores de la sección principal
  final _campamentoController = TextEditingController();
  final _resolucionController = TextEditingController();
  final _fuenteController = TextEditingController();
  final _usoController = TextEditingController();
  final _fechaController = TextEditingController();
  final _responsableController = TextEditingController();
  final _empresaController = TextEditingController();

  // Controladores para los campos de coordenadas
  final _norteController = TextEditingController();
  final _esteController = TextEditingController();
  final _mesController = TextEditingController();
  final _anoController = TextEditingController();

  // Variable para manejar la selección de Clase de Derecho
  String? _selectedDerecho;

  // Controladores para la sección de Ingreso
  final _ingresoHoraLecturaInicialController = TextEditingController();
  final _ingresoHoraLecturaFinalController = TextEditingController();
  final _ingresoLecturaInicialController = TextEditingController();
  final _ingresoLecturaFinalController = TextEditingController();
  final _ingresoVolumenAguaController = TextEditingController();
  final _ingresoTiempoOperacionController = TextEditingController();

  // Controladores para la sección de Salida
  final _salidaHoraLecturaInicialController = TextEditingController();
  final _salidaLecturaInicialController = TextEditingController();
  final _salidaHoraLecturaFinalController = TextEditingController();
  final _salidaLecturaFinalController = TextEditingController();
  final _salidaConsumoDiarioController = TextEditingController();

  // Variable de estado para el selector
  RegistroTipo _selectedRegistro = RegistroTipo.ingreso;

  // Variables para el dropdown con búsqueda
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final GlobalKey _campamentoKey = GlobalKey();
  bool _isDropdownOpen = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingReport != null) {
      _loadExistingReportData();
    } else {
      _setDefaultValues();
    }

    _ingresoLecturaInicialController.addListener(_calculateVolumenAgua);
    _ingresoLecturaFinalController.addListener(_calculateVolumenAgua);
    // --- NUEVOS LISTENERS PARA LA SECCIÓN DE SALIDA ---
    _salidaLecturaInicialController.addListener(_calculateConsumoDiario);
    _salidaLecturaFinalController.addListener(_calculateConsumoDiario);
  }

  void _loadExistingReportData() {
    final report = widget.existingReport!;
    _fechaController.text =
        report['fecha'] != null
            ? DateFormat('dd/MM/yyyy').format(DateTime.parse(report['fecha']))
            : '';
    _empresaController.text = report['empresa'] ?? '';
    _campamentoController.text = report['campamento'] ?? '';
    _resolucionController.text = report['resolucion'] ?? '';
    _fuenteController.text = report['fuente_de_agua'] ?? '';
    _usoController.text = report['tipo_de_uso'] ?? '';
    _responsableController.text = report['responsable'] ?? '';
    _norteController.text = report['coordenada_n'] ?? '';
    _esteController.text = report['coordenada_e'] ?? '';
    _mesController.text = report['mes'] ?? '';
    _anoController.text = report['ano'] ?? '';
    _selectedDerecho = report['clase_de_derecho'];

    _ingresoHoraLecturaInicialController.text =
        report['ingreso_hora_lectura_inicial'] ?? '';
    _ingresoHoraLecturaFinalController.text =
        report['ingreso_hora_lectura_final'] ?? '';
    _ingresoLecturaInicialController.text =
        report['ingreso_lectura_inicial']?.toString() ?? '';
    _ingresoLecturaFinalController.text =
        report['ingreso_lectura_final']?.toString() ?? '';
    _ingresoVolumenAguaController.text =
        report['ingreso_volumen_agua']?.toString() ?? '';
    _ingresoTiempoOperacionController.text =
        report['ingreso_tiempo_operacion']?.toString() ?? '';

    _salidaHoraLecturaInicialController.text =
        report['salida_hora_lectura_inicial'] ?? '';
    _salidaHoraLecturaFinalController.text =
        report['salida_hora_lectura_final'] ?? '';
    _salidaLecturaInicialController.text =
        report['salida_lectura_inicial']?.toString() ?? '';
    _salidaLecturaFinalController.text =
        report['salida_lectura_final']?.toString() ?? '';
    _salidaConsumoDiarioController.text =
        report['salida_consumo_diario']?.toString() ?? '';
  }

  void _setDefaultValues() {
    final now = DateTime.now();
    _fechaController.text = DateFormat('dd/MM/yyyy').format(now);
    _empresaController.text = 'Techint';
    _mesController.text = DateFormat('MM').format(now);
    _anoController.text = DateFormat('yyyy').format(now);
    _fetchCurrentUserData();
  }

  Future<void> _fetchCurrentUserData() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final response =
            await supabase
                .from('profiles')
                .select('nombres, apellido')
                .eq('id', user.id)
                .single();
        if (mounted) {
          setState(() {
            final nombres = response['nombres'] ?? '';
            final apellido = response['apellido'] ?? '';
            final fullName = '$nombres $apellido'.trim();
            _responsableController.text =
                fullName.isNotEmpty ? fullName : 'No definido';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _responsableController.text = 'Error al cargar usuario';
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _ingresoLecturaInicialController.removeListener(_calculateVolumenAgua);
    _ingresoLecturaFinalController.removeListener(_calculateVolumenAgua);
    // --- ELIMINAR LISTENERS DE SALIDA ---
    _salidaLecturaInicialController.removeListener(_calculateConsumoDiario);
    _salidaLecturaFinalController.removeListener(_calculateConsumoDiario);

    _hideDropdownOverlay();
    _campamentoController.dispose();
    _resolucionController.dispose();
    _fuenteController.dispose();
    _usoController.dispose();
    _fechaController.dispose();
    _responsableController.dispose();
    _empresaController.dispose();
    _norteController.dispose();
    _esteController.dispose();
    _mesController.dispose();
    _anoController.dispose();
    _ingresoHoraLecturaInicialController.dispose();
    _ingresoHoraLecturaFinalController.dispose();
    _ingresoLecturaInicialController.dispose();
    _ingresoLecturaFinalController.dispose();
    _ingresoVolumenAguaController.dispose();
    _ingresoTiempoOperacionController.dispose();
    _salidaHoraLecturaInicialController.dispose();
    _salidaLecturaInicialController.dispose();
    _salidaHoraLecturaFinalController.dispose();
    _salidaLecturaFinalController.dispose();
    _salidaConsumoDiarioController.dispose();
    super.dispose();
  }

  void _calculateVolumenAgua() {
    final double lecturaInicial =
        double.tryParse(_ingresoLecturaInicialController.text) ?? 0.0;
    final double lecturaFinal =
        double.tryParse(_ingresoLecturaFinalController.text) ?? 0.0;

    if (lecturaFinal >= lecturaInicial) {
      final double volumen = lecturaFinal - lecturaInicial;
      _ingresoVolumenAguaController.text = volumen.toStringAsFixed(2);
    } else {
      _ingresoVolumenAguaController.text = '0.00';
    }
  }

  // --- NUEVA FUNCIÓN PARA CALCULAR EL CONSUMO DIARIO ---
  void _calculateConsumoDiario() {
    final double lecturaInicial =
        double.tryParse(_salidaLecturaInicialController.text) ?? 0.0;
    final double lecturaFinal =
        double.tryParse(_salidaLecturaFinalController.text) ?? 0.0;

    if (lecturaFinal >= lecturaInicial) {
      final double consumo = lecturaFinal - lecturaInicial;
      _salidaConsumoDiarioController.text = consumo.toStringAsFixed(2);
    } else {
      _salidaConsumoDiarioController.text = '0.00';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userId = supabase.auth.currentUser!.id;
        final profileResponse =
            await supabase
                .from('profiles')
                .select('id')
                .eq('id', userId)
                .single();
        final profileId = profileResponse['id'];

        final data = {
          'user_id': userId,
          'profile_id': profileId,
          'fecha': DateFormat(
            'yyyy-MM-dd',
          ).format(DateFormat('dd/MM/yyyy').parse(_fechaController.text)),
          'empresa': _empresaController.text,
          'campamento': _campamentoController.text,
          'resolucion': _resolucionController.text,
          'fuente_de_agua': _fuenteController.text,
          'tipo_de_uso': _usoController.text,
          'responsable': _responsableController.text,
          'coordenada_n': _norteController.text,
          'coordenada_e': _esteController.text,
          'mes': _mesController.text,
          'ano': _anoController.text,
          'clase_de_derecho': _selectedDerecho,
          'ingreso_hora_lectura_inicial':
              _ingresoHoraLecturaInicialController.text.isNotEmpty
                  ? _ingresoHoraLecturaInicialController.text
                  : null,
          'ingreso_hora_lectura_final':
              _ingresoHoraLecturaFinalController.text.isNotEmpty
                  ? _ingresoHoraLecturaFinalController.text
                  : null,
          'ingreso_lectura_inicial': double.tryParse(
            _ingresoLecturaInicialController.text,
          ),
          'ingreso_lectura_final': double.tryParse(
            _ingresoLecturaFinalController.text,
          ),
          'ingreso_volumen_agua': double.tryParse(
            _ingresoVolumenAguaController.text,
          ),
          'ingreso_tiempo_operacion': double.tryParse(
            _ingresoTiempoOperacionController.text,
          ),
          'salida_hora_lectura_inicial':
              _salidaHoraLecturaInicialController.text.isNotEmpty
                  ? _salidaHoraLecturaInicialController.text
                  : null,
          'salida_hora_lectura_final':
              _salidaHoraLecturaFinalController.text.isNotEmpty
                  ? _salidaHoraLecturaFinalController.text
                  : null,
          'salida_lectura_inicial': double.tryParse(
            _salidaLecturaInicialController.text,
          ),
          'salida_lectura_final': double.tryParse(
            _salidaLecturaFinalController.text,
          ),
          'salida_consumo_diario': double.tryParse(
            _salidaConsumoDiarioController.text,
          ),
        };

        if (widget.existingReport == null) {
          await supabase.from('water_reports').insert(data);
        } else {
          final reportId = widget.existingReport!['id'];
          await supabase.from('water_reports').update(data).eq('id', reportId);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reporte guardado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } on PostgrestException catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${error.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ocurrió un error inesperado: $error'),
              backgroundColor: Colors.red,
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

  Future<void> _selectDate() async {
    _hideDropdownOverlay();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0077B6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.grey[200],
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0077B6),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fechaController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    _hideDropdownOverlay();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0077B6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.grey[200],
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0077B6),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hour:$minute';
      });
    }
  }

  void _toggleDropdown() {
    if (_isDropdownOpen) {
      _hideDropdownOverlay();
    } else {
      _showDropdownOverlay();
    }
  }

  void _hideDropdownOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
      if (mounted) {
        setState(() {
          _isDropdownOpen = false;
        });
      }
    }
  }

  void _showDropdownOverlay() {
    final renderBox =
        _campamentoKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            width: size.width,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, size.height + 5.0),
              child: Material(
                elevation: 4.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildDropdownList(),
              ),
            ),
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isDropdownOpen = true;
    });
  }

  Widget _buildDropdownList() {
    final searchController = TextEditingController();
    List<CampamentoData> filteredCampamentos = List.from(campamentos);

    return StatefulBuilder(
      builder: (context, setDialogState) {
        return SizedBox(
          height: 250,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    isDense: true,
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFF0077B6),
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      filteredCampamentos =
                          campamentos
                              .where(
                                (c) => c.nombre.toLowerCase().contains(
                                  value.toLowerCase(),
                                ),
                              )
                              .toList();
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: filteredCampamentos.length,
                  itemBuilder: (context, index) {
                    final campamento = filteredCampamentos[index];
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                      title: Text(
                        campamento.nombre,
                        style: const TextStyle(fontSize: 13),
                      ),
                      onTap: () {
                        setState(() {
                          _campamentoController.text = campamento.nombre;
                          _resolucionController.text = campamento.resolucion;
                          _fuenteController.text = campamento.fuenteDeAgua;
                          _usoController.text = campamento.tipoDeUso;
                          _norteController.text = campamento.n;
                          _esteController.text = campamento.e;
                          _selectedDerecho = campamento.claseDeDerecho;
                        });
                        _hideDropdownOverlay();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isDropdownOpen) {
          _hideDropdownOverlay();
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onTap: _hideDropdownOverlay,
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF4F6F6),
                      // AÑADIMOS SAFEAERA PARA EVITAR QUE EL SISTEMA OPERATIVO OCULTE LA UI
                      child: SafeArea(
                        top: false, // No aplicar padding superior
                        left: false, // No aplicar padding izquierdo
                        right: false, // No aplicar padding derecho
                        child: _buildForm(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (!_isDropdownOpen) {
                Navigator.of(context).pop();
              } else {
                _hideDropdownOverlay();
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Control de Agua',
                  style: TextStyle(
                    fontSize: (screenWidth * 0.06).clamp(22.0, 28.0),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Registro Diario de Consumo',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
            onPressed: _isLoading ? null : _submitForm,
            tooltip: 'Guardar Reporte',
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _buildSectionTitle("Información General"),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fechaController,
                  label: 'Fecha',
                  hint: 'DD/MM/YYYY',
                  prefixIcon: Icons.calendar_today,
                  readOnly: true,
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _empresaController,
                  label: 'Empresa',
                  hint: 'Constructora ABC',
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CompositedTransformTarget(
                  link: _layerLink,
                  child: _buildTextField(
                    key: _campamentoKey,
                    controller: _campamentoController,
                    label: 'Campamento y/o PK:',
                    hint: 'Seleccione un campamento',
                    readOnly: true,
                    onTap: _toggleDropdown,
                    suffixIcon:
                        _isDropdownOpen
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _resolucionController,
                  label: 'Tipo / N° Resolución:',
                  hint: 'Tipo de resolución',
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fuenteController,
                  label: 'Fuente de Agua:',
                  hint: 'Fuente de agua',
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _usoController,
                  label: 'Tipo de uso del agua:',
                  hint: 'Uso del agua',
                  readOnly: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _responsableController,
            label: 'Responsable del Registro',
            hint: 'Juan Pérez',
            readOnly: true,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Coordenadas UTM (WGS 84)'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _norteController,
                  label: 'N',
                  hint: 'Norte',
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _esteController,
                  label: 'E',
                  hint: 'Este',
                  keyboardType: TextInputType.number,
                  readOnly: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _mesController,
                  label: 'Mes',
                  hint: 'MM',
                  readOnly: true,
                  keyboardType: TextInputType.datetime,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _anoController,
                  label: 'Año',
                  hint: 'YYYY',
                  readOnly: true,
                  keyboardType: TextInputType.datetime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('Clase de Derecho'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 1),
              _buildDerechoOption('Licencia'),
              const SizedBox(width: 10),
              _buildDerechoOption('Permiso'),
              const SizedBox(width: 10),
              _buildDerechoOption('Autorización'),
              const Spacer(flex: 1),
            ],
          ),
          const SizedBox(height: 20),
          _buildRegistroSelector(),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child:
                _selectedRegistro == RegistroTipo.ingreso
                    ? _buildIngresoSection()
                    : _buildSalidaSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistroSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: Row(
        children: [
          _buildSelectorOption('Ingreso', RegistroTipo.ingreso),
          _buildSelectorOption('Salida', RegistroTipo.salida),
        ],
      ),
    );
  }

  Widget _buildSelectorOption(String title, RegistroTipo tipo) {
    final isSelected = _selectedRegistro == tipo;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRegistro = tipo;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0077B6) : Colors.transparent,
            borderRadius: BorderRadius.circular(25.0),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIngresoSection() {
    return Column(
      key: const ValueKey('ingreso'),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _ingresoHoraLecturaInicialController,
                label: 'Hora Lectura Inicial',
                hint: '00:00',
                prefixIcon: Icons.watch_later_outlined,
                readOnly: true,
                onTap: () => _selectTime(_ingresoHoraLecturaInicialController),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _ingresoHoraLecturaFinalController,
                label: 'Hora Lectura Final',
                hint: '00:00',
                prefixIcon: Icons.watch_later_outlined,
                readOnly: true,
                onTap: () => _selectTime(_ingresoHoraLecturaFinalController),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _ingresoLecturaInicialController,
                label: 'Lectura Inicial',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _ingresoLecturaFinalController,
                label: 'Lectura Final',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _ingresoVolumenAguaController,
                label: 'Volumen de Agua (m³)',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _ingresoTiempoOperacionController,
                label: 'Tiempo de Operación (hrs)',
                hint: '0.0',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalidaSection() {
    return Column(
      key: const ValueKey('salida'),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _salidaHoraLecturaInicialController,
                label: 'Hora Lectura Inicial',
                hint: '00:00',
                prefixIcon: Icons.watch_later_outlined,
                readOnly: true,
                onTap: () => _selectTime(_salidaHoraLecturaInicialController),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _salidaHoraLecturaFinalController,
                label: 'Hora Lectura Final',
                hint: '00:00',
                prefixIcon: Icons.watch_later_outlined,
                readOnly: true,
                onTap: () => _selectTime(_salidaHoraLecturaFinalController),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildTextField(
                controller: _salidaLecturaInicialController,
                label: 'Lectura Inicial',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _salidaLecturaFinalController,
                label: 'Lectura Final',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _salidaConsumoDiarioController,
          label: 'Consumo Diario (m³)',
          hint: '0.00',
          readOnly: true, // <-- CAMPO HECHO DE SOLO LECTURA
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildDerechoOption(String title) {
    final isSelected = _selectedDerecho == title;
    return Expanded(
      flex: 2,
      child: OutlinedButton(
        onPressed: () {
          setState(() {
            _selectedDerecho = title;
          });
        },
        style: OutlinedButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor:
              isSelected ? const Color(0xFF0077B6) : Colors.black54,
          backgroundColor:
              isSelected
                  ? const Color(0xFF00B4D8).withOpacity(0.1)
                  : Colors.white,
          side: BorderSide(
            color: isSelected ? const Color(0xFF0077B6) : Colors.grey.shade300,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 4),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    Key? key,
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon:
                prefixIcon != null
                    ? Icon(prefixIcon, size: 18, color: Colors.grey.shade600)
                    : null,
            suffixIcon:
                suffixIcon != null
                    ? Icon(suffixIcon, size: 22, color: Colors.grey.shade600)
                    : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            suffixIconConstraints: const BoxConstraints(maxHeight: 22),
            isDense: true,
            filled: true,
            fillColor: readOnly ? Colors.grey.shade200 : Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF0077B6),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 10,
            ),
          ),
          validator: (value) {
            if (!readOnly && (value == null || value.isEmpty)) {
              return 'Este campo no puede estar vacío';
            }
            if (label.contains('Campamento') &&
                (value == null || value.isEmpty)) {
              return 'Seleccione una opción';
            }
            return null;
          },
        ),
      ],
    );
  }
}
