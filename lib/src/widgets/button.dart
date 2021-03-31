import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final bool alternative;
  final String text;
  final GestureTapCallback onPressed;

  Button(this.text, {this.alternative = false, this.onPressed});

  Widget build(BuildContext context) {
    return alternative ?
        OutlinedButton(
            child: Text(
                text,
                style: TextStyle(
                    fontSize: 18,
                    color: Color.fromRGBO(44, 47, 124, 1),
                    fontFamily: 'Inter'
                )
            ),
            onPressed: onPressed,
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(15.0),
                side: BorderSide(width: 2, color: Color.fromRGBO(44, 47, 124, 1))
            )
        ) :
        ElevatedButton(
            child: Text(
                text,
                style: TextStyle(fontSize: 18, fontFamily: 'Inter')
            ),
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(15.0),
                primary: Color.fromRGBO(44, 47, 124, 1)
            ),
        );
  }

}
