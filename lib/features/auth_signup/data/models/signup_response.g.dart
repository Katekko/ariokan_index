// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignupResponse _$SignupResponseFromJson(Map<String, dynamic> json) =>
    SignupResponse(
      userId: json['userId'] as String,
      email: json['email'] as String,
      success: json['success'] as bool,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$SignupResponseToJson(SignupResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'email': instance.email,
      'success': instance.success,
      'error': instance.error,
    };
