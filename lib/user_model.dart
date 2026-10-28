class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String avatar;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.avatar,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    return UserModel(
      id: rawId is int ? rawId : int.tryParse('$rawId') ?? 0,
      email: (json['email'] ?? '').toString(),
      firstName: (json['first_name'] ?? json['name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      avatar: (json['avatar'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
        'avatar': avatar,
      };
}
