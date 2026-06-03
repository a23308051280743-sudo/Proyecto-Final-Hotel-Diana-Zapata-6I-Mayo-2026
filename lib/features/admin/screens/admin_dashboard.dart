import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel/features/admin/screens/rooms_admin_screen.dart';
import 'package:hotel/features/admin/screens/reservations_admin_screen.dart';
import 'package:hotel/features/admin/screens/users_admin_screen.dart';
import 'package:hotel/features/admin/screens/services_admin_screen.dart';
import 'package:hotel/data/services/seed_service.dart';
import 'package:hotel/data/services/firestore_service.dart';
import 'package:hotel/features/auth/auth_provider.dart';
import 'package:hotel/core/theme/app_theme.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _stats;
  bool _isSeeding = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final stats = await _firestoreService.getAdminStats();
    setState(() {
      _stats = stats;
    });
  }

  Future<void> _confirmAndSeed() async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.storage_rounded, color: AppTheme.primaryRed),
            const SizedBox(width: 12),
            const Text('Sembrar Datos'),
          ],
        ),
        content: const Text(
          '¿Deseas insertar los datos iniciales en la base de datos?\n\n'
          'Esto creará habitaciones y servicios de ejemplo. '
          'Si ya existen datos, podrían duplicarse.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSeeding = true);

    try {
      await SeedService().seedDatabase();
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('✅ Datos sembrados exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      await _loadStats();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error al sembrar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSeeding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Actualizar estadísticas',
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) context.go('/home-public');
            },
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_stats != null) _buildStatsBar(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16.0),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                _buildDashboardItem(
                  context,
                  'Habitaciones',
                  Icons.hotel,
                  const RoomsAdminScreen(),
                ),
                _buildDashboardItem(
                  context,
                  'Reservaciones',
                  Icons.calendar_today,
                  const ReservationsAdminScreen(),
                ),
                _buildDashboardItem(
                  context,
                  'Usuarios',
                  Icons.people,
                  const UsersAdminScreen(),
                ),
                _buildDashboardItem(
                  context,
                  'Servicios',
                  Icons.room_service_outlined,
                  const ServicesAdminScreen(),
                ),
              ],
            ),
          ),
          // Seed Data Button with confirmation dialog
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
            child: ElevatedButton.icon(
              onPressed: _isSeeding ? null : () => _confirmAndSeed(),
              icon: _isSeeding
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.storage_rounded),
              label: Text(_isSeeding ? 'SEMBRANDO DATOS...' : 'SEMBRAR DATOS INICIALES'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF455A64),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Activas', _stats?['activeReservations'].toString() ?? '0'),
          _buildStatItem('Hoy', _stats?['occupiedToday'].toString() ?? '0'),
          _buildStatItem('Mes', '\$${_stats?['monthlyRevenue']?.toStringAsFixed(2) ?? '0.00'}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Widget targetScreen,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
      ),
      child: Card(
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
