import 'package:flutter/material.dart';
import 'package:recycle_app/login_page.dart';
import 'package:recycle_app/main.dart';
import 'package:recycle_app/notifications_page.dart';
import 'package:recycle_app/upload_report_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart'; // <-- AÑADIDO

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentReports = [];
  bool _loadingReports = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _requestNotificationPermission(); // <-- AÑADIDO
  }

  // --- NUEVA FUNCIÓN PARA PEDIR PERMISOS ---
  Future<void> _requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isDenied) {
      // Opcional: mostrar un mensaje si el usuario niega el permiso.
      debugPrint("Permiso de notificación denegado.");
    }
  }

  Future<void> _fetchInitialData() async {
    await _fetchProfile();
    await _fetchRecentReports();
    await _fetchUnreadNotificationsCount();
  }

  Future<void> _fetchProfile() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final response =
          await supabase.from('profiles').select().eq('id', userId).single();
      setState(() {
        _profileData = response;
        _isLoading = false;
      });
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
          .select('''
            id, semana, fecha_inicio, fecha_fin, campamento, area,
            flowline, progresiva, actividad, numero_guia, total_kilos,
            total_trabajadores, total_dias, status, created_at, updated_at
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);

      setState(() {
        _recentReports = List<Map<String, dynamic>>.from(response);
        _loadingReports = false;
      });
    } catch (error) {
      debugPrint('Error al cargar reportes: $error');
      setState(() => _loadingReports = false);
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

  IconData _getReportIcon(String status) {
    switch (status) {
      case 'draft':
        return Icons.drafts;
      case 'in_progress':
        return Icons.hourglass_bottom;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.description;
    }
  }

  Color _getReportColor(String status) {
    switch (status) {
      case 'draft':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'draft':
        return 'Borrador';
      case 'in_progress':
        return 'En progreso';
      case 'completed':
        return 'Completado';
      default:
        return status;
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
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.03,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F6F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListView(
              children: [
                _buildMainActionButton(screenHeight, screenWidth),
                SizedBox(height: screenHeight * 0.035),
                _buildSectionTitle('Actividad Reciente', screenWidth),
                _buildRecentActivityCard(screenWidth),
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
                          _fetchUnreadNotificationsCount();
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

  Widget _buildMainActionButton(double screenHeight, double screenWidth) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add_circle_outline, size: 28),
      label: const Text('Crear Nuevo Formulario'),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.022),
        textStyle: TextStyle(
          fontSize: (screenWidth * 0.045).clamp(16.0, 20.0),
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UploadReportPage()),
        ).then((_) {
          _fetchRecentReports();
        });
      },
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

  Widget _buildRecentActivityCard(double screenWidth) {
    if (_loadingReports) {
      return const Card(
        child: ListTile(
          leading: CircularProgressIndicator(),
          title: Text('Cargando reportes...'),
        ),
      );
    }

    if (_recentReports.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: const ListTile(
          contentPadding: EdgeInsets.all(15),
          leading: Icon(Icons.history, color: Colors.grey, size: 32),
          title: Text('Aún no hay reportes recientes'),
          subtitle: Text('Crea un nuevo formulario para empezar'),
        ),
      );
    }

    return Column(
      children:
          _recentReports.map((report) {
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: Icon(
                  _getReportIcon(report['status']),
                  color: _getReportColor(report['status']),
                  size: 32,
                ),
                title: Text(
                  'Reporte: ${report['semana']}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Campamento: ${report['campamento']}\n'
                  'Área: ${report['area']}\n'
                  'Estado: ${_getStatusText(report['status'])}',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => UploadReportPage(existingReport: report),
                    ),
                  ).then((_) {
                    _fetchRecentReports();
                  });
                },
              ),
            );
          }).toList(),
    );
  }
}
