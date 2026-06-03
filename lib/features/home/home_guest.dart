import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel/data/models/room.dart';
import 'package:hotel/data/models/service.dart';
import 'package:hotel/data/models/reservation.dart';
import 'package:hotel/data/services/firestore_service.dart';
import 'package:hotel/features/auth/auth_provider.dart';
import 'package:hotel/widgets/room_card.dart';
import 'package:hotel/widgets/section_title.dart';
import 'package:hotel/widgets/reservation_card.dart';
import 'package:hotel/widgets/empty_state.dart';
import 'package:hotel/features/rooms/room_catalog_screen.dart';
import 'package:hotel/features/reservations/my_reservations_screen.dart';
import 'package:hotel/features/profile/profile_screen.dart';

class HomeGuest extends StatefulWidget {
  const HomeGuest({super.key});

  @override
  State<HomeGuest> createState() => _HomeGuestState();
}

class _HomeGuestState extends State<HomeGuest> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeGuestContent(),
    const RoomCatalogScreen(),
    const MyReservationsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Luxury Moonsea'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => _onItemTapped(3),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.bed), label: 'Habitaciones'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Mis Reservas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class HomeGuestContent extends StatelessWidget {
  const HomeGuestContent({super.key});

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'wellness':
        return Icons.spa;
      case 'transport':
        return Icons.directions_car;
      case 'other':
      default:
        return Icons.room_service;
    }
  }

  void _showServiceDetailBottomSheet(BuildContext context, HotelService service) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUid;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String? selectedReservationId;
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return FutureBuilder<List<Reservation>>(
              future: firestoreService.getMyReservations(userId),
              builder: (context, snapshot) {
                final reservations = snapshot.data ?? [];
                // Filter only active reservations that are 'pending' or 'confirmed'
                final activeReservations = reservations
                    .where((r) => r.status == 'pending' || r.status == 'confirmed')
                    .toList();

                return Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.category.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\$${service.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Descripción',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        service.description,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Cargar a Reservación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Center(child: CircularProgressIndicator())
                      else if (activeReservations.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            border: Border.all(color: Colors.amber.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'No tienes reservaciones activas (Pendientes o Confirmadas) para cargar este servicio.',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Selecciona una reservación',
                          ),
                          initialValue: selectedReservationId,
                          items: activeReservations.map((res) {
                            return DropdownMenuItem<String>(
                              value: res.reservationId,
                              child: Text(
                                '${res.roomName} (${res.checkIn.toString().split(' ')[0]} al ${res.checkOut.toString().split(' ')[0]})',
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setModalState(() {
                              selectedReservationId = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: selectedReservationId == null || isSaving
                                ? null
                                : () async {
                                    setModalState(() {
                                      isSaving = true;
                                    });
                                    try {
                                      final selectedRes = activeReservations.firstWhere((r) => r.reservationId == selectedReservationId);
                                      await firestoreService.addServiceToReservation(
                                        selectedReservationId!,
                                        service,
                                      );
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Servicio "${service.name}" cargado con éxito a la reserva de ${selectedRes.roomName}',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error al cargar servicio: $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } finally {
                                      if (context.mounted) {
                                        setModalState(() {
                                          isSaving = false;
                                        });
                                      }
                                    }
                                  },
                            child: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('AGREGAR AL COBRO'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner destacado
          Stack(
            children: [
              Image.network(
                'https://raw.githubusercontent.com/a23308051280743-sudo/imagenes/refs/heads/main/image_1769691025367.webp',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 250,
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                child: Center(
                  child: Text(
                    'Reserva tu experiencia perfecta',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle(title: 'Habitaciones Destacadas'),
                SizedBox(
                  height: 440,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4, // Demo
                    itemBuilder: (context, index) {
                      return FutureBuilder<Room>(
                        future: firestoreService.getRooms().then((rooms) => rooms[index % rooms.length]),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox(width: 200, child: Center(child: CircularProgressIndicator()));
                          return SizedBox(
                            width: 280,
                            child: RoomCard(
                              room: snapshot.data!,
                              imageHeight: 180,
                              onSeeMore: () => context.push('/rooms/${snapshot.data!.roomId}'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),


                const SectionTitle(title: 'Nuestros Servicios'),
                FutureBuilder<List<HotelService>>(
                  future: firestoreService.getServices(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final services = snapshot.data!;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.15,
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return Card(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showServiceDetailBottomSheet(context, service),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getServiceIcon(service.category),
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    service.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text('\$${service.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                const SectionTitle(title: 'Mis Próximas Reservas'),
                FutureBuilder<List<Reservation>>(
                  future: firestoreService.getMyReservations(Provider.of<AuthProvider>(context, listen: false).currentUid),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final reservations = snapshot.data!;
                    if (reservations.isEmpty) return const EmptyState(message: 'No tienes reservas próximas');

                    return Column(
                      children: [
                        ...reservations.take(3).map((res) => ReservationCard(
                          reservation: res,
                          onViewDetail: () => context.push('/reservations/${res.reservationId}'),
                        )),
                        if (reservations.length > 3)
                          TextButton(
                            onPressed: () => context.push('/reservations'),
                            child: const Text('Ver todas'),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

