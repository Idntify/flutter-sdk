import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:idntify_widget/src/widgets/button.dart';
import 'package:idntify_widget/src/widgets/text.dart';

import 'package:extended_image/extended_image.dart';

class Cropper extends StatelessWidget {
  final editorKey;
  final Uint8List image;
  final bool loading;
  final onRetry;
  final onContinue;

  Cropper(this.editorKey, this.image, {this.onRetry, this.onContinue, this.loading = false});

  Widget build(BuildContext context) {
    final List<Widget> defaultWidgets = [
      Flexible(
          child: ExtendedImage.memory(image,
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
        child: !loading ? Column(children: <Widget>[ 
            ...defaultWidgets  
        ], mainAxisAlignment: MainAxisAlignment.spaceAround) : 
        Stack(
            children: <Widget>[
              Column(children: defaultWidgets, mainAxisAlignment: MainAxisAlignment.spaceAround,),
              SizedBox.expand(
                  child: Container(
                      child: Center(child: CircularProgressIndicator.adaptive()),
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(0, 0, 0, 0.2)
                      ),
                  )
              ), 
            ]
        ));
  }
}
