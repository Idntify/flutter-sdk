import 'package:flutter/foundation.dart';

/// Response object based on what the server retrieves.
///
/// [result] is a boolean that depends on the success of the request
/// [error] will receive a null if the [result] is true, otherwise it'll receive an error code
/// [message] is a personalized message based on the [result] and [error]
/// [data] is any aditional (requested) information
class IdntifyResponse {
  final bool? result;
  final String? error;
  final String? message;
  final Map<String, dynamic>? data;

  IdntifyResponse(
      {required this.result,
      required this.error,
      required this.message,
      required this.data});

  factory IdntifyResponse.fromJson(Map<String, dynamic> json) {
    return IdntifyResponse(
        result: json['result'] as bool?,
        error: json['error'] as String?,
        message: json['message'] as String?,
        data: json['data'] as Map<String, dynamic>?);
  }
}
