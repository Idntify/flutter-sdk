import 'package:idntify_widget/models/text_icon.dart';

import 'package:flutter/material.dart';

class InfoText extends StatelessWidget {
  final String text;
  final TextIcon icon;
  final bool bold;
  final double size;
  final Color color;
  final double padding;
  
  InfoText(this.text, {this.icon, this.bold = false, this.size = 16, this.color = const Color.fromRGBO(124, 124, 124, 1), this.padding = 0});

  Widget build(context) { 
    return Padding(
        padding: EdgeInsets.only(top: padding, bottom: padding),
        child: icon != null ?
          Row(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 12),
                child: Image.asset(icon.name, height: 35, width: 35,),
              ),
              Flexible(
                  child: Text(text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontSize: size, 
                        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                        fontFamily: 'Inter'
                      )
                  )
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center
        ) :
        Text(text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: color,
            fontSize: size, 
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Inter'
          ),
        )
      );
  }
} 
