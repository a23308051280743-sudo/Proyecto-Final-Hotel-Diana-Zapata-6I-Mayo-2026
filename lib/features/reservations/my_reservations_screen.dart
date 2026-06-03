import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel/data/models/reservation.dart';
import 'package:hotel/data/services/firestore_service.dart';
import 'package:hotel/widgets/reservation_card.dart';
import 'package:hotel/widgets/empty_state.dart';
import 'package:hotel/features/auth/auth_provider.dart';

class MyReservationsScreen extends StatelessWidget {
  const MyReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Reservas'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Próximas'),
              Tab(text: 'Historial'),
              Tab(text: 'Canceladas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReservationList(statusFilter: 'pending,confirmed'),
            _ReservationList(statusFilter: 'completed'),
            _ReservationList(statusFilter: 'cancelled'),
          ],
        ),
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  final String statusFilter;
  const _ReservationList({required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final statuses = statusFilter.split(',');

    return FutureBuilder<List<Reservation>>(
      future: firestoreService.getMyReservations(auth.currentUid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final allReservations = snapshot.data!;
        final filtered = allReservations.where((res) => statuses.contains(res.status)).toList();

        if (filtered.isEmpty) return const EmptyState(message: 'No hay reservas en esta categoría');

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            return ReservationCard(
              reservation: filtered[index],
              onViewDetail: () => context.push('/reservations/${filtered[index].reservationId}'),
            );
          },
        );
      },
    );
  }
}
