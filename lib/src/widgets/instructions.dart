import 'package:flutter/material.dart';

import 'package:idntify_widget/src/models/instruction_image.dart';
import 'package:idntify_widget/src/widgets/text.dart';

/// Widget that displays a screen with an icon and a text based on a specific instruction information.
///
/// It's intended to be used when a big icon with a small text is required to be displayed in the whole screen.
///
/// Returns an [Expanded] widget given an [InstructionImage] (which depends on the kind of instruction) and a [String] text.
class Instructions extends StatelessWidget {
  final InstructionImage image;
  final String text;

  Instructions(this.text, this.image);

  Widget build(context) {
    return Expanded(
        child: Column(
      children: <Widget>[
        Image.asset(image.name!, scale: 2, package: 'idntify_widget'),
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: InfoText(text, bold: true, size: 24, color: Colors.black),
        )
      ] as List<Widget>,
      mainAxisAlignment: MainAxisAlignment.center,
    ));
  }
}
