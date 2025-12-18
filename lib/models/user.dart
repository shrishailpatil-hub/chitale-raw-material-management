class User {
  final String username;
  final String password;
  final String role; // 'ADMIN' or 'QC'
  final String name;

  User({
    required this.username,
    required this.password,
    required this.role,
    required this.name,
  });

  // Convert to Map (for Database)
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'role': role,
      'name': name,
    };
  }

  // Create User from Database Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      username: map['username'],
      password: map['password'],
      role: map['role'],
      name: map['name'],
    );
  }
}