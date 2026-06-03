import 'package:flutter/material.dart';
import 'package:hotel/data/models/service.dart';
import 'package:hotel/data/services/firestore_service.dart';
import 'service_form_screen.dart';

class ServicesAdminScreen extends StatefulWidget {
  const ServicesAdminScreen({super.key});

  @override
  State<ServicesAdminScreen> createState() => _ServicesAdminScreenState();
}

class _ServicesAdminScreenState extends State<ServicesAdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<HotelService>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _refreshServices();
  }

  void _refreshServices() {
    setState(() {
      _servicesFuture = _firestoreService.getServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshServices,
          ),
        ],
      ),
      body: FutureBuilder<List<HotelService>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final services = snapshot.data ?? [];
          if (services.isEmpty) {
            return const Center(child: Text('No services found.'));
          }
          return ListView.builder(
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return ListTile(
                title: Text(service.name),
                subtitle: Text('${service.category} - \$${service.price}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ServiceFormScreen(service: service),
                          ),
                        );
                        _refreshServices();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteService(service.serviceId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ServiceFormScreen()),
          );
          _refreshServices();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteService(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: const Text('Are you sure you want to delete this service?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteService(id);
      _refreshServices();
    }
  }
}
