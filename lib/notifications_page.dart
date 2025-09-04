import 'package:flutter/material.dart';
import 'package:recycle_app/main.dart';
import 'package:timeago/timeago.dart' as timeago;

// NOTA: Asegúrate de añadir el paquete 'timeago' a tu pubspec.yaml
// ejecutando: flutter pub add timeago

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // Usamos un Future para cargar las notificaciones y poder refrescarlo
  late Future<List<Map<String, dynamic>>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    // Inicializamos el Future en initState
    _notificationsFuture = _fetchNotifications();
    // Configuramos el idioma español para timeago
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

  /// Obtiene las notificaciones del usuario desde Supabase
  Future<List<Map<String, dynamic>>> _fetchNotifications() async {
    final userId = supabase.auth.currentUser!.id;
    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Marca una notificación como leída y refresca la lista
  Future<void> _markAsRead(String notificationId) async {
    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      // Refresca la lista de notificaciones para que el cambio se vea al instante
      setState(() {
        _notificationsFuture = _fetchNotifications();
      });
    } catch (e) {
      // Manejo básico de errores
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al marcar como leído: ${e.toString()}'),
          ),
        );
      }
    }
  }

  /// Define el ícono y el color según el tipo de notificación
  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'reminder':
        return Icon(Icons.timer_outlined, color: Colors.orange.shade800);
      case 'info':
        return Icon(Icons.info_outline, color: Colors.blue.shade700);
      default:
        return Icon(Icons.notifications, color: Colors.grey.shade600);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Notificaciones',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF16A085), Color(0xFF2ECC71)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _notificationsFuture = _fetchNotifications();
          });
        },
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final notifications = snapshot.data ?? [];
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No tienes notificaciones',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isRead = notification['is_read'] as bool;
                final createdAt = DateTime.parse(
                  notification['created_at'] as String,
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 6.0,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color:
                          isRead
                              ? Colors.transparent
                              : Theme.of(context).primaryColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                    leading: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _getNotificationIcon(notification['type']),
                        ),
                        if (!isRead)
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      notification['title'] ?? 'Notificación',
                      style: TextStyle(
                        fontWeight:
                            isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification['message'] ?? ''),
                        const SizedBox(height: 5),
                        Text(
                          timeago.format(createdAt, locale: 'es'),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (!isRead) {
                        _markAsRead(notification['id']);
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
