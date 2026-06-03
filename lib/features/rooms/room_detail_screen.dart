import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel/data/models/room.dart';
import 'package:hotel/data/services/firestore_service.dart';
import 'package:hotel/widgets/primary_button.dart';

class RoomDetailScreen extends StatelessWidget {
  final String roomId;
  const RoomDetailScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      body: FutureBuilder<Room>(
        future: firestoreService.getRoom(roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final room = snapshot.data!;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: room.roomId,
                    child: room.imageUrls.isNotEmpty
                        ? Image.network(room.imageUrls[0], fit: BoxFit.cover)
                        : const Icon(Icons.bed, size: 100),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('\$${room.pricePerNight}/noche', style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      Text(room.description, style: const TextStyle(fontSize: 16, color: Colors.black87)),
                      const SizedBox(height: 24),
                      const Text('Amenidades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: room.amenities.map((a) => Chip(label: Text(a))).toList(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(Icons.people),
                          SizedBox(width: 8),
                          Text('Capacidad: ${room.capacity} personas'),
                          SizedBox(width: 24),
                          const Icon(Icons.layers),
                          SizedBox(width: 8),
                          Text('Piso: ${room.floor}'),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<bool>(
          future: Future.value(true), // Replace with real auth check
          builder: (context, snapshot) {
            final isAuthenticated = snapshot.data ?? false;
            return PrimaryButton(
              text: isAuthenticated ? 'RESERVAR AHORA' : 'Inicia sesión para reservar',
              onPressed: isAuthenticated
                ? () => context.push('/reservations/new?roomId=$roomId')
                : () => context.push('/login'),
            );
          },
        ),
      ),
    );
  }
}
