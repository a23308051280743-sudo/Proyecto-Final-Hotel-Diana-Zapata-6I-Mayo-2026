import 'package:cloud_firestore/cloud_firestore.dart';

class Reservation {
  final String reservationId;
  final String userId;
  final String roomId;
  final String roomName;
  final String guestName;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final double totalPrice;
  final String status;
  final int adults;
  final int children;
  final String? specialRequests;
  final DateTime createdAt;

  Reservation({
    required this.reservationId,
    required this.userId,
    required this.roomId,
    required this.roomName,
    required this.guestName,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.totalPrice,
    required this.status,
    required this.adults,
    required this.children,
    this.specialRequests,
    required this.createdAt,
  });

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      reservationId: map['reservationId'] ?? '',
      userId: map['userId'] ?? '',
      roomId: map['roomId'] ?? '',
      roomName: map['roomName'] ?? '',
      guestName: map['guestName'] ?? '',
      checkIn: (map['checkIn'] as Timestamp).toDate(),
      checkOut: (map['checkOut'] as Timestamp).toDate(),
      nights: map['nights'] ?? 0,
      totalPrice: (map['totalPrice'] as num).toDouble(),
      status: map['status'] ?? 'pending',
      adults: map['adults'] ?? 0,
      children: map['children'] ?? 0,
      specialRequests: map['specialRequests'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reservationId': reservationId,
      'userId': userId,
      'roomId': roomId,
      'roomName': roomName,
      'guestName': guestName,
      'checkIn': Timestamp.fromDate(checkIn),
      'checkOut': Timestamp.fromDate(checkOut),
      'nights': nights,
      'totalPrice': totalPrice,
      'status': status,
      'adults': adults,
      'children': children,
      'specialRequests': specialRequests,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
