import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:numberpicker/numberpicker.dart';

class CartElement extends StatelessWidget {
  final String imageSrc;
  final double price;
  final String title;
  final String subtitle;
  final int quantity;
  final Function(int) onQuantityChange;
  final GestureTapCallback onDelete;

  CartElement(this.title, this.imageSrc,
      {this.price = 0.0,
      this.quantity = 1,
      this.subtitle,
      this.onQuantityChange,
      this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Image.network(imageSrc, scale: 1.5),
        Expanded(
            child: Column(children: <Widget>[
          Text(title, style: TextStyle(fontSize: 16)),
          if (subtitle != null) ...{Text(subtitle)}
        ])),
        Expanded(
            child: Text('\$${price.toInt().toString()}',
                style: TextStyle(fontSize: 18))),
        Expanded(
            child: NumberPicker(
                value: quantity,
                minValue: 1,
                maxValue: 100,
                onChanged: (v) => onQuantityChange?.call(v))),
        Expanded(
            child: Text('\$${(quantity * price).toInt().toString()}',
                style: TextStyle(fontSize: 18))),
        Expanded(
            child: GestureDetector(
                child: Container(child: Icon(Icons.close)), onTap: onDelete))
      ],
    );
  }
}
