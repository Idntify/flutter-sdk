import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:idntify_widget/idntify_widget.dart';

/// Given a [CameraController] it tries to record a second of video and a quick snapshot
/// of the selfie and returns the bytes of both files.
///
/// The one-second delay is the time taken to record the selfie, the two-seconds delay is
/// to prevent the app to crash.
///
/// It can be reduced if you can take a snaphost from the video file, couldn't find a way to do it.
Future<Map<String, Uint8List>> getSelfie(
    CameraController cameraController) async {
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
