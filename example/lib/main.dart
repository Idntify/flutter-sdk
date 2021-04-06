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
  bool _idntifyProcessCompleted = false;

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
                Expanded(
                    child: ListView(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.map),
                      title: Text('Map'),
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_album),
                      title: Text('Album'),
                    ),
                    ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('Phone'),
                    )
                  ],
                )),
                ElevatedButton(
                    onPressed: () =>
                        setState(() => _executeIdntifyProcess = true),
                    child: Text('Checkout', style: TextStyle(fontSize: 20)))
              } else ...{
                Expanded(
                    child: Idntify(
                  '<<YOUR API_KEY>>',
                  '<<YOUR ORIGIN>>',
                  cameras,
                  onTransactionFinished: () => setState(() => {
                        _executeIdntifyProcess = false,
                        _idntifyProcessCompleted = true
                      }),
                ))
              }
            ])));
  }
}
