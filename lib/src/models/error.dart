/// Exception custom wrapper.
/// [_message] is the received [mesage] in [IdntifyResponse]
/// [_prefix] is a status based on the HTTP code
class IdntifyException implements Exception {
  final _message;
  final _prefix;

  IdntifyException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

/// Wrapper around the 400 HTTP code.
class BadRequestException extends IdntifyException {
  BadRequestException([message]) : super(message, "Bad Request: ");
}

/// Wrapper around the 401 and 403 HTTP code.
class UnauthorisedException extends IdntifyException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

/// Wrapper around the 404 HTTP code.
class NotFoundException extends IdntifyException {
  NotFoundException([message]) : super(message, "Not found: ");
}

/// Wrapper around the 500 HTTP code.
class InternalServerException extends IdntifyException {
  InternalServerException([message])
      : super(message, "Internal Server Error: ");
}
