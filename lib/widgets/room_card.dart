import 'package:flutter/material.dart';
import 'package:hotel/data/models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onSeeMore;

  const RoomCard({super.key, required this.room, required this.onSeeMore});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: room.imageUrls.isNotEmpty
                ? Image.network(room.imageUrls[0], height: 200, width: double.infinity, fit: BoxFit.cover)
                : Container(height: 200, color: Colors.grey, child: const Icon(Icons.bed, size: 50)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(room.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('\$${room.pricePerNight}/noche', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
                SizedBox(height: 4),
                Text(room.type, style: TextStyle(color: Colors.grey[600])),
                SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text('Capacidad: ${room.capacity} personas', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: room.amenities.take(3).map((a) => Chip(label: Text(a, style: const TextStyle(fontSize: 12)))).toList(),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onSeeMore,
                    style: OutlinedButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.primary),
                    child: const Text('Ver más'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
