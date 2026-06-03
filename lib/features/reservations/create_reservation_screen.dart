import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel/data/models/room.dart';
import 'package:hotel/data/models/reservation.dart';
import 'package:hotel/data/services/firestore_service.dart';
import 'package:hotel/widgets/primary_button.dart';
import 'package:hotel/features/auth/auth_provider.dart';


class CreateReservationScreen extends StatefulWidget {
  final String roomId;
  const CreateReservationScreen({super.key, required this.roomId});

  @override
  State<CreateReservationScreen> createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _adults = 1;
  int _children = 0;
  final TextEditingController _requestsController = TextEditingController();
  bool _isLoading = false;

  void _selectDate(BuildContext context, bool isCheckIn) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkIn = picked;
        } else {
          _checkOut = picked;
        }
      });
    }
  }

  int get _nights {
    if (_checkIn == null || _checkOut == null) return 0;
    return _checkOut!.difference(_checkIn!).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Reserva')),
      body: FutureBuilder<Room>(
        future: firestoreService.getRoom(widget.roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final room = snapshot.data!;

          double totalPrice = _nights * room.pricePerNight;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reserva de ${room.name}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Check-in'),
                        subtitle: Text(_checkIn == null ? 'Seleccionar' : _checkIn.toString().split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, true),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Check-out'),
                        subtitle: Text(_checkOut == null ? 'Seleccionar' : _checkOut.toString().split(' ')[0]),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),

                // Guests
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: const Text('Adultos'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _adults = _adults > 1 ? _adults - 1 : 1)),
                            Text('$_adults'),
                            IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _adults++)),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: const Text('Niños'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(icon: const Icon(Icons.remove), onPressed: () => setState(() => _children = _children > 0 ? _children - 1 : 0)),
                            Text('$_children'),
                            IconButton(icon: const Icon(Icons.add), onPressed: () => setState(() => _children++)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text('Solicitudes Especiales', style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: _requestsController,
                  maxLines: 3,
                  decoration: const InputDecoration(hintText: 'Ej. Cama matrimonial, piso alto...'),
                ),

                const SizedBox(height: 30),

                // Summary Card
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Resumen de la reserva', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const Divider(),
                        Text('Habitación: ${room.name}'),
                        Text('Noches: $_nights'),
                        Text('Huéspedes: ${_adults + _children}'),
                        SizedBox(height: 12),
                        Text('Total: \$${totalPrice.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                PrimaryButton(
                  text: 'CONFIRMAR RESERVA',
                  isLoading: _isLoading,
                  onPressed: () async {
                    if (_checkIn == null || _checkOut == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor selecciona las fechas')));
                      return;
                    }
                    if (_checkOut!.isBefore(_checkIn!)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El check-out debe ser posterior al check-in')));
                      return;
                    }
                    if (_adults + _children > room.capacity) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La cantidad de huéspedes excede la capacidad de la habitación')));
                      return;
                    }

                    setState(() => _isLoading = true);
                    final auth = Provider.of<AuthProvider>(context, listen: false);

                    final available = await firestoreService.checkAvailability(
                      roomId: room.roomId,
                      checkIn: _checkIn!,
                      checkOut: _checkOut!,
                    );

                    if (!available) {
                      setState(() => _isLoading = false);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La habitación no está disponible para las fechas seleccionadas')));
                      return;
                    }

                    final reservation = Reservation(
                      reservationId: '', // Firestore auto-generates
                      userId: auth.currentUid,
                      roomId: room.roomId,
                      roomName: room.name,
                      guestName: auth.currentUser?.name ?? 'Huésped',
                      checkIn: _checkIn!,
                      checkOut: _checkOut!,
                      nights: _nights,
                      totalPrice: totalPrice,
                      status: 'pending',
                      adults: _adults,
                      children: _children,
                      specialRequests: _requestsController.text,
                      createdAt: DateTime.now(),
                    );

                    await firestoreService.createReservation(reservation);
                    setState(() => _isLoading = false);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva creada exitosamente')));
                      context.go('/reservations');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
