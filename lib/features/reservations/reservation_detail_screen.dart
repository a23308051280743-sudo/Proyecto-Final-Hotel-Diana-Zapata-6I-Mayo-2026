import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hotel/data/models/reservation.dart';
import 'package:hotel/data/services/firestore_service.dart';
import 'package:hotel/widgets/status_badge.dart';
import 'package:hotel/widgets/confirm_dialog.dart';

class ReservationDetailScreen extends StatelessWidget {
  final String reservationId;
  const ReservationDetailScreen({super.key, required this.reservationId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Reserva')),
      body: FutureBuilder<Reservation>(
        future: _getReservation(firestoreService),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final res = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: StatusBadge(status: res.status)),
                const SizedBox(height: 24),
                _DetailItem(label: 'Habitación', value: res.roomName),
                _DetailItem(label: 'Check-in', value: res.checkIn.toString().split(' ')[0]),
                _DetailItem(label: 'Check-out', value: res.checkOut.toString().split(' ')[0]),
                _DetailItem(label: 'Noches', value: res.nights.toString()),
                _DetailItem(label: 'Huéspedes', value: '${res.adults} adultos, ${res.children} niños'),
                _DetailItem(label: 'Total Pagado', value: '\$${res.totalPrice}'),
                if (res.specialRequests != null) _DetailItem(label: 'Solicitudes', value: res.specialRequests!),
                const Spacer(),
                if (res.status == 'pending' || res.status == 'confirmed')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmDialog(
                            title: 'Cancelar Reserva',
                            content: '¿Estás seguro de que deseas cancelar esta reserva?',
                            confirmText: 'Cancelar',
                            onConfirm: () async {
                              await firestoreService.cancelReservation(res.reservationId);
                            },
                          ),
                        );
                      },
                      child: const Text('CANCELAR RESERVA'),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<Reservation> _getReservation(FirestoreService service) async {
    return service.getReservation(reservationId);
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
