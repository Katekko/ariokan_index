// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_body.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupBody _$SignupBodyFromJson(Map<String, dynamic> json) => SignupBody(
  email: json['email'] as String,
  password: json['password'] as String,
  username: json['username'] as String,
);

Map<String, dynamic> _$SignupBodyToJson(SignupBody instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'username': instance.username,
    };
