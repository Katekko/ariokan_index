import 'package:json_annotation/json_annotation.dart';

part 'login_body.g.dart';

@JsonSerializable()
class LoginBody {
  const LoginBody({required this.username, required this.password});

  factory LoginBody.fromJson(Map<String, dynamic> json) =>
      _$LoginBodyFromJson(json);

  final String username;
  final String password;

  Map<String, dynamic> toJson() => _$LoginBodyToJson(this);
}
