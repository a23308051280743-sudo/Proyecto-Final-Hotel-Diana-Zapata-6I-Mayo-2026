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
  final List<Map<String, dynamic>> services;

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
    this.services = const [],
  });

  static DateTime parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    } else if (value is DateTime) {
      return value;
    } else {
      return DateTime.now();
    }
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      reservationId: map['reservationId'] ?? '',
      userId: map['userId'] ?? '',
      roomId: map['roomId'] ?? '',
      roomName: map['roomName'] ?? '',
      guestName: map['guestName'] ?? '',
      checkIn: parseDateTime(map['checkIn']),
      checkOut: parseDateTime(map['checkOut']),
      nights: (map['nights'] as num?)?.toInt() ?? 0,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      adults: (map['adults'] as num?)?.toInt() ?? 0,
      children: (map['children'] as num?)?.toInt() ?? 0,
      specialRequests: map['specialRequests'],
      createdAt: parseDateTime(map['createdAt']),
      services: (map['services'] as List<dynamic>?)
              ?.map((item) => Map<String, dynamic>.from(item as Map))
              .toList() ??
          const [],
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
      'services': services,
    };
  }
}
