import 'package:json_annotation/json_annotation.dart';

part 'signup_response.g.dart';

@JsonSerializable()
class SignupResponse {
  const SignupResponse({
    required this.userId,
    required this.email,
    required this.success,
    this.error,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) =>
      _$SignupResponseFromJson(json);

  final String userId;
  final String email;
  final bool success;
  final String? error;

  Map<String, dynamic> toJson() => _$SignupResponseToJson(this);
}
