import 'package:idntify_widget/src/models/text_icon.dart';

import 'package:flutter/material.dart';

/// A Text wrapper with custom style.
///
/// A [string] [text] should be provided, this is self explanatory.
/// The text can contain an [TextIcon], if it's needed.
/// There are other specific arguments for styling just as [bold], [size], [color] and [padding].
///
/// The text changes it's [size] depending on the screen size.
class InfoText extends StatelessWidget {
  final String? text;
  final TextIcon? icon;
  final bool bold;
  final double size;
  final Color color;
  final double padding;

  InfoText(this.text,
      {this.icon,
      this.bold = false,
      this.size = 16,
      this.color = const Color.fromRGBO(124, 124, 124, 1),
      this.padding = 0});

  Widget build(context) {
    double width = MediaQuery.of(context).size.width;
    double finalSize = size;
    double iconSize = 35;

    if (width <= 350) {
      finalSize -= 4;
      iconSize -= 5;
    }

    return Padding(
        padding: EdgeInsets.only(top: padding, bottom: padding),
        child: icon != null
            ? Row(children: [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Image.asset(icon.name!,
                      height: iconSize,
                      width: iconSize,
                      package: 'idntify_widget'),
                ),
                Flexible(
                    child: Text(text!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: color,
                            fontSize: finalSize,
                            fontWeight:
                                bold ? FontWeight.bold : FontWeight.normal,
                            fontFamily: 'Inter')))
              ], mainAxisAlignment: MainAxisAlignment.center)
            : Text(
                text!,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color,
                    fontSize: finalSize,
                    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                    fontFamily: 'Inter'),
              ));
  }
}
