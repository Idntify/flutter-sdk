import 'dart:async';

import 'package:flutter/material.dart';

import 'package:idntify_widget/src/models/camera_button_icons.dart';
import 'package:idntify_widget/src/models/text_icon.dart';
import 'package:idntify_widget/src/widgets/text.dart';

import 'package:camera/camera.dart';

class Camera extends StatefulWidget {
  final CameraController cameraController;
  final GestureTapCallback takePhoto;
  final GestureTapCallback changeCamera;
  final bool changeCameraOption;
  final String text;
  final TextIcon textIcon;
  final bool recording;

  Camera(this.cameraController, {Key key, this.takePhoto, this.changeCamera, this.changeCameraOption, this.text, this.textIcon, this.recording = false}) : super(key: key);

  @override
  _CameraState createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  double opacity = 1.0;

  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    double scale = size.aspectRatio * widget.cameraController.value.aspectRatio;

    if (scale < 1) scale = 1 / scale;

    return
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 5.0, right: 5.0),
                child: Transform.scale(
                    scale: scale,
                    child: Center(
                        child: CameraPreview(
                            widget.cameraController,
                            child: Stack(
                                children: <Widget>[
                                  if (widget.text != null) ...{
                                    Container(
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                            width: double.infinity,
                                            margin: EdgeInsets.all(10),
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                color: Colors.grey
                                            ),
                                            child: InfoText(widget.text, color: Colors.black, size: 18, icon: widget.textIcon)                                                  )
                                    ) 
                                },
                                  Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Padding(
                                          padding: EdgeInsets.only(bottom: 30),
                                          child: Row(
                                              children: <Widget>[
                                                AnimatedOpacity(
                                                    child: FloatingActionButton(
                                                      child: Image.asset(widget.recording ? CameraButtonIcons.recordActive.name : CameraButtonIcons.record.name, package: 'idntify_widget'),
                                                      backgroundColor: Colors.white,
                                                      onPressed: () {
                                                        if (widget.recording) {
                                                          Timer.periodic(Duration(seconds: 2), (_timer) {
                                                            if (mounted) {
                                                              setState(() => opacity = opacity == 1 && mounted ? 0.6 : 1.0);
                                                            }
                                                          });
                                                        }
                                                        widget.takePhoto?.call();
                                                      }
                                                    ),
                                                    opacity: opacity,
                                                    duration: Duration(seconds: 1)
                                                ),
                                                if (widget.changeCameraOption) ...{
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 5),
                                                    child: FloatingActionButton(
                                                        child: Image.asset(CameraButtonIcons.flip.name, package: 'idntify_widget'),
                                                        backgroundColor: Colors.white,
                                                        mini: true,
                                                        onPressed: widget.changeCamera
                                                    )
                                                  )
                                                }
                                              ],
                                              mainAxisAlignment: MainAxisAlignment.center,
                                          )
                                      ),
                                  )
                                ]
                            )
                        ),
                    )
                ),
            )
        );
  }
}
