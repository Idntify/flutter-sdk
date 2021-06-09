import 'dart:typed_data';
import 'dart:convert';

import 'package:idntify_widget/src/models/document_type.dart';
import 'package:idntify_widget/src/models/error.dart';
import 'package:idntify_widget/src/models/response.dart';
import 'package:idntify_widget/src/models/stage.dart';

import 'package:http/http.dart';

/// Handles the petitions to the API.
///
/// You should create an instance of ̣̣[IdntifyApiService] in order to use,
/// passing the required function arguments: [apiKey] (provided by the IDntify service),
/// [origin] (set in the IDntify platform), and the optional argument [stage]
/// for the environment to use.
///
/// Keep in mind that the class functions are expected to be use in this sequence:
/// 1. [createTransaction()] for creating the transaction reference
/// 2. [addDocument()] for saving the ID pictures.
/// 3. [addSelfie()] for saving the user's selfie.
///
/// If you don't use those functions in that sequence it'll work but will return a custom
/// error from the server.
class IdntifyApiService {
  late String _base;
  String? _transactionKey;
  final String apiKey;
  final Stage? stage;
  final String origin;

  IdntifyApiService(this.apiKey, this.origin, {this.stage = Stage.dev}) {
    this._base =
        this.stage == Stage.dev ? 'api.stage.idntify.io' : 'api.idntify.io';
  }

  /// Creates a new transaction.
  ///
  /// **You should use this functions first before accessing the other ones.**
  ///
  /// Based on the [apiKey] and the [origin] variables passed in the
  /// class constructure, it'll send a request to create a new transaction.
  /// If any of those values are not in the service DB then it's going to
  /// return a custom error, if that's not the case then the class will set a
  /// [_transactionKey] which other functions will use and return a [IdntifyResponse].
  Future<IdntifyResponse> createTransaction() async {
    const String endpoint = 'v1/widget/transaction';
    final Map<String, String> headers = {'x-api-key': apiKey};
    Map<String, String> payload = {'origin': origin};

    try {
      Response res = await post(Uri.https(_base, endpoint),
          headers: headers, body: jsonEncode(payload));
      Map<String, dynamic> body = jsonDecode(res.body);

      IdntifyResponse parsedBody = IdntifyResponse.fromJson(body);

      if (res.statusCode != 200) {
        return Future.error(_handleResponseError(res.statusCode, parsedBody));
      }

      _transactionKey = parsedBody.data!['transactionToken'];

      return parsedBody;
    } catch (error) {
      return Future.error(error);
    }
  }

  /// Saves a document (frontal/reverse ID image).
  ///
  /// **This functions should be executed after [createTransaction()] and before [addSelfie()],  /// and you should also send the frontal ID image first and then the reverse ID image. **
  ///
  /// Given a [Uint8List] data (of an image file) and a [DocumentType] of the kind of image,
  /// it'll save the image and return a [IdntifyResponse], if something went wrong then it'll
  /// return a custom error.
  Future<IdntifyResponse> addDocument(Uint8List data, DocumentType type) async {
    const String endpoint = 'v1/widget/transaction/document';
    final Map<String, String?> headers = {'x-transaction-key': _transactionKey};

    try {
      final String dataB64 = base64Encode(data.toList());
      final Map<String, String?> payload = {
        'd': 'data:image/png;base64,$dataB64',
        's': type.name
      };
      Response res = await post(Uri.https(_base, endpoint),
          headers: headers as Map<String, String>?, body: json.encode(payload));
      Map<String, dynamic> body = jsonDecode(res.body);

      IdntifyResponse parsedBody = IdntifyResponse.fromJson(body);

      if (res.statusCode != 200) {
        return Future.error(_handleResponseError(res.statusCode, parsedBody));
      }

      return parsedBody;
    } catch (error) {
      return Future.error(error);
    }
  }

  /// Saves the selfie recording and snapshot.
  ///
  /// **This functions should be executed after [createTransaction()] and [addSelfie()].**
  ///
  /// Given a [Uint8List] data of a selfie snapshot file and the selfie video file,
  /// it'll both files and return a [IdntifyResponse] including if the **transaction is finished and the result of it**, if something went wrong then it'll return a custom error.
  Future<IdntifyResponse> addSelfie(
      Uint8List selfieImageData, Uint8List selfieVideoData) async {
    const String endpoint = 'v1/widget/transaction/document/selfie';
    final Map<String, String?> headers = {'x-transaction-key': _transactionKey};

    try {
      final String imageB64 = base64Encode(selfieImageData.toList());
      final String videoB64 = base64Encode(selfieVideoData.toList());
      final Map<String, String> payload = {
        'd': 'data:image/png;base64,$imageB64',
        's': 's',
        't': 'video/mp4',
        'v': videoB64
      };

      Response res = await post(Uri.https(_base, endpoint),
          headers: headers as Map<String, String>?, body: jsonEncode(payload));
      Map<String, dynamic> body = jsonDecode(res.body);

      IdntifyResponse parsedBody = IdntifyResponse.fromJson(body);

      if (res.statusCode != 200) {
        return Future.error(_handleResponseError(res.statusCode, parsedBody));
      }

      return parsedBody;
    } catch (error) {
      return Future.error(error);
    }
  }

  /// Returns a custom error depending on the response of the HTTP petition ([IdntifyResponse])
  /// and the [statusCode].
  dynamic _handleResponseError(int statusCode, IdntifyResponse response) {
    final String? errorCode = response.error;
    final String? errorMessage = response.message;
    final String error = "$errorMessage ($errorCode)";

    switch (statusCode) {
      case 400:
        return BadRequestException(error);
      case 401:
      case 403:
        return UnauthorisedException(error);
      default:
        return InternalServerException(error);
    }
  }
}
