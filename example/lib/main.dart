import 'package:camera/camera.dart';
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
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Mi Tienda :)'),
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
  bool _IdntifyProcessCompleted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: !_executeIdntifyProcess
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _IdntifyProcessCompleted
                        ? 'Transacción de IDntify completada'
                        : 'Mi carrito de compras... (WIP)',
                  ),
                ],
              ),
            )
          : Idntify(
              '<<YOUR API_KEY>>',
              '<<YOUR ORIGIN>>',
              cameras,
              onTransactionFinished: () => setState(() => {
                    _executeIdntifyProcess = false,
                    _IdntifyProcessCompleted = true
                  }),
            ),
      floatingActionButton: !_executeIdntifyProcess
          ? FloatingActionButton(
              onPressed: () => setState(() => _executeIdntifyProcess = true),
              tooltip: 'Checkout',
              child: Icon(Icons.payment),
            )
          : null,
    );
  }
}
