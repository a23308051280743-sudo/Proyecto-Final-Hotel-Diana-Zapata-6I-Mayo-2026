class User {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String? photoUrl;
  final DateTime createdAt;

  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'guest',
      photoUrl: map['photoUrl'],
      createdAt: (map['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
    };
  }
}
