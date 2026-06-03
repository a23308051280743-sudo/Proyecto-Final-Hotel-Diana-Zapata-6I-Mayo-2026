import 'package:flutter/material.dart';
import 'package:hotel/data/models/room.dart';
import 'package:hotel/data/services/firestore_service.dart';

class RoomFormScreen extends StatefulWidget {
  final Room? room;
  const RoomFormScreen({super.key, this.room});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _nameController;
  late TextEditingController _typeController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _capacityController;
  late TextEditingController _floorController;
  late TextEditingController _amenitiesController;

  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room?.name);
    _typeController = TextEditingController(text: widget.room?.type);
    _descriptionController = TextEditingController(text: widget.room?.description);
    _priceController = TextEditingController(text: widget.room?.pricePerNight.toString());
    _capacityController = TextEditingController(text: widget.room?.capacity.toString());
    _floorController = TextEditingController(text: widget.room?.floor.toString());
    _amenitiesController = TextEditingController(text: widget.room?.amenities.join(', '));
    _isAvailable = widget.room?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _capacityController.dispose();
    _floorController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final roomData = Room(
      roomId: widget.room?.roomId ?? '', // Firestore handles ID for new rooms if omitted or provided via add()
      name: _nameController.text,
      type: _typeController.text,
      description: _descriptionController.text,
      pricePerNight: double.parse(_priceController.text),
      capacity: int.parse(_capacityController.text),
      floor: int.parse(_floorController.text),
      amenities: _amenitiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      imageUrls: widget.room?.imageUrls ?? [],
      isAvailable: _isAvailable,
    );

    try {
      if (widget.room == null) {
        await _firestoreService.createRoom(roomData);
      } else {
        await _firestoreService.updateRoom(widget.room!.roomId, roomData.toMap());
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving room: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room == null ? 'Add Room' : 'Edit Room'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Room Name'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
            ),
            TextFormField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type (e.g. Single, Double, Suite)'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter a type' : null,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
            ),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price per Night'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || double.tryParse(value) == null ? 'Please enter a valid price' : null,
            ),
            TextFormField(
              controller: _capacityController,
              decoration: const InputDecoration(labelText: 'Capacity'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || int.tryParse(value) == null ? 'Please enter a valid capacity' : null,
            ),
            TextFormField(
              controller: _floorController,
              decoration: const InputDecoration(labelText: 'Floor'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || int.tryParse(value) == null ? 'Please enter a valid floor' : null,
            ),
            TextFormField(
              controller: _amenitiesController,
              decoration: const InputDecoration(labelText: 'Amenities (comma separated)'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter amenities' : null,
            ),
            SwitchListTile(
              title: const Text('Is Available'),
              value: _isAvailable,
              onChanged: (val) => setState(() => _isAvailable = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Room'),
            ),
          ],
        ),
      ),
    );
  }
}
