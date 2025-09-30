import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recycle_app/main.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// --- MODELOS DE DATOS ---
class ResiduoItem {
  final String nombre;
  final List<TextEditingController> controllers = List.generate(
    7,
    (_) => TextEditingController(text: '0'),
  );
  final List<FocusNode> focusNodes = List.generate(7, (_) => FocusNode());

  ResiduoItem({required this.nombre});

  double getTotal() {
    return controllers.fold(
      0.0,
      (sum, ctrl) => sum + (double.tryParse(ctrl.text) ?? 0.0),
    );
  }

  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
  }
}

class CategoriaResiduos {
  final String titulo;
  final String emoji;
  final Color color;
  final String unidad;
  final List<ResiduoItem> items;
  bool isExpanded;

  CategoriaResiduos({
    required this.titulo,
    required this.emoji,
    required this.color,
    this.unidad = 'Kg',
    required this.items,
    this.isExpanded = false,
  });

  double getTotal() {
    return items.fold(0.0, (sum, item) => sum + item.getTotal());
  }

  void dispose() {
    for (var item in items) {
      item.dispose();
    }
  }
}

class UploadReportPage extends StatefulWidget {
  final Map<String, dynamic>? existingReport;

  const UploadReportPage({super.key, this.existingReport});

  @override
  State<UploadReportPage> createState() => _UploadReportPageState();
}

