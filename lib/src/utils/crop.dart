import 'package:extended_image/extended_image.dart';
import 'package:image_editor/image_editor.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

/// Crops an image.
///
/// The image gets cropped based on the user selection and the values and functions are taken out
/// of the [GlobalKey<ExtendedImageEditorState>] passed as [editorKey].
Future<Uint8List?> cropImage(editorKey) async {
  final state = editorKey.currentState;
  final Rect? cropRect = state.getCropRect();
  final EditActionDetails action = state.editAction;

  final int rotateAngle = action.rotateAngle.toInt();
  final bool flipHorizontal = action.flipY;
  final bool flipVertical = action.flipX;
  final Uint8List img = state.rawImageData;

  final ImageEditorOption option = ImageEditorOption();
  if (action.needCrop) {
    option.addOption(ClipOption.fromRect(cropRect!));
  }

  if (action.needFlip) {
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
  }

  if (action.hasRotateAngle) {
    option.addOption(RotateOption(rotateAngle));
  }

  try {
    final Uint8List? result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    return result;
  } catch (error) {
    rethrow;
  }
}
