import 'dart:typed_data';

import 'package:idntify_widget/idntify_widget.dart';
import 'package:idntify_widget/src/models/document_type.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List> pickImage(ImagePicker imagePicker) async {
  try {
    final PickedFile? pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);

    if (pickedFile == null) {
      throw 'No image selected';
    }

    return await pickedFile.readAsBytes();
  } catch (error) {
    rethrow;
  }
}

Future setImage(
    Uint8List image, IdntifyApiService apiService, DocumentType docType) async {
  try {
    return await apiService.addDocument(image, docType);
  } catch (error) {
    rethrow;
  }
}
