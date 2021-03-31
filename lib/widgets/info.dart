import 'package:flutter/material.dart';

import 'package:idntify_widget/models/info_icon.dart';
import 'package:idntify_widget/widgets/button.dart';
import 'package:idntify_widget/widgets/image_picker.dart';
import 'package:idntify_widget/widgets/text.dart';

class Info extends StatelessWidget {
  final InfoIcon icon;
  final String title;
  final List<InfoText> texts;
  final List<Button> buttons;
  final ImagePicker imagePicker;

  Info({this.icon, this.title, this.texts, this.buttons, this.imagePicker});

  Widget build(context) {
    return Expanded(
        child: Column(
            children:<Widget>[
              if (icon != null) ...{ Image.asset(icon.name, scale: 1.6) },
              if (title != null) ...{ InfoText(title, bold: true, size: 24, color: Colors.black) },
              Flexible(child: Column(children: texts ?? [], mainAxisSize: MainAxisSize.min,), fit: FlexFit.loose, flex: 2),
              if (imagePicker != null) ...{ imagePicker },
              Row(
                children: buttons ?? [], crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              )
            ],
        mainAxisAlignment: MainAxisAlignment.spaceAround
      )
    );
  }
}
