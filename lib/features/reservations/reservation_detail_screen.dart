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

          final servicesTotal = res.services.fold<double>(0.0, (sum, svc) => sum + ((svc['price'] as num?)?.toDouble() ?? 0.0));
          final roomTotal = res.totalPrice - servicesTotal;

          return SingleChildScrollView(
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
                if (res.specialRequests != null && res.specialRequests!.isNotEmpty)
                  _DetailItem(label: 'Solicitudes', value: res.specialRequests!),
                
                const SizedBox(height: 24),
                const Text('Detalle de Cargos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Divider(),
                _DetailItem(label: 'Costo de Habitación', value: '\$${roomTotal.toStringAsFixed(2)}'),
                
                if (res.services.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('Servicios Adicionales:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
                  const SizedBox(height: 4),
                  ...res.services.map((svc) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(svc['name'] ?? '', style: const TextStyle(fontSize: 13)),
                        Text('\$${(svc['price'] as num?)?.toDouble().toStringAsFixed(2) ?? "0.00"}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
                ],
                const Divider(),
                _DetailItem(
                  label: 'Total General', 
                  value: '\$${res.totalPrice.toStringAsFixed(2)}',
                  valueStyle: TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold, 
                    color: Theme.of(context).colorScheme.primary
                  ),
                ),
                
                const SizedBox(height: 40),
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
                              if (context.mounted) {
                                Navigator.pop(context); // Cerrar diálogo
                                Navigator.pop(context); // Regresar de la pantalla de detalle para actualizar
                              }
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
  final TextStyle? valueStyle;
  const _DetailItem({required this.label, required this.value, this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: valueStyle ?? const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
