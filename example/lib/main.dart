import 'package:camera/camera.dart';
import 'package:example/cart_element.dart';
import 'package:flutter/material.dart';
import 'package:idntify_widget/idntify_widget.dart';
import 'package:permission_handler/permission_handler.dart';

List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await [
    Permission.location,
    Permission.storage,
  ].request();

  cameras = await availableCameras();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tienda Ejemplo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Tienda Ejemplo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _executeIdntifyProcess = false;
  bool _idntifyProcessCompleted = false;

  final cartElements = [
    {
      'title': 'Colorblock Scuba',
      'imageSrc': 'assets/one.png',
      'subtitle': 'Web ID: 1089772',
      'price': 59.0,
      'quantity': 1
    },
    {
      'title': 'Colorblock Scuba',
      'imageSrc': 'assets/two.png',
      'subtitle': 'Web ID: 1089772',
      'price': 59.0,
      'quantity': 1
    },
    {
      'title': 'Colorblock Scuba',
      'imageSrc': 'assets/three.png',
      'subtitle': 'Web ID: 1089772',
      'price': 59.0,
      'quantity': 1
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
            width: double.infinity,
            child: Column(children: <Widget>[
              if (!_executeIdntifyProcess) ...{
                Row(
                  children: <Widget>[
                    Text(
                      'IDntify status:',
                      style: TextStyle(fontSize: 24),
                    ),
                    Expanded(
                        child: Text(
                            _idntifyProcessCompleted
                                ? 'Completed'
                                : 'Not initialized',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 24,
                                color: _idntifyProcessCompleted
                                    ? Colors.green
                                    : Colors.red)))
                  ],
                ),
                Container(
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                            'Item',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          flex: 1),
                      Expanded(
                        child: Text('Price',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      Expanded(
                        child: Text('Quantity',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      Expanded(
                        child: Text('Total',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                  color: Colors.orange,
                  padding: EdgeInsets.all(5),
                ),
                Expanded(
                  child: ListView.builder(
                      itemCount: cartElements.length,
                      itemBuilder: (context, index) {
                        final element = cartElements[index];
                        return CartElement(
                            element['title'], element['imageSrc'],
                            price: element['price'],
                            quantity: element['quantity'],
                            subtitle: element['subtitle'],
                            onQuantityChange: (v) => setState(
                                () => cartElements[index]['quantity'] = v),
                            onDelete: () =>
                                setState(() => cartElements.removeAt(index)));
                      }),
                ),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: ElevatedButton(
                        onPressed: () =>
                            setState(() => _executeIdntifyProcess = true),
                        child: Text('Checkout', style: TextStyle(fontSize: 20)),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(15))))
              } else ...{
                Expanded(
                    child: Idntify(
                  '<<YOUR API_KEY>>',
                  '<<YOUR ORIGIN>>',
                  cameras,
                  stage: Stage.dev,
                  onTransactionFinished: () => setState(() => {
                        _executeIdntifyProcess = false,
                        _idntifyProcessCompleted = true
                      }),
                ))
              }
            ])));
  }
}
