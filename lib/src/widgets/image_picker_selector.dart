import 'package:flutter/material.dart';

import 'package:idntify_widget/src/models/image_picker_icon.dart';
import 'package:idntify_widget/src/models/text_icon.dart';
import 'package:idntify_widget/src/widgets/text.dart';

/// Widget that displays an area to be pressed for loading a device image.
///
/// A [ImageṔickerIcon] will need to be passed as an argument, the icon can change depending on the state
/// of the main [Idntify] widget.
///
/// A [text] should be provided as a small instruction, optionally a [TextIcon] can also
/// be provided.
///
/// Finally an [onTap] function can also be provided by a custom function.
///
/// TODO: The picker process should be inside the class instead of the main
/// [Idntify] widget. This widget should be transformed a [StatefulWidget].
class ImagePickerSelector extends StatelessWidget {
  final TextIcon? textIcon;
  final ImagePickerIcon icon;
  final String text;
  final onTap;

  ImagePickerSelector(this.text, this.icon, {this.onTap, this.textIcon});

  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
          child: Column(children: <Widget>[
            InfoText(text, color: Colors.black, icon: textIcon),
            Image.asset(icon.name!, height: 30, package: 'idntify_widget')
          ]),
          width: 250,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(
                color:
                    icon == ImagePickerIcon.loaded ? Colors.green : Colors.red,
                width: 2.0,
              ),
              color: icon == ImagePickerIcon.loaded
                  ? Color.fromRGBO(83, 177, 177, 0.3)
                  : Color.fromRGBO(229, 97, 55, 0.3),
              borderRadius: BorderRadius.all(Radius.circular(10.0)))),
      onTap: onTap,
    );
  }
}
