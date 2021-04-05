import 'package:flutter/material.dart';

import 'package:idntify_widget/src/models/instruction_image.dart';
import 'package:idntify_widget/src/widgets/text.dart';

class Instructions extends StatelessWidget {
  final InstructionImage image;
  final String text;

  Instructions(this.text, this.image);

  Widget build(context) {
    return Expanded(
        child: Column(
      children: <Widget>[
        Image.asset(image.name, scale: 2, package: 'idntify_widget'),
        Padding(
          padding: EdgeInsets.only(top: 15),
          child: InfoText(text, bold: true, size: 24, color: Colors.black),
        )
      ],
      mainAxisAlignment: MainAxisAlignment.center,
    ));
  }
}
