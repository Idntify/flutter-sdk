import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:convert';

import 'package:idntify_widget/models/document_type.dart';
import 'package:idntify_widget/models/response.dart';
import 'package:idntify_widget/models/stage.dart';

import 'package:http/http.dart';

class IdntifyApiService {
  String _base;
  String _transactionKey;
  final String apiKey;
  final Stage stage; 
  final String origin;

  IdntifyApiService(this.apiKey, {this.stage, this.origin}) {
    this._base = this.stage == Stage.dev ? 'api.stage.idntify.io' : 'api.idntify.io';  
  }

  Future<void> createTransaction() async {
    const String endpoint = 'v1/widget/transaction';
    final Map<String, String> headers = {'x-api-key': apiKey};
    Map<String, String> payload = {'origin': origin};

    try {
      Response res = await post(Uri.https(_base, endpoint), headers: headers, body: jsonEncode(payload));
      Map<String, dynamic> body = jsonDecode(res.body);

      IdntifyResponse parsedBody = IdntifyResponse.fromJson(body);

      if (res.statusCode != 200) {
        developer.log('Server error', error: parsedBody);
        return Future.error(parsedBody);
      }

      _transactionKey = parsedBody.data['transactionToken'];
    } catch (error) {
      developer.log('Client error', error: error);
      return Future.error(error);
    }
  }

  Future<void> addDocument(Uint8List data, DocumentType type) async {
    const String endpoint = 'v1/widget/transaction/document';
    final Map<String, String> headers = {'x-transaction-key': _transactionKey};

    try {
      final String dataB64 = base64Encode(data.toList());
      final Map<String, String> payload = {'d': 'data:image/png;base64,${dataB64}', 's': type.name};
      Response res = await post(Uri.https(_base, endpoint), headers: headers, body: json.encode(payload));
      Map<String, dynamic> body = jsonDecode(res.body);

      IdntifyResponse parsedBody = IdntifyResponse.fromJson(body);

      if (res.statusCode != 200) {
        developer.log('Server error', error: parsedBody);
        return Future.error(parsedBody);
      }

    } catch (error) {
      developer.log('Client error', error: error);
      return Future.error(error);
    }
  }

  Future<void> addSelfie(Uint8List selfieImageData, Uint8List selfieVideoData) async {
    const String endpoint = 'v1/widget/transaction/document/selfie';
    final Map<String, String> headers = {'x-transaction-key': _transactionKey};

    try {
      final String imageB64 = base64Encode(selfieImageData.toList());
      final String videoB64 = base64Encode(selfieVideoData.toList());
      final Map<String, String> payload = {'d': 'data:image/png;base64,${imageB64}', 's': 's', 't': 'video/mp4', 'v': videoB64};

      Response res = await post(Uri.https(_base, endpoint), headers: headers, body: jsonEncode(payload));
      Map<String, dynamic> body = jsonDecode(res.body);

      IdntifyResponse parsedBody = IdntifyResponse.fromJson(body);

      if (res.statusCode != 200) {
        developer.log('Server error', error: parsedBody);
        return Future.error(parsedBody);
      }

    } catch (error) {
      developer.log('Client error', error: error);
      return Future.error(error);
    }
  }

}