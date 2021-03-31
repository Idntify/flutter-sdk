import 'package:flutter/widgets.dart';

class Idntify extends StatefulWidget {
  final String apiKey;
	final String origin;
  final void Function(int) onStageChange;
  final void Function() onTransactionFinished;

  Idntify(this.apiKey, this.origin, {Key key, this.onStageChange, this.onTransactionFinished}) : super(key: key);

  @override
  _IdnitfyState createState() => _IdnitfyState();
}

class _IdnitfyState extends State<Idntify> {
	Widget build(BuildContext context) {
		return Container();
	}
}
