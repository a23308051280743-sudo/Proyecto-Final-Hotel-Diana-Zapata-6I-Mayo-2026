import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel/data/models/room.dart';
import 'package:hotel/data/models/service.dart';
import 'package:hotel/data/services/firestore_service.dart';

class SeedService {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> seedDatabase() async {
    await _seedRooms();
    await _seedServices();
  }

  Future<void> _seedRooms() async {
    final rooms = [
      Room(
        roomId: '',
        name: 'Suite Presidencial',
        type: 'suite',
        description: 'La habitación más lujosa del hotel, con vistas panorámicas y acabados de primera.',
        pricePerNight: 350.0,
        capacity: 2,
        amenities: ['WiFi', 'TV', 'Jacuzzi', 'Minibar', 'Caja fuerte'],
        imageUrls: ['https://images.unsplash.com/photo-1582719478250-7da22418737e?q=80&w=1000'],
        isAvailable: true,
        floor: 10,
      ),
      Room(
        roomId: '',
        name: 'Suite Junior',
        type: 'suite',
        description: 'Espacio y confort combinados para una estancia inolvidable.',
        pricePerNight: 220.0,
        capacity: 2,
        amenities: ['WiFi', 'TV', 'Minibar', 'Caja fuerte'],
        imageUrls: ['https://images.unsplash.com/photo-1590490367563-16a6a6056776?q=80&w=1000'],
        isAvailable: true,
        floor: 8,
      ),
      Room(
        roomId: '',
        name: 'Habitación Doble Deluxe',
        type: 'double',
        description: 'Habitación amplia ideal para parejas o familias pequeñas.',
        pricePerNight: 140.0,
        capacity: 3,
        amenities: ['WiFi', 'TV', 'Minibar'],
        imageUrls: ['https://images.unsplash.com/photo-1566609370769-7372ee479171?q=80&w=1000'],
        isAvailable: true,
        floor: 4,
      ),
      Room(
        roomId: '',
        name: 'Habitación Doble Estándar',
        type: 'double',
        description: 'Todas las comodidades esenciales para un descanso reparador.',
        pricePerNight: 95.0,
        capacity: 2,
        amenities: ['WiFi', 'TV'],
        imageUrls: ['https://images.unsplash.com/photo-1631049308372-271679578327?q=80&w=1000'],
        isAvailable: true,
        floor: 2,
      ),
      Room(
        roomId: '',
        name: 'Habitación Individual',
        type: 'single',
        description: 'Perfecta para viajeros solitarios que buscan tranquilidad y eficiencia.',
        pricePerNight: 70.0,
        capacity: 1,
        amenities: ['WiFi', 'TV'],
        imageUrls: ['https://images.unsplash.com/photo-1522770179533-2475cf894307?q=80&w=1000'],
        isAvailable: true,
        floor: 2,
      ),
      Room(
        roomId: '',
        name: 'Habitación Familiar',
        type: 'family',
        description: 'Diseñada para el disfrute de toda la familia con espacio de sobra.',
        pricePerNight: 180.0,
        capacity: 5,
        amenities: ['WiFi', 'TV', 'Minibar', 'Caja fuerte'],
        imageUrls: ['https://images.unsplash.com/photo-1595526761200-ee976f586727?q=80&w=1000'],
        isAvailable: true,
        floor: 6,
      ),
    ];

    for (var room in rooms) {
      await _firestoreService.createRoom(room);
    }
  }

  Future<void> _seedServices() async {
    final services = [
      HotelService(
        serviceId: '',
        name: 'Desayuno buffet',
        description: 'Variedad de frutas frescas, panes artesanales y jugos naturales.',
        price: 18.0,
        category: 'food',
        imageUrl: 'https://images.unsplash.com/photo-1496070539351-e1aa23827471?q=80&w=1000',
        isActive: true,
      ),
      HotelService(
        serviceId: '',
        name: 'Spa & Masajes',
        description: 'Relajación profunda con terapias especializadas y ambiente zen.',
        price: 80.0,
        category: 'wellness',
        imageUrl: 'https://images.unsplash.com/photo-1544161515-f744659f1457?q=80&w=1000',
        isActive: true,
      ),
      HotelService(
        serviceId: '',
        name: 'Transfer aeropuerto',
        description: 'Transporte privado y puntual desde y hacia el aeropuerto.',
        price: 45.0,
        category: 'transport',
        imageUrl: 'https://images.unsplash.com/photo-1449965409990-d47565885330?q=80&w=1000',
        isActive: true,
      ),
      HotelService(
        serviceId: '',
        name: 'Room service 24h',
        description: 'Gastronomía de alta calidad entregada directamente en su habitación.',
        price: 0.0,
        category: 'food',
        imageUrl: 'https://images.unsplash.com/photo-15209383y20-c31c824b6424?q=80&w=1000', // Fixed URL
        isActive: true,
      ),
      HotelService(
        serviceId: '',
        name: 'Gimnasio',
        description: 'Equipos de última generación para mantener su rutina de ejercicio.',
        price: 0.0,
        category: 'wellness',
        imageUrl: 'https://images.unsplash.com/photo-1534438373606-87173f1a1797?q=80&w=1000',
        isActive: true,
      ),
    ];

    for (var service in services) {
      await _firestoreService.createService(service);
    }
  }
}
