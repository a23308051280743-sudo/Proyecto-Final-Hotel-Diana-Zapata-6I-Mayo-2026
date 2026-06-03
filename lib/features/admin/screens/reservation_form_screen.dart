import 'package:flutter/material.dart';
import 'package:hotel/data/models/reservation.dart';
import 'package:hotel/data/models/room.dart';
import 'package:hotel/data/services/firestore_service.dart';

class ReservationFormScreen extends StatefulWidget {
  final Reservation? reservation;
  const ReservationFormScreen({super.key, this.reservation});

  @override
  State<ReservationFormScreen> createState() => _ReservationFormScreenState();
}

class _ReservationFormScreenState extends State<ReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();

  late TextEditingController _guestNameController;
  late TextEditingController _userIdController;
  late TextEditingController _specialRequestsController;

  Room? _selectedRoom;
  DateTime _checkIn = DateTime.now();
  DateTime _checkOut = DateTime.now().add(const Duration(days: 1));
  int _adults = 1;
  int _children = 0;
  String _status = 'confirmed';

  List<Room> _rooms = [];

  @override
  void initState() {
    super.initState();
    _guestNameController = TextEditingController(text: widget.reservation?.guestName);
    _userIdController = TextEditingController(text: widget.reservation?.userId);
    _specialRequestsController = TextEditingController(text: widget.reservation?.specialRequests);

    if (widget.reservation != null) {
      _checkIn = widget.reservation!.checkIn;
      _checkOut = widget.reservation!.checkOut;
      _adults = widget.reservation!.adults;
      _children = widget.reservation!.children;
      _status = widget.reservation!.status;
      _loadRooms();
    } else {
      _loadRooms();
    }
  }

  Future<void> _loadRooms() async {
    final rooms = await _firestoreService.getRooms();
    setState(() {
      _rooms = rooms;
      if (widget.reservation != null) {
        _selectedRoom = _rooms.firstWhere(
          (r) => r.roomId == widget.reservation!.roomId,
          orElse: () => _rooms.first,
        );
      }
    });
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _userIdController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a room')));
      return;
    }

    final nights = _checkOut.difference(_checkIn).inDays;
    final totalPrice = nights * _selectedRoom!.pricePerNight;

    final reservation = Reservation(
      reservationId: widget.reservation?.reservationId ?? '',
      userId: _userIdController.text,
      roomId: _selectedRoom!.roomId,
      roomName: _selectedRoom!.name,
      guestName: _guestNameController.text,
      checkIn: _checkIn,
      checkOut: _checkOut,
      nights: nights,
      totalPrice: totalPrice,
      status: _status,
      adults: _adults,
      children: _children,
      specialRequests: _specialRequestsController.text,
      createdAt: widget.reservation?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.reservation == null) {
        await _firestoreService.createReservation(reservation);
      } else {
        await _firestoreService.updateReservation(widget.reservation!.reservationId, reservation.toMap());
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving reservation: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reservation == null ? 'Create Reservation' : 'Edit Reservation'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _guestNameController,
              decoration: const InputDecoration(labelText: 'Guest Name'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter guest name' : null,
            ),
            TextFormField(
              controller: _userIdController,
              decoration: const InputDecoration(labelText: 'User ID'),
              validator: (value) => value == null || value.isEmpty ? 'Please enter user ID' : null,
            ),
            DropdownButtonFormField<Room>(
              value: _selectedRoom,
              items: _rooms.map((room) => DropdownMenuItem(value: room, child: Text(room.name))).toList(),
              onChanged: (val) => setState(() => _selectedRoom = val),
              decoration: const InputDecoration(labelText: 'Room'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text('Check-in: ${_checkIn.toString().split(' ')[0]}'),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(context: context, initialDate: _checkIn, firstDate: DateTime.now(), lastDate: DateTime(2100));
                    if (date != null) setState(() => _checkIn = date);
                  },
                  child: const Text('Select'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text('Check-out: ${_checkOut.toString().split(' ')[0]}'),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(context: context, initialDate: _checkOut, firstDate: _checkIn, lastDate: DateTime(2100));
                    if (date != null) setState(() => _checkOut = date);
                  },
                  child: const Text('Select'),
                ),
              ],
            ),
            TextFormField(
              controller: _specialRequestsController,
              decoration: const InputDecoration(labelText: 'Special Requests'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('Adults: '),
                TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() => _adults = int.tryParse(val) ?? 1),
                  initialValue: _adults.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 20),
                const Text('Children: '),
                TextFormField(
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() => _children = int.tryParse(val) ?? 0),
                  initialValue: _children.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['pending', 'confirmed', 'cancelled', 'completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => _status = val!),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Reservation'),
            ),
          ],
        ),
      ),
    );
  }
}
