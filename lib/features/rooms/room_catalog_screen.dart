import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel/data/models/room.dart';
import 'package:hotel/data/services/firestore_service.dart';
import 'package:hotel/widgets/room_card.dart';
import 'package:hotel/widgets/empty_state.dart';

class RoomCatalogScreen extends StatefulWidget {
  const RoomCatalogScreen({super.key});

  @override
  State<RoomCatalogScreen> createState() => _RoomCatalogScreenState();
}

class _RoomCatalogScreenState extends State<RoomCatalogScreen> {
  String selectedType = 'All';
  final List<String> types = ['All', 'Suite', 'Doble', 'Individual', 'Familiar'];

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Habitaciones')),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: types.map((type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type),
                  selected: selectedType == type,
                  onSelected: (selected) {
                    setState(() {
                      selectedType = type;
                    });
                  },
                ),
              )).toList(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Room>>(
              future: firestoreService.getRooms(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                var rooms = snapshot.data!;
                if (selectedType != 'All') {
                  rooms = rooms.where((r) => r.type == selectedType).toList();
                }

                if (rooms.isEmpty) return const EmptyState(message: 'No hay habitaciones disponibles en esta categoría');

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    return RoomCard(
                      room: rooms[index],
                      onSeeMore: () => context.go('/rooms/${rooms[index].roomId}'),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
