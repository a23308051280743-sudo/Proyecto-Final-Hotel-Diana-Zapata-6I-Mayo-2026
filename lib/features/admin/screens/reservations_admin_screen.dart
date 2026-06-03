import 'package:flutter/material.dart';
import 'package:hotel/data/models/reservation.dart';
import 'package:hotel/data/services/firestore_service.dart';
import 'reservation_form_screen.dart';

class ReservationsAdminScreen extends StatefulWidget {
  const ReservationsAdminScreen({super.key});

  @override
  State<ReservationsAdminScreen> createState() => _ReservationsAdminScreenState();
}

class _ReservationsAdminScreenState extends State<ReservationsAdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Reservation>> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _refreshReservations();
  }

  void _refreshReservations() {
    setState(() {
      _reservationsFuture = _firestoreService.getAllReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Reservations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshReservations,
          ),
        ],
      ),
      body: FutureBuilder<List<Reservation>>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final reservations = snapshot.data ?? [];
          if (reservations.isEmpty) {
            return const Center(child: Text('No reservations found.'));
          }
          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              return ListTile(
                title: Text('${res.guestName} - ${res.roomName}'),
                subtitle: Text('Status: ${res.status} | Check-in: ${res.checkIn.toString().split(' ')[0]}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReservationFormScreen(reservation: res),
                          ),
                        );
                        _refreshReservations();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteReservation(res.reservationId),
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
            MaterialPageRoute(builder: (context) => const ReservationFormScreen()),
          );
          _refreshReservations();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteReservation(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reservation'),
        content: const Text('Are you sure you want to delete this reservation?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteReservation(id);
      _refreshReservations();
    }
  }
}
