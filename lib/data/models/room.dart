class Room {
  final String roomId;
  final String name;
  final String type;
  final String description;
  final double pricePerNight;
  final int capacity;
  final List<String> amenities;
  final List<String> imageUrls;
  final bool isAvailable;
  final int floor;

  Room({
    required this.roomId,
    required this.name,
    required this.type,
    required this.description,
    required this.pricePerNight,
    required this.capacity,
    required this.amenities,
    required this.imageUrls,
    required this.isAvailable,
    required this.floor,
  });

  factory Room.fromMap(Map<String, dynamic> map) {
    return Room(
      roomId: map['roomId'] ?? '',
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      description: map['description'] ?? '',
      pricePerNight: (map['pricePerNight'] as num).toDouble(),
      capacity: map['capacity'] ?? 0,
      amenities: List<String>.from(map['amenities'] ?? []),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      isAvailable: map['isAvailable'] ?? true,
      floor: map['floor'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'name': name,
      'type': type,
      'description': description,
      'pricePerNight': pricePerNight,
      'capacity': capacity,
      'amenities': amenities,
      'imageUrls': imageUrls,
      'isAvailable': isAvailable,
      'floor': floor,
    };
  }
}
