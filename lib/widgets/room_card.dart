import 'package:flutter/material.dart';
import 'package:hotel/data/models/room.dart';

class RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onSeeMore;
  final double imageHeight;

  const RoomCard({
    super.key,
    required this.room,
    required this.onSeeMore,
    this.imageHeight = 160,
  });

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
                ? Image.network(room.imageUrls[0], height: imageHeight, width: double.infinity, fit: BoxFit.cover)
                : Container(height: imageHeight, color: Colors.grey, child: const Icon(Icons.bed, size: 50)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        room.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('\$${room.pricePerNight}/noche', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(room.type, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Capacidad: ${room.capacity} personas', style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: room.amenities.take(3).map((a) => CompactChip(label: a)).toList(),
                ),
                const SizedBox(height: 16),
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

class CompactChip extends StatelessWidget {
  final String label;
  const CompactChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: Colors.grey[800]),
      ),
    );
  }
}
