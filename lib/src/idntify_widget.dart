import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:camera/camera.dart';
import 'package:extended_image/extended_image.dart';
import 'package:idntify_widget/idntify_widget.dart';
import 'package:idntify_widget/src/models/document_type.dart';
import 'package:idntify_widget/src/models/image_picker_icon.dart';
import 'package:idntify_widget/src/models/info_icon.dart';
import 'package:idntify_widget/src/models/instruction_image.dart';
import 'package:idntify_widget/src/models/response.dart';
import 'package:idntify_widget/src/models/stage.dart';
import 'package:idntify_widget/src/models/text_icon.dart';
import 'package:idntify_widget/src/utils/crop.dart';
import 'package:idntify_widget/src/utils/selfie.dart';
import 'package:idntify_widget/src/utils/image.dart';
import 'package:idntify_widget/src/widgets/button.dart';
import 'package:idntify_widget/src/widgets/camera.dart';
import 'package:idntify_widget/src/widgets/cropper.dart';
import 'package:idntify_widget/src/widgets/info.dart';
import 'package:idntify_widget/src/widgets/instructions.dart';
import 'package:idntify_widget/src/widgets/text.dart';
import 'package:idntify_widget/src/widgets/image_picker_selector.dart';
import 'package:image_picker/image_picker.dart';

class Idntify extends StatefulWidget {
  final String apiKey;
  final String origin;
  final Stage stage;
  final List<CameraDescription> cameras;
  final void Function(int) onStepChange;
  final void Function() onTransactionFinished;

  Idntify(this.apiKey, this.origin, this.cameras,
      {Key key, this.stage, this.onStepChange, this.onTransactionFinished})
      : super(key: key);

  @override
  _IdnitfyState createState() => _IdnitfyState();
}

class _IdnitfyState extends State<Idntify> {
  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();
  IdntifyApiService _apiService;
  int currentStep = 1;
  // Image picker controller.
  final ImagePicker _imagePicker = ImagePicker();
  // Camera reference and controller.
  CameraDescription _frontCamera;
  CameraDescription _backCamera;
  CameraController _cameraController;

  // Picture of the ID front.
  Uint8List _frontalID;
  Uint8List _reverseID;
  // Status.
  bool _loadFiles = false;
  bool _takePicture = false;
  // loadFiles status.
  bool _loadingImage = false;
  bool _loadedImage = false;
  // LoadFiles - takePicture status.
  bool _frontalIDLoaded = false;
  bool _reverseIDLoaded = false;
  // takePicture status;
  bool _hasBothCameras = false;

  bool _showLogo = true;

  Widget _widgeToRender;

  @override
  void initState() {
    super.initState();

    _apiService = IdntifyApiService(widget.apiKey, widget.origin);
  }

