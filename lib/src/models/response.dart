import 'package:flutter/foundation.dart';

class IdntifyResponse {
  final bool result;
  final String error;
  final String message;
  final Map<String, dynamic> data;

  IdntifyResponse({
     @required this.result,
     @required this.error,
     @required this.message,
     @required this.data
  });

  factory IdntifyResponse.fromJson(Map<String, dynamic> json) {
    return IdntifyResponse(
      result: json['result'] as bool,
      error: json['error'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>
    );
  }
}
