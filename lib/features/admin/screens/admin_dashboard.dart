import 'package:flutter/material.dart';
import 'package:hotel/features/admin/screens/rooms_admin_screen.dart';
import 'package:hotel/features/admin/screens/reservations_admin_screen.dart';
import 'package:hotel/features/admin/screens/users_admin_screen.dart';
import 'package:hotel/features/admin/screens/services_admin_screen.dart';
import 'package:hotel/data/services/seed_service.dart';
import 'package:hotel/data/services/firestore_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  Map<String, dynamic>? _stats;

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

  Future<void> _handleSeedData(BuildContext context) async {
    try {
      await SeedService().seedDatabase();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Database seeded successfully!')),
      );
      await _loadStats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error seeding database: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
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
                  'Rooms',
                  Icons.hotel,
                  const RoomsAdminScreen(),
                ),
                _buildDashboardItem(
                  context,
                  'Reservations',
                  Icons.calendar_today,
                  const ReservationsAdminScreen(),
                ),
                _buildDashboardItem(
                  context,
                  'Users',
                  Icons.people,
                  const UsersAdminScreen(),
                ),
                _buildDashboardItem(
                  context,
                  'Services',
                  Icons.concierge_bell,
                  const ServicesAdminScreen(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _handleSeedData(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('SEED INITIAL DATA'),
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
          _buildStatItem('Active', _stats?['activeReservations'].toString() ?? '0'),
          _buildStatItem('Today', _stats?['occupiedToday'].toString() ?? '0'),
          _buildStatItem('Month', '\$${_stats?['monthlyRevenue']?.toStringAsFixed(2) ?? '0.00'}'),
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
