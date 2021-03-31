import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:idntify_widget/widgets/button.dart';
import 'package:idntify_widget/widgets/text.dart';

import 'package:extended_image/extended_image.dart';

class Cropper extends StatelessWidget {
  final editorKey;
  final Uint8List image;
  final onRetry;
  final onContinue;

  Cropper(this.editorKey, this.image, {this.onRetry, this.onContinue});

  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
            children: <Widget>[
              Flexible(
                  child: ExtendedImage.memory(image,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.editor,
                  extendedImageEditorKey: editorKey
                ),
              ),
              InfoText('Asegurate de que los detalles se observen claramente', padding: 30),
              Row(
                  children: <Button>[
                    Button('Reintentar', alternative: true, onPressed: onRetry),
                    Button('Continuar', onPressed: onContinue,)
                  ], crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              )
            ], mainAxisAlignment: MainAxisAlignment.spaceAround
        )
    );
  }
}
