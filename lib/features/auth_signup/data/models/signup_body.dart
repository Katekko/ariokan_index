import 'package:json_annotation/json_annotation.dart';

part 'signup_body.g.dart';

@JsonSerializable()
class SignupBody {
  const SignupBody({
    required this.email,
    required this.password,
    required this.username,
  });

  factory SignupBody.fromJson(Map<String, dynamic> json) =>
      _$SignupBodyFromJson(json);

  final String email;
  final String password;
  final String username;

  Map<String, dynamic> toJson() => _$SignupBodyToJson(this);
}