  // This code needs to be rewritten or refactored
  void getCameras(
      {bool flip = false,
      CameraLensDirection cameraToSet = CameraLensDirection.back}) {
    // Catch if there is no cameras and set the configuration for front/back camera.
    if (widget.cameras.length > 0) {
      final front = widget.cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.front);
      final back = widget.cameras
          .where((camera) => camera.lensDirection == CameraLensDirection.back);

      _frontCamera = front.first ?? null;
      _backCamera = back.first ?? null;

      _hasBothCameras = _frontCamera != null && _backCamera != null;

      if (_frontCamera != null || _backCamera != null) {
        if (flip && _cameraController != null) {
          final currentCamera = _cameraController.description.lensDirection;

          cameraToSet = currentCamera == CameraLensDirection.front
              ? CameraLensDirection.back
              : CameraLensDirection.front;
        }

        _cameraController = CameraController(
            cameraToSet == CameraLensDirection.front
                ? _frontCamera ?? _backCamera
                : _backCamera ?? _frontCamera,
            ResolutionPreset.high);

        _cameraController
            .initialize()
            .then((_) => setState(() => _takePicture = true));
      }
    }
  }

  Widget build(BuildContext context) {
    switch (currentStep) {
      case 1:
        _widgeToRender = FutureBuilder(
            future: _apiService.createTransaction(),
            builder: (contextFutureBuilder, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Flexible(
                  child: Column(
                    children: <Widget>[CircularProgressIndicator.adaptive()],
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                );
              }

              if (snapshot.hasError) {
                var error = snapshot.error;

                return Info(
                  title: 'ERROR',
                  texts: [
                    if (error is IdntifyResponse) ...{
                      InfoText(error.error, color: Colors.red, bold: true),
                      InfoText(error.message, color: Colors.red),
                    } else ...{
                      InfoText(error.toString() ?? '',
                          color: Colors.red, bold: true)
                    }
                  ],
                );
              }

              widget.onStepChange?.call(currentStep);
              return Info(
                icon: InfoIcon.identity,
                title: 'Valida tu identidad',
                texts: [
                  InfoText('Sólo tomará unos minutos', bold: true, padding: 10),
                  InfoText(
                      'Usa las cámaras de tu teléfono para tomar una foto de:',
                      padding: 10),
                  InfoText('1. Tu INE por ambos lados', padding: 10),
                  InfoText('2. Tu rostro', padding: 10)
                ],
                buttons: [
                  Button('Continuar', onPressed: () {
                    setState(() => currentStep = 2);
                    widget.onStepChange?.call(currentStep);
                  })
                ],
              );
            });
        break;
      case 2:
        var texts = [
          InfoText(
              'Usa las cámaras de tu teléfono para tomar una foto por cada lado de tu INE.',
              padding: 5),
          if (!_loadFiles) ...{
            InfoText('Requerimos de:', bold: true, padding: 5),
            InfoText('1 foto de la parte frontal',
                icon: TextIcon.front, padding: 10),
            InfoText('1 foto de la parte posterior',
                icon: TextIcon.reverse, padding: 10),
          }
        ];
        List<Button> buttons = [
          if (!_loadFiles) ...{
            Button(
              'Cargar archivos',
              alternative: true,
              onPressed: () => setState(() => _loadFiles = true),
            ),
            Button('Tomar foto', onPressed: () {
              setState(() => currentStep = 3);
              widget.onStepChange?.call(currentStep);
            })
          } else ...{
            if (_frontalID == null) ...{
              Button(
                'Cancelar',
                alternative: true,
                onPressed: () => setState(() => _loadFiles = false),
              )
            },
          }
        ];
        String imageToLoad = 'Cargar frontal';

        if (_loadFiles) {
          if (_frontalIDLoaded) {
            imageToLoad = 'Cargar reverso';
          }

          if (_frontalID != null && _reverseID == null && _loadedImage) {
            Timer(
                Duration(seconds: 1),
                () => setState(
                    () => {_loadedImage = false, _frontalIDLoaded = true}));
          }

          if (_reverseID != null && _loadedImage) {
            Timer(Duration(seconds: 1), () {
              widget.onStepChange?.call(currentStep);
              setState(() => {_reverseIDLoaded = true, currentStep = 7});
            });
          }
        }

        _widgeToRender = Info(
          icon: InfoIcon.photo,
          title: 'Foto de identificación',
          texts: texts,
          imagePicker: _loadFiles
              ? ImagePickerSelector(
                  imageToLoad,
                  _loadingImage
                      ? ImagePickerIcon.loading
                      : _loadedImage
                          ? ImagePickerIcon.loaded
                          : ImagePickerIcon.load,
                  textIcon: TextIcon.front, onTap: _loadingImage ? null : () async {
                  try {
                    Uint8List image = await pickImage(_imagePicker);
                    setState(() {
                      _frontalID != null
                          ? _reverseID = image
                          : _frontalID = image;
                      _loadingImage = true;
                    });

                    await setImage(
                        image,
                        _apiService,
                        _frontalID != null && _reverseID == null
                            ? DocumentType.frontal
                            : DocumentType.back);

                    await Future.delayed(Duration(seconds: 10));

                    setState(
                        () => {_loadingImage = false, _loadedImage = true});
                  } catch (error) {
                    print(error);
                  }
                })
              : null,
          buttons: buttons,
        );
        break;
      case 3:
      case 5:
        if (!_takePicture) {
          _showLogo = false;
          Timer(Duration(seconds: 4), () => getCameras());
          _widgeToRender = Instructions(
              _frontalIDLoaded
                  ? 'Captura el reverso de tu INE'
                  : 'Captura el frente de tu INE',
              _frontalIDLoaded
                  ? InstructionImage.reverse
                  : InstructionImage.front);
        } else {
          _widgeToRender = Camera(
            _cameraController,
            changeCameraOption: _hasBothCameras,
            text: _frontalIDLoaded
                ? 'Toma una foto del reverso de tu INE'
                : 'Toma una foto del frente de tu INE',
            textIcon: _frontalIDLoaded ? TextIcon.reverse : TextIcon.front,
            takePhoto: () async {
              final XFile image = await _cameraController.takePicture();
              final Uint8List imageBytes = await image.readAsBytes();
              setState(() {
                if (!_frontalIDLoaded) {
                  _frontalID = imageBytes;
                  currentStep = 4;
                  _showLogo = true;
                } else {
                  _reverseID = imageBytes;
                  currentStep = 6;
                  _showLogo = true;
                }

                widget.onStepChange?.call(currentStep);
              });
            },
            changeCamera: () => getCameras(flip: true),
          );
        }
        break;
      case 4:
      case 6:
        _widgeToRender = Cropper(
          _editorKey,
          !_frontalIDLoaded ? _frontalID : _reverseID,
          onRetry: () => setState(() =>
              {currentStep = _frontalIDLoaded && !_reverseIDLoaded ? 3 : 5}),
          onContinue: () async {
            final result = await CropImage().getImage(_editorKey);

            await _apiService.addDocument(
                result,
                _frontalID != null && _reverseID == null
                    ? DocumentType.frontal
                    : DocumentType.back);

            setState(() {
              if (!_frontalIDLoaded) {
                _frontalID = result;
                _frontalIDLoaded = true;
                currentStep = 5;
              } else {
                _reverseID = result;
                _reverseIDLoaded = true;
                currentStep = 7;
              }
              widget.onStepChange?.call(currentStep);
              _takePicture = false;
            });
          },
        );
        break;
      case 7:
        _widgeToRender = Info(
          icon: InfoIcon.selfie,
          title: 'Captura de selfie',
          texts: [
            InfoText(
                'Compararemos la captura de tu rostro con la fotografía de tu identificación',
                padding: 5),
            InfoText('Instrucciones generales:', bold: true, padding: 5),
            InfoText(
                'Muestra el frente de tu rostro, asegurate de que tus ojos se vean claramente y sonríe',
                icon: TextIcon.first,
                padding: 10),
            InfoText(
                'Evita usar lentes, audifonos o algún otro accesorio en tu cabeza',
                icon: TextIcon.second,
                padding: 10),
          ],
          imagePicker: null,
          buttons: [
            Button('Continuar', onPressed: () {
              setState(() => currentStep = 8);
              widget.onStepChange?.call(currentStep);
            })
          ],
        );
        break;
      case 8:
        if (!_takePicture) {
          _showLogo = false;
          Timer(Duration(seconds: 4),
              () => getCameras(cameraToSet: CameraLensDirection.front));
          _widgeToRender =
              Instructions('Captura de selfie', InstructionImage.selfie);
        } else {
          _widgeToRender = Camera(
            _cameraController,
            changeCameraOption: false,
            takePhoto: () async {
              await getSelfie(_cameraController, _apiService);

              setState(() {
                currentStep = 9;
                _showLogo = true;
              });

              widget.onStepChange?.call(currentStep);
            },
            recording: true,
          );
        }
        break;
      case 9:
        Timer(Duration(seconds: 7), () => widget.onTransactionFinished?.call());

        _widgeToRender = Info(
          icon: InfoIcon.complete,
          title: 'Gracias por validar tu identidad',
          texts: [InfoText('La verificación ha sido completada exitosamente')],
          imagePicker: null,
          buttons: [],
        );
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
          color: [3, 5, 8].contains(currentStep) && _takePicture
              ? Colors.black
              : Colors.white),
      child: Column(
        children: <Widget>[
          if (_showLogo) ...{
            Image.asset('assets/icons/logo.png',
                scale: 1.6, package: 'idntify_widget')
          },
          _widgeToRender ?? Container()
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }
}
