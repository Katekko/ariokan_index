import 'package:equatable/equatable.dart';

/// Immutable User entity (T017)
class User extends Equatable {
  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
  });

  factory User.fromMap(Map<String, Object?> map) => User(
    id: map['id'] as String,
    username: map['username'] as String,
    email: map['email'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
  );

  final String id;
  final String username; // immutable unique handle
  final String email;
  final DateTime createdAt;

  User copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email ?? this.email,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'username': username,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  String toString() => 'User(id: $id, username: $username, email: $email)';

  @override
  List<Object?> get props => [id, username, email, createdAt];
}
