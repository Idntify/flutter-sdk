import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:idntify_widget/src/widgets/button.dart';
import 'package:idntify_widget/src/widgets/text.dart';

import 'package:extended_image/extended_image.dart';

/// Returns a widget that displays a screen with the cropper functionality.
///
/// An instaNce of the [GlobalKey<ExtendedImageEditorState>] passed as [editorKey] must be provided.
/// An [image] as bytes should also be provided.
///
/// Two functions can be provided that will be bind, [onRetry] to get back to the [Camera] widget (as the proccess is defined) and [onContinue] when the selection of the cropper is correct.
///
/// A [loading] argument can also be provided. If the value is true it'll show a loader.
///
/// TODO: The cropper proccess should be inside this class instead of the main [Idntify] widget.
/// You might probably change it to a [StatefulWidget].
class Cropper extends StatelessWidget {
  final editorKey;
  final Uint8List? image;
  final bool loading;
  final onRetry;
  final onContinue;

  Cropper(this.editorKey, this.image,
      {this.onRetry, this.onContinue, this.loading = false});

  Widget build(BuildContext context) {
    final List<Widget> defaultWidgets = [
      Flexible(
        child: ExtendedImage.memory(image!,
            fit: BoxFit.contain,
            mode: ExtendedImageMode.editor,
            extendedImageEditorKey: editorKey),
      ),
      InfoText('Asegurate de que los detalles se observen claramente',
          padding: 30),
      Row(
        children: <Button>[
          Button('Reintentar', alternative: true, onPressed: onRetry),
          Button(
            'Continuar',
            onPressed: onContinue,
          )
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      )
    ];

    return Expanded(
        child: !loading
            ? Column(
                children: <Widget>[...defaultWidgets],
                mainAxisAlignment: MainAxisAlignment.spaceAround)
            : Stack(children: <Widget>[
                Column(
                  children: defaultWidgets,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                ),
                SizedBox.expand(
                    child: Container(
                  child: Center(child: CircularProgressIndicator.adaptive()),
                  decoration:
                      BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.2)),
                )),
              ]));
  }
}
