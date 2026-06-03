class HotelService {
  final String serviceId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String? imageUrl;
  final bool isActive;

  HotelService({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.imageUrl,
    required this.isActive,
  });

  factory HotelService.fromMap(Map<String, dynamic> map) {
    return HotelService(
      serviceId: map['serviceId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'],
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }
}
