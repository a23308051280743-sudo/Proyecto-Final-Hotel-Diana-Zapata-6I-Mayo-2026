import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hotel/data/models/room.dart';
import 'package:hotel/data/models/service.dart';
import 'package:hotel/data/models/reservation.dart';
import 'package:hotel/data/services/firestore_service.dart';
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
                'https://images.unsplash.com/photo-1566073760409-4e075eec36ef?q=80&w=1000',
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 250,
                width: double.infinity,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
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
                  height: 300,
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
                              onSeeMore: () => context.go('/rooms/${snapshot.data!.roomId}'),
                            ),
                          );
                        },
                      ),
                    ),
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
                        childAspectRatio: 1.1,
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.spa, color: Colors.red),
                              SizedBox(height: 8),
                              Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('\$${service.price}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),

                const SectionTitle(title: 'Mis Próximas Reservas'),
                FutureBuilder<List<Reservation>>(
                  future: firestoreService.getMyReservations('currentUserUid'), // Replace with real UID
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    final reservations = snapshot.data!;
                    if (reservations.isEmpty) return const EmptyState(message: 'No tienes reservas próximas');

                    return Column(
                      children: [
                        ...reservations.take(3).map((res) => ReservationCard(
                          reservation: res,
                          onViewDetail: () => context.go('/reservations/${res.reservationId}'),
                        )),
                        if (reservations.length > 3)
                          TextButton(
                            onPressed: () => context.go('/reservations'),
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

