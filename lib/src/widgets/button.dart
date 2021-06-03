import 'package:flutter/material.dart';
import 'package:idntify_widget/src/widgets/text.dart';

class Button extends StatelessWidget {
  final bool alternative;
  final String text;
  final GestureTapCallback? onPressed;

  Button(this.text, {this.alternative = false, this.onPressed});

  Widget build(BuildContext context) {
    return alternative
        ? OutlinedButton(
            child: InfoText(
              text,
              size: 18,
              color: Color.fromRGBO(44, 47, 124, 1),
            ),
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(15.0),
                side: BorderSide(
                    width: 2, color: Color.fromRGBO(44, 47, 124, 1))))
        : ElevatedButton(
            child: InfoText(text, size: 18, color: Colors.white),
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15.0),
                primary: Color.fromRGBO(44, 47, 124, 1)),
          );
  }
}
