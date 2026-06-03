import 'package:flutter/material.dart';
import 'package:hotel/data/models/reservation.dart';
import 'package:hotel/widgets/status_badge.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onViewDetail;

  const ReservationCard({super.key, required this.reservation, required this.onViewDetail});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(reservation.roomName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${reservation.checkIn.toString().split(' ')[0]} → ${reservation.checkOut.toString().split(' ')[0]}'),
            SizedBox(height: 4),
            Text('Total: \$${reservation.totalPrice}', style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StatusBadge(status: reservation.status),
            SizedBox(height: 8),
            TextButton(onPressed: onViewDetail, child: const Text('Detalle')),
          ],
        ),
      ),
    );
  }
}
