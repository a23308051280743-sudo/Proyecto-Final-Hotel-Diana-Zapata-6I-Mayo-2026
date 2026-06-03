import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:hotel/data/models/user.dart';
import 'package:hotel/data/models/room.dart';
import 'package:hotel/data/models/reservation.dart';
import 'package:hotel/data/models/service.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Users
  Future<User> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return User.fromMap(doc.data()!);
  }

  Future<List<User>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs.map((doc) => User.fromMap(doc.data()!)).toList();
  }

  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future<void> createUser(User user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  // Rooms
  Future<List<Room>> getRooms() async {
    final snapshot = await _db.collection('rooms').get();
    return snapshot.docs.map((doc) => Room.fromMap({...doc.data()!, 'roomId': doc.id})).toList();
  }

  Future<Room> getRoom(String roomId) async {
    final doc = await _db.collection('rooms').doc(roomId).get();
    return Room.fromMap({...doc.data()!, 'roomId': doc.id});
  }

  Future<void> createRoom(Room room) async {
    await _db.collection('rooms').add(room.toMap());
  }

  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    await _db.collection('rooms').doc(roomId).update(data);
  }

  Future<void> deleteRoom(String roomId) async {
    await _db.collection('rooms').doc(roomId).delete();
  }

  // Reservations
  Future<List<Reservation>> getAllReservations() async {
    final snapshot = await _db.collection('reservations')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Reservation.fromMap({...doc.data()!, 'reservationId': doc.id})).toList();
  }

  Future<List<Reservation>> getMyReservations(String userId) async {
    final snapshot = await _db.collection('reservations')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Reservation.fromMap({...doc.data()!, 'reservationId': doc.id})).toList();
  }

  Future<Reservation> getReservation(String reservationId) async {
    final doc = await _db.collection('reservations').doc(reservationId).get();
    return Reservation.fromMap({...doc.data()!, 'reservationId': doc.id});
  }

  Future<void> createReservation(Reservation reservation) async {
    await _db.collection('reservations').add(reservation.toMap());
  }

  Future<void> updateReservation(String reservationId, Map<String, dynamic> data) async {
    await _db.collection('reservations').doc(reservationId).update(data);
  }

  Future<void> deleteReservation(String reservationId) async {
    await _db.collection('reservations').doc(reservationId).delete();
  }

  Future<void> cancelReservation(String reservationId) async {
    await _db.collection('reservations').doc(reservationId).update({'status': 'cancelled'});
  }

  // Services
  Future<List<HotelService>> getServices() async {
    final snapshot = await _db.collection('services').get();
    return snapshot.docs.map((doc) => HotelService.fromMap({...doc.data()!, 'serviceId': doc.id})).toList();
  }

  Future<void> createService(HotelService service) async {
    await _db.collection('services').add(service.toMap());
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    await _db.collection('services').doc(serviceId).update(data);
  }

  Future<void> deleteService(String serviceId) async {
    await _db.collection('services').doc(serviceId).delete();
  }


  // Stats
  Future<Map<String, dynamic>> getAdminStats() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final reservationsSnapshot = await _db.collection('reservations').get();
    final reservations = reservationsSnapshot.docs;

    int activeReservations = 0;
    int occupiedToday = 0;
    double monthlyRevenue = 0;

    for (var doc in reservations) {
      final data = doc.data();
      final status = data['status'] as String;
      final checkIn = (data['checkIn'] as Timestamp).toDate();
      final checkOut = (data['checkOut'] as Timestamp).toDate();
      final totalPrice = (data['totalPrice'] as num).toDouble();
      final createdAt = (data['createdAt'] as Timestamp).toDate();

      if (status == 'pending' || status == 'confirmed') {
        activeReservations++;
        if (now.isAfter(checkIn) && now.isBefore(checkOut)) {
          occupiedToday++;
        }
      }

      if (status == 'confirmed' &&
          createdAt.isAfter(startOfMonth) &&
          createdAt.isBefore(endOfMonth)) {
        monthlyRevenue += totalPrice;
      }
    }

    return {
      'activeReservations': activeReservations,
      'occupiedToday': occupiedToday,
      'monthlyRevenue': monthlyRevenue,
    };
  }

  // Room Availability Check Logic from Spec
  Future<bool> checkAvailability({
    required String roomId,
    required DateTime checkIn,
    required DateTime checkOut,
  }) async {
    final query = await _db.collection('reservations')
        .where('roomId', isEqualTo: roomId)
        .where('status', whereIn: ['pending', 'confirmed'])
        .get();

    for (final doc in query.docs) {
      final data = doc.data();
      final existingCheckIn = (data['checkIn'] as Timestamp).toDate();
      final existingCheckOut = (data['checkOut'] as Timestamp).toDate();

      // Hay solapamiento si: nueva checkIn < existente checkOut
      //                   Y nueva checkOut > existente checkIn
      if (checkIn.isBefore(existingCheckOut) &&
          checkOut.isAfter(existingCheckIn)) {
        return false; // No disponible
      }
    }
    return true; // Disponible
  }
}
