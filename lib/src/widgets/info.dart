import 'package:flutter/material.dart';

import 'package:idntify_widget/src/models/info_icon.dart';
import 'package:idntify_widget/src/widgets/button.dart';
import 'package:idntify_widget/src/widgets/image_picker_selector.dart';
import 'package:idntify_widget/src/widgets/text.dart';

/// Widget that returrn
///
class Info extends StatelessWidget {
  final InfoIcon? icon;
  final String? title;
  final List<InfoText>? texts;
  final List<Button>? buttons;
  final ImagePickerSelector? imagePicker;

  Info({this.icon, this.title, this.texts, this.buttons, this.imagePicker});

  Widget build(context) {
    double width = MediaQuery.of(context).size.width;

    return Expanded(
        child: Column(children: <Widget?>[
      if (icon != null) ...{
        Image.asset(icon.name!,
            scale: width < 400 ? 2.2 : 1.6, package: 'idntify_widget')
      },
      if (title != null) ...{
        InfoText(title, bold: true, size: 24, color: Colors.black)
      },
      Flexible(
          child: Column(
            children: texts ?? [],
            mainAxisSize: MainAxisSize.min,
          ),
          fit: FlexFit.loose,
          flex: 2),
      if (imagePicker != null) ...{imagePicker},
      Row(
        children: buttons ?? [],
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      )
    ], mainAxisAlignment: MainAxisAlignment.spaceAround));
  }
}
