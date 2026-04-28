class AppUser {
  final String uid;
  final String phone;
  final String role; // customer | seller | admin

  AppUser({
    required this.uid,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'phone': phone,
      'role': role,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      phone: map['phone'],
      role: map['role'],
    );
  }
}
