class IdntifyException implements Exception {
  final _message;
  final _prefix;

  IdntifyException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

// 400
class BadRequestException extends IdntifyException {
  BadRequestException([message]) : super(message, "Bad Request: ");
}

// 401, 403
class UnauthorisedException extends IdntifyException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

// 404
class NotFoundException extends IdntifyException {
  NotFoundException([message]) : super(message, "Not found: ");
}

// 500
class InternalServerException extends IdntifyException {
  InternalServerException([message])
      : super(message, "Internal Server Error: ");
}
