import 'package:flutter/material.dart';
import 'package:hotel/data/models/room.dart';
import 'package:hotel/data/services/firestore_service.dart';
import 'room_form_screen.dart';

class RoomsAdminScreen extends StatefulWidget {
  const RoomsAdminScreen({super.key});

  @override
  State<RoomsAdminScreen> createState() => _RoomsAdminScreenState();
}

class _RoomsAdminScreenState extends State<RoomsAdminScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Room>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _refreshRooms();
  }

  void _refreshRooms() {
    setState(() {
      _roomsFuture = _firestoreService.getRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Rooms'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRooms,
          ),
        ],
      ),
      body: FutureBuilder<List<Room>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return const Center(child: Text('No rooms found.'));
          }
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return ListTile(
                title: Text(room.name),
                subtitle: Text('${room.type} - \$${room.pricePerNight}/night'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RoomFormScreen(room: room),
                          ),
                        );
                        _refreshRooms();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteRoom(room.roomId),
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
            MaterialPageRoute(builder: (context) => const RoomFormScreen()),
          );
          _refreshRooms();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteRoom(String roomId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: const Text('Are you sure you want to delete this room?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await _firestoreService.deleteRoom(roomId);
      _refreshRooms();
    }
  }
}
