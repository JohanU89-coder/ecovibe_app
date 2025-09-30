import 'package:flutter/material.dart';
import 'package:recycle_app/login_page.dart';
import 'package:recycle_app/main.dart';
import 'package:recycle_app/notifications_page.dart';
import 'package:recycle_app/upload_report_page.dart';
import 'package:recycle_app/water_report_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

// Enum para gestionar el tipo de reporte seleccionado
enum ReportType { waste, water }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  // Datos para reportes de residuos
  List<Map<String, dynamic>> _recentReports = [];
  bool _loadingReports = true;

  // Datos para reportes de agua
  List<Map<String, dynamic>> _recentWaterReports = [];
  bool _loadingWaterReports = true;

  int _unreadNotifications = 0;

  // Variable de estado para controlar el selector
  Set<ReportType> _selection = {ReportType.waste};

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isDenied) {
      debugPrint("Permiso de notificación denegado.");
    }
  }

  Future<void> _fetchInitialData() async {
    await _fetchProfile();
    // Carga ambos tipos de reportes en paralelo para mayor eficiencia
    await Future.wait([_fetchRecentReports(), _fetchRecentWaterReports()]);
    await _fetchUnreadNotificationsCount();
  }

  Future<void> _fetchProfile() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response =
          await supabase.from('profiles').select().eq('id', userId).single();
      if (mounted) {
        setState(() {
          _profileData = response;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error al cargar el perfil.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchRecentReports() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('weekly_reports')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(6);

      if (mounted) {
        setState(() {
          _recentReports = List<Map<String, dynamic>>.from(response);
          _loadingReports = false;
        });
      }
    } catch (error) {
      debugPrint('Error al cargar reportes de residuos: $error');
      if (mounted) {
        setState(() => _loadingReports = false);
      }
    }
  }

  Future<void> _fetchRecentWaterReports() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response = await supabase
          .from('water_reports')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(6);

      if (!mounted) return;

      final reports = List<Map<String, dynamic>>.from(response);
      final List<Future> updateFutures = [];

      // Revisa cada reporte y si su estado no es 'completed', lo actualiza en la BD.
      for (final report in reports) {
        if (report['status'] != 'completed' &&
            report['status'] != 'terminado') {
          final reportId = report['id'];
          // Prepara la actualización para la BD
          updateFutures.add(
            supabase
                .from('water_reports')
                .update({'status': 'completed'})
                .eq('id', reportId),
          );
          // Actualiza el estado en la lista local para reflejarlo inmediatamente.
          report['status'] = 'completed';
        }
      }

      // Espera a que todas las actualizaciones se completen si hubo alguna.
      if (updateFutures.isNotEmpty) {
        await Future.wait(updateFutures);
      }

      setState(() {
        _recentWaterReports = reports;
        _loadingWaterReports = false;
      });
    } catch (error) {
      debugPrint('Error al cargar o actualizar reportes de agua: $error');
      if (mounted) {
        setState(() => _loadingWaterReports = false);
      }
    }
  }

  Future<void> _fetchUnreadNotificationsCount() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final count = await supabase
          .from('notifications')
          .count(CountOption.exact)
          .eq('user_id', userId)
          .eq('is_read', false);

      if (mounted) {
        setState(() {
          _unreadNotifications = count;
        });
      }
    } catch (e) {
      debugPrint('Error fetching unread notifications count: $e');
    }
  }

  IconData _getReportIcon(String? status) {
    switch (status) {
      case 'draft':
        return Icons.drafts;
      case 'in_progress':
        return Icons.hourglass_bottom;
      case 'completed':
      case 'terminado':
        return Icons.check_circle;
      default:
        return Icons.description;
    }
  }

  Color _getReportColor(String? status) {
    switch (status) {
      case 'draft':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
      case 'terminado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'draft':
        return 'Borrador';
      case 'in_progress':
        return 'En progreso';
      case 'completed':
      case 'terminado':
        return 'Completado';
      default:
        return status ?? 'Desconocido';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF16A085), Color(0xFF2ECC71)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                  : _profileData == null
                  ? const Center(
                    child: Text(
                      'No se pudo cargar el perfil.',
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                  : buildProfileView(),
        ),
      ),
    );
  }

  Widget buildProfileView() {
    final String nombresCompletos = _profileData!['nombres'] ?? '';
    final String primerNombre = nombresCompletos.split(' ').first;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        _buildCustomHeader(primerNombre, screenWidth),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF4F6F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.03,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildActionButtons(),
                      SizedBox(height: screenHeight * 0.035),
                      _buildSectionTitle('Actividad Reciente', screenWidth),
                      const SizedBox(height: 15),
                      _buildReportTypeSelector(),
                      const SizedBox(height: 15),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child:
                            _selection.first == ReportType.waste
                                ? _buildWasteReportsList(screenWidth)
                                : _buildWaterReportsList(screenWidth),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomHeader(String name, double screenWidth) {
    final double welcomeFontSize = (screenWidth * 0.05).clamp(18.0, 24.0);
    final double nameFontSize = (screenWidth * 0.09).clamp(32.0, 40.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenWidth * 0.05,
        20,
        screenWidth * 0.05,
        30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bienvenido,',
                style: TextStyle(
                  fontSize: welcomeFontSize,
                  color: Colors.white70,
                ),
              ),
              Row(
                children: [
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsPage(),
                            ),
                          );
                          if (mounted) {
                            _fetchUnreadNotificationsCount();
                          }
                        },
                      ),
                      if (_unreadNotifications > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$_unreadNotifications',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Cerrar Sesión',
                    onPressed: () async {
                      await supabase.auth.signOut();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: nameFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.recycling,
            label: 'Reporte Residuos',
            color: const Color(0xFF2ECC71),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadReportPage(),
                ),
              );
              if (mounted) {
                _fetchRecentReports();
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.water_drop_outlined,
            label: 'Reporte Agua',
            color: Colors.blue,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WaterReportPage(),
                ),
              );
              if (mounted) {
                _fetchRecentWaterReports();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        foregroundColor: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Text(
      title,
      style: TextStyle(
        fontSize: (screenWidth * 0.05).clamp(18.0, 22.0),
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildReportTypeSelector() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selection = {ReportType.waste};
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color:
                      _selection.first == ReportType.waste
                          ? const Color(0xFF2ECC71)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.recycling,
                        color:
                            _selection.first == ReportType.waste
                                ? Colors.white
                                : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Residuos',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              _selection.first == ReportType.waste
                                  ? Colors.white
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selection = {ReportType.water};
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color:
                      _selection.first == ReportType.water
                          ? Colors.blue
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop,
                        color:
                            _selection.first == ReportType.water
                                ? Colors.white
                                : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Agua',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              _selection.first == ReportType.water
                                  ? Colors.white
                                  : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteReportsList(double screenWidth) {
    if (_loadingReports) {
      return const Card(
        key: ValueKey('waste_loading'),
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Cargando reportes de residuos...'),
        ),
      );
    }

    if (_recentReports.isEmpty) {
      return Card(
        key: const ValueKey('waste_empty'),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const ListTile(
          contentPadding: EdgeInsets.all(15),
          leading: Icon(Icons.recycling, color: Colors.grey, size: 32),
          title: Text('Aún no hay reportes de residuos'),
          subtitle: Text('Crea un nuevo reporte para empezar'),
        ),
      );
    }

    return Column(
      key: const ValueKey('waste_data'),
      children:
          _recentReports.map((report) {
            return Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                leading: Icon(
                  _getReportIcon(report['status']),
                  color: _getReportColor(report['status']),
                  size: 28,
                ),
                title: Text(
                  'Reporte: ${report['semana'] ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${report['campamento'] ?? 'N/A'} • ${_getStatusText(report['status'])}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UploadReportPage(existingReport: report),
                    ),
                  );
                  if (mounted) {
                    _fetchRecentReports();
                  }
                },
              ),
            );
          }).toList(),
    );
  }

  Widget _buildWaterReportsList(double screenWidth) {
    if (_loadingWaterReports) {
      return const Card(
        key: ValueKey('water_loading'),
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Cargando reportes de agua...'),
        ),
      );
    }

    if (_recentWaterReports.isEmpty) {
      return Card(
        key: const ValueKey('water_empty'),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: const ListTile(
          contentPadding: EdgeInsets.all(15),
          leading: Icon(
            Icons.water_drop_outlined,
            color: Colors.grey,
            size: 32,
          ),
          title: Text('Aún no hay reportes de agua'),
          subtitle: Text('Crea un nuevo reporte para empezar'),
        ),
      );
    }

    return Column(
      key: const ValueKey('water_data'),
      children:
          _recentWaterReports.map((report) {
            final status = report['status'];
            String fecha = 'N/A';
            final rawDate = report['fecha'];

            if (rawDate is String && rawDate.isNotEmpty) {
              try {
                fecha = DateFormat(
                  'dd/MM/yyyy',
                ).format(DateTime.parse(rawDate));
              } catch (e) {
                debugPrint('Error al parsear la fecha: $rawDate');
              }
            }

            return Card(
              elevation: 4,
              shadowColor: Colors.black.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              // CHANGE: Adjusted margin for consistency with waste reports.
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 12,
                ),
                leading: Icon(
                  _getReportIcon(status),
                  color: _getReportColor(status),
                  size: 28,
                ),
                title: Text(
                  'Reporte de Agua: $fecha',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  '${report['campamento'] ?? 'N/A'} • ${_getStatusText(status)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => WaterReportPage(existingReport: report),
                    ),
                  );
                  if (mounted) {
                    _fetchRecentWaterReports();
                  }
                },
              ),
            );
          }).toList(),
    );
  }
}
