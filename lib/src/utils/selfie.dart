import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:idntify_widget/idntify_widget.dart';

Future<void> getSelfie(CameraController cameraController, IdntifyApiService apiService) async {
  try {
    await cameraController.prepareForVideoRecording();
    await cameraController.startVideoRecording();

    await Future.delayed(const Duration(seconds: 1));

    XFile video = await cameraController.stopVideoRecording();

    await Future.delayed(const Duration(seconds: 2));

    final XFile image = await cameraController.takePicture();

    Uint8List videoBytes = await video.readAsBytes();
    Uint8List imageBytes = await image.readAsBytes();

    await apiService.addSelfie(imageBytes, videoBytes);

  } catch (error) {
    print(error);
    if (error.toString().contains('Server')) {
      getSelfie(cameraController, apiService);
    }
  }
}