class _UploadReportPageState extends State<UploadReportPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controladores y variables
  final _semanaController = TextEditingController();
  final _flowlineController = TextEditingController();
  final _progresivaController = TextEditingController();
  final _actividadController = TextEditingController();
  final _numeroGuiaController = TextEditingController();
  final _campamentoSearchController = TextEditingController();

  DateTimeRange? _selectedDateRange;
  String? _selectedCampamento;
  String? _selectedArea;
  bool _isLoading = false;
  bool _loadingEditData = false;

  final List<String> _campamentos = [
    'Campamento 9+600',
    'Campamento 17+500',
    'Campamento 19+000',
    'Campamento 23+500',
    'Campamento 39+000',
    'Campamento Cashiriari 01',
    'Campamento 3+750',
    'Campamento Km 20',
    'Campamento Km 24+700',
    'Campamento Pag. 1X',
    'Campamento Pag. B',
    'Campamento Saniri',
    'Campamento Malvinas',
    'Obra Menor Diverter Pit',
    'Obra Menor PK 24+420',
    'Obra Menor PK 31+200',
    'Obra Menor PK 31+010',
    'San Martin 3 (Cluster)',
    'Campamento Mipaya (Cluster)',
  ];
  final List<String> _areas = ['Mantenimiento', 'AID'];

  late List<CategoriaResiduos> _categorias;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    _selectedDateRange = DateTimeRange(start: startOfWeek, end: endOfWeek);

    final dateFormat = DateFormat('dd/MM/yyyy');
    _semanaController.text =
        '${dateFormat.format(_selectedDateRange!.start)} - ${dateFormat.format(_selectedDateRange!.end)}';

    if (widget.existingReport != null) {
      _loadExistingReport(widget.existingReport!);
    }

    _categorias = [
      CategoriaResiduos(
        titulo: 'Residuos Orgánicos',
        emoji: '🍎',
        color: Colors.orange.shade800,
        items: [
          ResiduoItem(nombre: 'Residuos de comida'),
          ResiduoItem(nombre: 'Parihuelas de madera - Reuso (aprovechables)'),
          ResiduoItem(nombre: 'Cajas de madera - Reuso (aprovechables)'),
        ],
        isExpanded: true,
      ),
      CategoriaResiduos(
        titulo: 'Papel y Cartón',
        emoji: '📦',
        color: Colors.blue.shade700,
        items: [ResiduoItem(nombre: 'Papel/Cartón')],
      ),
      CategoriaResiduos(
        titulo: 'Plásticos',
        emoji: '🛍️',
        color: Colors.white,
        items: [
          ResiduoItem(nombre: 'Plástico PET (botellas)'),
          ResiduoItem(nombre: 'PVC'),
          ResiduoItem(nombre: 'Plástico duro'),
          ResiduoItem(nombre: 'Geomembrana'),
          ResiduoItem(nombre: 'Bolsas de plástico'),
          ResiduoItem(nombre: 'Neumáticos fuera de uso (llantas usadas)'),
          ResiduoItem(nombre: 'Sacos'),
          ResiduoItem(nombre: 'Strech film'),
        ],
      ),
      CategoriaResiduos(
        titulo: 'Metales',
        emoji: '🧲',
        color: Colors.yellow.shade700,
        items: [
          ResiduoItem(nombre: 'Residuos metálicos'),
          ResiduoItem(nombre: 'Restos de cables eléctricos'),
          ResiduoItem(nombre: 'Latas'),
          ResiduoItem(
            nombre: 'Residuos de aparatos eléctricos y electrónicos (RAEE)',
          ),
        ],
      ),
      CategoriaResiduos(
        titulo: 'Vidrio',
        emoji: '🍾',
        color: Colors.grey.shade700,
        items: [
          ResiduoItem(nombre: 'Vidrio'),
          ResiduoItem(nombre: 'Cerámicas'),
        ],
      ),
      CategoriaResiduos(
        titulo: 'No Aprovechables',
        emoji: '🗑️',
        color: Colors.black,
        items: [
          ResiduoItem(nombre: 'Restos de madera'),
          ResiduoItem(nombre: 'Bolsas plásticas no aprovechables'),
          ResiduoItem(nombre: 'Restos de concreto'),
          ResiduoItem(nombre: 'Filtros usados'),
          ResiduoItem(nombre: 'Residuos textiles'),
          ResiduoItem(nombre: 'Colchones en desuso'),
          ResiduoItem(nombre: 'EPP usados'),
          ResiduoItem(nombre: 'Jebes'),
          ResiduoItem(nombre: 'Garnet o granete'),
          ResiduoItem(nombre: 'Tecknopor'),
          ResiduoItem(nombre: 'Todo Plastico no aprovechables '),
          ResiduoItem(nombre: 'Envase de alimentos'),
          ResiduoItem(nombre: 'Restos de alimentos termicos'),
          ResiduoItem(nombre: 'Papel Higienico Usado'),
          ResiduoItem(nombre: 'Papel y Carton no Probechable'),
          ResiduoItem(nombre: 'Cables electricos no aprovechables'),
          ResiduoItem(nombre: 'Restos de Cal'),
        ],
      ),
      CategoriaResiduos(
        titulo: 'Peligrosos Solidos Aprovechables',
        emoji: '☣️',
        color: Colors.red.shade700,
        items: [
          ResiduoItem(nombre: 'Baterías de ácido - plomo usadas'),
          ResiduoItem(nombre: 'Baterías Niquel-Cadmio'),
          ResiduoItem(nombre: 'Cartuchos de impresora'),
        ],
      ),
      CategoriaResiduos(
        titulo: 'Peligrosos Solidos No Aprovechables',
        emoji: '☢️',
        color: Colors.red.shade700,
        items: [
          ResiduoItem(nombre: 'Suelo/Tierra contaminada con Hidrocarburo'),
          ResiduoItem(nombre: 'Floculos'),
          ResiduoItem(nombre: 'Recipientes de gases comprimidos en desuso'),
          ResiduoItem(nombre: 'Residuos biocontaminados'),
          ResiduoItem(nombre: 'Tubos fluorescentes'),
          ResiduoItem(nombre: 'Pilas usadas'),
          ResiduoItem(nombre: 'Arena / grava cama de secado'),
          ResiduoItem(nombre: 'Cajas de madera contaminada con pintura'),
          ResiduoItem(
            nombre: 'Cilindros metálicos contaminados con hidrocarburo',
          ),
          ResiduoItem(
            nombre: 'Parihuelas de madera contaminadas con hidrocarburo',
          ),
          ResiduoItem(
            nombre:
                'Recipientes bulk drum vacios (impregnados con hidrocarburo)',
          ),
          ResiduoItem(nombre: 'Residuos sólidos contaminados con solventes'),
          ResiduoItem(nombre: 'Borra sólida con hidrocarburo '),
          ResiduoItem(nombre: 'Restos de yeso / drywall'),
          ResiduoItem(
            nombre: 'Restos de soldadura, discos de corte y esmerilado',
          ),
          ResiduoItem(nombre: 'Residuos sólidos contaminados con quimicos'),
        ],
      ),
      CategoriaResiduos(
        titulo: 'Peligrosos Liquidos Aprovechables',
        emoji: '🥛',
        color: Colors.red.shade700,
        items: [
          ResiduoItem(nombre: 'Aceite mineral residual (aceite quemado)'),
          ResiduoItem(nombre: 'Aceite vegetal (frituras)'),
        ],
      ),
      CategoriaResiduos(
        titulo: 'Peligrosos Liquidos No Aprovechables',
        emoji: '🧴',
        color: Colors.red.shade700,
        items: [
          ResiduoItem(nombre: 'Grasas (Trampas de cocina)'),
          ResiduoItem(nombre: 'Lixiviado de compactacion (grasas y sólidos)'),
          ResiduoItem(nombre: 'Floculantes'),
          ResiduoItem(nombre: 'Residuos de baños portátiles'),
          ResiduoItem(nombre: 'Refrigerante residual'),
          ResiduoItem(nombre: 'Pintura residual'),
          ResiduoItem(nombre: 'Lodos domésticos residuales'),
          ResiduoItem(nombre: 'Emulsión de hidrocarburo con agua y aceite'),
          ResiduoItem(nombre: 'Agua con floculante'),
          ResiduoItem(nombre: 'Residuo líquido contaminado con químico'),
        ],
      ),
      CategoriaResiduos(
        titulo: 'Trabajadores',
        emoji: '👷',
        color: Colors.green.shade700,
        unidad: 'Nro',
        items: [
          ResiduoItem(nombre: 'Cantidad de trabajadores en el campamento'),
        ],
      ),
    ];

    _setupFocusNodeListeners();

    for (var categoria in _categorias) {
      for (var item in categoria.items) {
        for (var controller in item.controllers) {
          controller.addListener(() => setState(() {}));
        }
      }
    }
  }

  void _setupFocusNodeListeners() {
    for (var categoria in _categorias) {
      for (var item in categoria.items) {
        for (int i = 0; i < item.focusNodes.length; i++) {
          item.focusNodes[i].addListener(() {
            if (item.focusNodes[i].hasFocus) {
              if (item.controllers[i].text == '0') {
                item.controllers[i].clear();
                setState(() {});
              }
            } else {
              if (item.controllers[i].text.isEmpty) {
                item.controllers[i].text = '0';
                setState(() {});
              }
            }
          });
        }
      }
    }
  }

  void _loadExistingReport(Map<String, dynamic> report) {
    _semanaController.text = report['semana'] ?? '';
    _flowlineController.text = report['flowline'] ?? '';
    _progresivaController.text = report['progresiva'] ?? '';
    _actividadController.text = report['actividad'] ?? '';
    _numeroGuiaController.text = report['numero_guia'] ?? '';
    _selectedCampamento = report['campamento'];
    _selectedArea = report['area'];

    if (report['fecha_inicio'] != null && report['fecha_fin'] != null) {
      try {
        _selectedDateRange = DateTimeRange(
          start: DateTime.parse(report['fecha_inicio']),
          end: DateTime.parse(report['fecha_fin']),
        );
      } catch (e) {
        debugPrint('Error al parsear fechas: $e');
      }
    }

    _loadCategoriesAndItems(report['id'] as String);
  }

  Future<void> _loadCategoriesAndItems(String reportId) async {
    setState(() => _loadingEditData = true);

    try {
      final supabase = Supabase.instance.client;
      final categoriesResponse = await supabase
          .from('report_categories')
          .select('id, categoria_nombre, unidad, total_categoria')
          .eq('report_id', reportId);

      for (var categoryData in categoriesResponse) {
        final categoryId = categoryData['id'] as String;
        final itemsResponse = await supabase
            .from('report_items')
            .select(
              'item_nombre, lunes, martes, miercoles, jueves, viernes, sabado, domingo, total_item',
            )
            .eq('category_id', categoryId);

        final categoriaNombre = categoryData['categoria_nombre'] as String;
        final categoriaIndex = _categorias.indexWhere(
          (cat) => cat.titulo == categoriaNombre,
        );

        if (categoriaIndex != -1) {
          final categoria = _categorias[categoriaIndex];
          for (var itemData in itemsResponse) {
            final itemNombre = itemData['item_nombre'] as String;
            final itemIndex = categoria.items.indexWhere(
              (it) => it.nombre == itemNombre,
            );

            if (itemIndex != -1) {
              final item = categoria.items[itemIndex];
              item.controllers[0].text = (itemData['lunes'] as num)
                  .toStringAsFixed(0);
              item.controllers[1].text = (itemData['martes'] as num)
                  .toStringAsFixed(0);
              item.controllers[2].text = (itemData['miercoles'] as num)
                  .toStringAsFixed(0);
              item.controllers[3].text = (itemData['jueves'] as num)
                  .toStringAsFixed(0);
              item.controllers[4].text = (itemData['viernes'] as num)
                  .toStringAsFixed(0);
              item.controllers[5].text = (itemData['sabado'] as num)
                  .toStringAsFixed(0);
              item.controllers[6].text = (itemData['domingo'] as num)
                  .toStringAsFixed(0);
            }
          }
        }
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error al cargar categorías e items: $e');
    } finally {
      if (mounted) setState(() => _loadingEditData = false);
    }
  }

  @override
  void dispose() {
    _semanaController.dispose();
    _flowlineController.dispose();
    _progresivaController.dispose();
    _actividadController.dispose();
    _numeroGuiaController.dispose();
    _campamentoSearchController.dispose();

    for (var categoria in _categorias) {
      categoria.dispose();
    }
    super.dispose();
  }

  double _getTotalKilos() {
    return _categorias.fold(0.0, (sum, categoria) {
      if (categoria.titulo != 'Trabajadores') {
        return sum + categoria.getTotal();
      }
      return sum;
    });
  }

  double _getTotalTrabajadores() {
    return _categorias.fold(0.0, (sum, categoria) {
      if (categoria.titulo == 'Trabajadores') {
        return sum + categoria.getTotal();
      }
      return sum;
    });
  }

  int _getTotalDias() {
    final dateRange =
        _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 6)),
        );
    return dateRange.end.difference(dateRange.start).inDays + 1;
  }

  bool _hayCambios() {
    if (widget.existingReport == null) return true;
    final existing = widget.existingReport!;
    if (_semanaController.text != (existing['semana'] ?? '') ||
        _selectedCampamento != existing['campamento'] ||
        _selectedArea != existing['area'] ||
        _flowlineController.text != (existing['flowline'] ?? '') ||
        _progresivaController.text != (existing['progresiva'] ?? '') ||
        _actividadController.text != (existing['actividad'] ?? '') ||
        _numeroGuiaController.text != (existing['numero_guia'] ?? '')) {
      return true;
    }
    for (var categoria in _categorias) {
      if (categoria.getTotal() > 0) return true;
    }
    return false;
  }

  Future<void> _updateExistingCategoriesAndItems(String reportId) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('report_items').delete().eq('report_id', reportId);
      await supabase
          .from('report_categories')
          .delete()
          .eq('report_id', reportId);
      await _createCategoriesAndItems(reportId, supabase.auth.currentUser!.id);
    } catch (e) {
      debugPrint('❌ Error en actualización: $e');
      throw e;
    }
  }

  Future<void> _createCategoriesAndItems(String reportId, String userId) async {
    try {
      final supabase = Supabase.instance.client;
      for (var categoria in _categorias) {
        if (categoria.getTotal() <= 0) continue;
        final categoryResponse =
            await supabase
                .from('report_categories')
                .insert({
                  'report_id': reportId,
                  'categoria_nombre': categoria.titulo,
                  'unidad': categoria.unidad,
                  'total_categoria': categoria.getTotal(),
                })
                .select()
                .single();
        final categoryId = categoryResponse['id'] as String;
        for (var item in categoria.items) {
          if (item.getTotal() > 0) {
            await supabase.from('report_items').insert({
              'category_id': categoryId,
              'report_id': reportId,
              'item_nombre': item.nombre,
              'lunes': double.tryParse(item.controllers[0].text) ?? 0,
              'martes': double.tryParse(item.controllers[1].text) ?? 0,
              'miercoles': double.tryParse(item.controllers[2].text) ?? 0,
              'jueves': double.tryParse(item.controllers[3].text) ?? 0,
              'viernes': double.tryParse(item.controllers[4].text) ?? 0,
              'sabado': double.tryParse(item.controllers[5].text) ?? 0,
              'domingo': double.tryParse(item.controllers[6].text) ?? 0,
              'total_item': item.getTotal(),
            });
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error al crear categorías: $e');
      throw e;
    }
  }

  // --- NUEVA FUNCIÓN DE VALIDACIÓN ---
  Future<bool> _checkExistingReport() async {
    if (_selectedCampamento == null || _semanaController.text.isEmpty) {
      return true; // Pasa la validación si los datos están incompletos, el validador del formulario lo detectará.
    }

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      var query = supabase
          .from('weekly_reports')
          .select('id')
          .eq('user_id', userId)
          .eq('campamento', _selectedCampamento!)
          .eq('semana', _semanaController.text);

      // Si se está editando, excluye el reporte actual de la verificación.
      if (widget.existingReport != null) {
        query = query.not('id', 'eq', widget.existingReport!['id']);
      }

      final response = await query;

      if (response.isNotEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ya existe un reporte para este campamento en la semana seleccionada.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return false; // Se encontró un duplicado, la validación falla.
      }

      return true; // No se encontró duplicado, la validación pasa.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al verificar reportes existentes: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false; // Falla la validación en caso de error.
    }
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.existingReport != null && !_hayCambios()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se detectaron cambios para guardar'),
            backgroundColor: Colors.blue,
          ),
        );
        Navigator.pop(context, false);
      }
      return;
    }
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, selecciona una semana para el reporte.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);

    // --- VERIFICACIÓN DE REPORTE EXISTENTE ---
    final canSave = await _checkExistingReport();
    if (!canSave) {
      setState(
        () => _isLoading = false,
      ); // Detiene la carga y retorna si se encuentra un duplicado.
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final reportData = {
        'semana': _semanaController.text,
        'fecha_inicio':
            _selectedDateRange!.start.toIso8601String().split('T')[0],
        'fecha_fin': _selectedDateRange!.end.toIso8601String().split('T')[0],
        'campamento': _selectedCampamento ?? '',
        'area': _selectedArea ?? '',
        'flowline': _flowlineController.text,
        'progresiva': _progresivaController.text,
        'actividad': _actividadController.text,
        'numero_guia':
            _numeroGuiaController.text.isNotEmpty
                ? _numeroGuiaController.text
                : null,
        'total_kilos': _getTotalKilos(),
        'total_trabajadores': _getTotalTrabajadores().toInt(),
        'total_dias': _getTotalDias(),
        'status': 'in_progress',
        'updated_at': 'now()',
        'user_id': userId,
      };
      final profileResponse =
          await supabase
              .from('profiles')
              .select('id')
              .eq('id', userId)
              .single();
      reportData['profile_id'] = profileResponse['id'];
      String reportId;
      if (widget.existingReport != null) {
        reportId = widget.existingReport!['id'] as String;
        await supabase
            .from('weekly_reports')
            .update(reportData)
            .eq('id', reportId);
        await _updateExistingCategoriesAndItems(reportId);
      } else {
        reportData['created_at'] = 'now()';
        final response =
            await supabase
                .from('weekly_reports')
                .insert(reportData)
                .select()
                .single();
        reportId = response['id'] as String;
        await _createCategoriesAndItems(reportId, userId);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte guardado con éxito ✅'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (_loadingEditData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.1),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF16A085), Color(0xFF2ECC71)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    Text(
                      widget.existingReport != null
                          ? 'Editar Reporte'
                          : 'Nuevo Reporte',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: () {
            final isLastStep = _currentStep == getSteps(context).length - 1;
            if (_formKey.currentState!.validate()) {
              if (isLastStep) {
                _saveReport();
              } else {
                setState(() => _currentStep += 1);
              }
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep -= 1);
            }
          },
          steps: getSteps(context),
          controlsBuilder: (context, details) {
            final isLastStep = _currentStep == getSteps(context).length - 1;
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : Text(isLastStep ? 'Guardar' : 'Siguiente'),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepCancel,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black54,
                        ),
                        child: const Text('Volver'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // MODIFICADO: Se ajustó el estilo de los campos
  List<Step> getSteps(BuildContext context) {
    InputDecoration fieldDecoration(String label, {IconData? suffixIcon}) {
      return InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 20) : null,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      );
    }

    return [
      Step(
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 0,
        title: const Text('Información General'),
        content: Column(
          children: [
            const Center(
              child: Text(
                'REPORTE DE GENERACIÓN DE RESIDUOS',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _semanaController,
              readOnly: true,
              style: const TextStyle(fontSize: 13),
              decoration: fieldDecoration(
                'Semana',
                suffixIcon: Icons.calendar_today,
              ),
              onTap: () {},
              validator:
                  (value) => value!.isEmpty ? 'Selecciona una semana' : null,
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  // CAMBIO: Se ajustó el flex para cambiar el tamaño
                  flex: 3,
                  child: DropdownButtonFormField2<String>(
                    value: _selectedCampamento,
                    decoration: fieldDecoration('Campamento'),
                    isExpanded: true,
                    buttonStyleData: const ButtonStyleData(
                      height: 40,
                      padding: EdgeInsets.zero,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items:
                        _campamentos.map((String camp) {
                          return DropdownMenuItem<String>(
                            value: camp,
                            child: Text(
                              camp,
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        }).toList(),
                    validator:
                        (value) =>
                            value == null ? 'Selecciona un campamento' : null,
                    onChanged:
                        (newValue) =>
                            setState(() => _selectedCampamento = newValue),
                    dropdownSearchData: DropdownSearchData(
                      searchController: _campamentoSearchController,
                      searchInnerWidgetHeight: 40,
                      searchInnerWidget: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _campamentoSearchController,
                          style: const TextStyle(fontSize: 13),
                          decoration: fieldDecoration(
                            'Buscar campamento...',
                          ).copyWith(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value.toString().toLowerCase().contains(
                          searchValue.toLowerCase(),
                        );
                      },
                    ),
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        _campamentoSearchController.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  // CAMBIO: Se ajustó el flex para cambiar el tamaño
                  flex: 2,
                  child: DropdownButtonFormField2<String>(
                    value: _selectedArea,
                    decoration: fieldDecoration('Área'),
                    isExpanded: true,
                    buttonStyleData: const ButtonStyleData(
                      height: 40,
                      padding: EdgeInsets.zero,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    items:
                        _areas.map((String area) {
                          return DropdownMenuItem<String>(
                            value: area,
                            child: Text(
                              area,
                              style: const TextStyle(fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                    onChanged:
                        (newValue) => setState(() => _selectedArea = newValue),
                    validator:
                        (value) => value == null ? 'Selecciona un área' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _flowlineController,
              decoration: fieldDecoration('Flowline'),
              style: const TextStyle(fontSize: 13),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _progresivaController,
              decoration: fieldDecoration('Progresiva'),
              style: const TextStyle(fontSize: 13),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _actividadController,
              decoration: fieldDecoration('Actividad'),
              style: const TextStyle(fontSize: 13),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
      Step(
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        isActive: _currentStep >= 1,
        title: const Text('Registro de Residuos'),
        content: Column(
          children:
              _categorias.map((CategoriaResiduos categoria) {
                Color colorDeLetra = Colors.white;
                if (categoria.titulo == 'Plásticos') {
                  colorDeLetra = Colors.black87;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              categoria.titulo,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorDeLetra,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${categoria.getTotal().toStringAsFixed(2)} ${categoria.unidad}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: colorDeLetra,
                            ),
                          ),
                        ],
                      ),
                      leading: Text(
                        categoria.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                      backgroundColor: categoria.color,
                      collapsedBackgroundColor: categoria.color,
                      initiallyExpanded: categoria.isExpanded,
                      onExpansionChanged: (isExpanded) {
                        setState(() => categoria.isExpanded = isExpanded);
                      },
                      children: [
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 16,
                          ),
                          child: Column(
                            children:
                                categoria.items
                                    .map(
                                      (ResiduoItem item) =>
                                          _buildResiduoItemRow(item, categoria),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
      Step(
        isActive: _currentStep >= 2,
        title: const Text('Confirmar y Guardar'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Revisa toda la información antes de guardar el reporte.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información General',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Semana:', _semanaController.text),
                    _buildInfoRow(
                      'Campamento:',
                      _selectedCampamento ?? 'No seleccionado',
                    ),
                    _buildInfoRow('Área:', _selectedArea ?? 'No seleccionado'),
                    _buildInfoRow('Flowline:', _flowlineController.text),
                    _buildInfoRow('Progresiva:', _progresivaController.text),
                    _buildInfoRow('Actividad:', _actividadController.text),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _numeroGuiaController,
                      decoration: const InputDecoration(
                        labelText: 'Número de Guía (Opcional)',
                        hintText: 'Ingrese el número de guía si aplica',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                      ),
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTotalItem(
                      value: _getTotalKilos().toStringAsFixed(2),
                      label: 'Total Kg',
                      color: Colors.green,
                    ),
                    _buildTotalItem(
                      value: _getTotalTrabajadores().toStringAsFixed(0),
                      label: 'Trabajadores',
                      color: Colors.blue,
                    ),
                    _buildTotalItem(
                      value: _getTotalDias().toString(),
                      label: 'Días',
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Resumen por Categoría:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ..._categorias.map((categoria) {
              if (categoria.titulo != 'Trabajadores' &&
                  categoria.getTotal() > 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(categoria.titulo),
                      Text(
                        '${categoria.getTotal().toStringAsFixed(2)} ${categoria.unidad}',
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }).toList(),
          ],
        ),
      ),
    ];
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'No especificado',
              style: TextStyle(
                color: value.isNotEmpty ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalItem({
    required String value,
    required String label,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final circleSize = (screenWidth * 0.18).clamp(60.0, 80.0);
    final valueFontSize = (circleSize * 0.25).clamp(16.0, 20.0);
    final labelFontSize = (circleSize * 0.18).clamp(12.0, 15.0);

    return Column(
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueFontSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: labelFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildResiduoItemRow(ResiduoItem item, CategoriaResiduos categoria) {
    const dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

    // --- LÓGICA PARA BLOQUEAR DÍAS PASADOS ---
    final today = DateUtils.dateOnly(DateTime.now());
    final startDate = _selectedDateRange?.start ?? DateTime.now();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    item.nombre,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${item.getTotal().toStringAsFixed(2)} ${categoria.unidad}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final double dayInputWidth =
                    (constraints.maxWidth - (6 * 4)) / 7.5;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    // Calculamos la fecha para este día de la semana
                    final dayDate = DateUtils.addDaysToDate(startDate, index);
                    final isPastDay = dayDate.isBefore(today);

                    return Column(
                      children: [
                        Text(
                          dias[index],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: dayInputWidth,
                          child: TextFormField(
                            controller: item.controllers[index],
                            focusNode: item.focusNodes[index],
                            textAlign: TextAlign.center,
                            enabled: !isPastDay, // <-- AQUÍ SE BLOQUEA EL CAMPO
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              filled:
                                  isPastDay, // <-- Color de fondo si está bloqueado
                              fillColor: Colors.grey[200],
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 4,
                              ),
                              border: const OutlineInputBorder(),
                              enabledBorder:
                                  isPastDay
                                      ? const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      )
                                      : null,
                            ),
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                      ],
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
