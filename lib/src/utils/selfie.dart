import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:idntify_widget/idntify_widget.dart';

Future<Map<String, Uint8List>> getSelfie(
    CameraController cameraController, IdntifyApiService apiService) async {
  await cameraController.prepareForVideoRecording();
  await cameraController.startVideoRecording();

  await Future.delayed(Duration(seconds: 1));

  XFile video = await cameraController.stopVideoRecording();

  await Future.delayed(Duration(seconds: 2));

  final XFile image = await cameraController.takePicture();

  Uint8List videoBytes = await video.readAsBytes();
  Uint8List imageBytes = await image.readAsBytes();

  return {'video': videoBytes, 'image': imageBytes};
}
