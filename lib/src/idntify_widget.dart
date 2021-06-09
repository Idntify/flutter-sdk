import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:camera/camera.dart';
import 'package:extended_image/extended_image.dart';
import 'package:idntify_widget/idntify_widget.dart';
import 'package:idntify_widget/src/models/document_type.dart';
import 'package:idntify_widget/src/models/image_picker_icon.dart';
import 'package:idntify_widget/src/models/info_icon.dart';
import 'package:idntify_widget/src/models/instruction_image.dart';
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

/// Main IDntify widget.
///
/// [apiKey] is generated on the IDntify platform. Required.
/// [origin] is the origin of the request that the client set on the IDntify platform. Required.
/// [cameras] is a required argument of a [List<CameraDescription>] where the info of cameras on
/// the device is referenced.
/// [stage] is an optional parameter. Set by 'dev' as default, make sure you set it to
/// 'prod' when needed.
/// [onStepChange] is a custom function triggered when the stage of the IDntify process haschanged.
/// [onTransactionFinished] is a custom function triggered when IDntify process has finished.
class Idntify extends StatefulWidget {
  final String apiKey;
  final String origin;
  final Stage? stage;
  final List<CameraDescription> cameras;
  final void Function(int)? onStepChange;
  final void Function()? onTransactionFinished;

  Idntify(this.apiKey, this.origin, this.cameras,
      {Key? key, this.stage, this.onStepChange, this.onTransactionFinished})
      : super(key: key);

  @override
  _IdnitfyState createState() => _IdnitfyState();
}

/// [StatefulWidget] based on the main [Idntify] widget.
///
/// Because of the nature of the process, a re-rendering screen is needed.
/// Router/router were avoided to prevent any conflict with the main application.
///
/// What is rendered depends on the value of [currentStep]. This value is updated
/// according to what the user does.
class _IdnitfyState extends State<Idntify> {
  /// Instance of the editor key. Used for cropping images.
  final GlobalKey<ExtendedImageEditorState> _editorKey =
      GlobalKey<ExtendedImageEditorState>();

  /// Instance reference of the [IdntifyApiService].
  IdntifyApiService? _apiService;

  /// Current step of the IDntify process.
  int currentStep = 1;

  /// Image picker controller.
  final ImagePicker _imagePicker = ImagePicker();

  /// Frontal camera reference.
  CameraDescription? _frontCamera;

  /// Back camera reference.
  CameraDescription? _backCamera;
  // Camera controller. It includes the reference for the cameras on the device.
  CameraController? _cameraController;

  // Picture of the ID front.
  Uint8List? _frontalID;
  Uint8List? _reverseID;
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
  bool _flipCamera = false;

  /// Whenever the widget is rendered for the first time, it'll create an instance of
  /// the [IdntifyApiService].
  @override
  void initState() {
    super.initState();

    _apiService =
        IdntifyApiService(widget.apiKey, widget.origin, stage: widget.stage);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Sets the reference of the requested cameras validating if it can be valid.
  ///
  /// TODO: This code needs to be rewritten or refactored.
  /// TODO: This code should be part of the [Camera] widget class.
  Future<dynamic> getCamera(
      {bool flip = false,
      CameraLensDirection cameraToSet = CameraLensDirection.back}) async {
    try {
      if (widget.cameras.length <= 0) {
        throw 'No cameras available.';
      }

      final _frontCamera = widget.cameras.firstWhereOrNull(
          (camera) => camera.lensDirection == CameraLensDirection.front);
      final _backCamera = widget.cameras.firstWhereOrNull(
          (camera) => camera.lensDirection == CameraLensDirection.back);

      _hasBothCameras = _frontCamera != null && _backCamera != null;

      if (_frontCamera != null || _backCamera != null) {
        if (flip && _cameraController != null) {
          final currentCamera = _cameraController!.description.lensDirection;

          cameraToSet = currentCamera == CameraLensDirection.front
              ? CameraLensDirection.back
              : CameraLensDirection.front;
        }

        _cameraController = CameraController(
            cameraToSet == CameraLensDirection.front
                ? _frontCamera ?? _backCamera!
                : _backCamera ?? _frontCamera!,
            ResolutionPreset.high);
      }

      await _cameraController!.initialize();
    } catch (error) {
      print(error);
      return error;
    }
  }

  /// This handles the ID photo.
  /// TODO: this might probably be inside the [Camera] widget class.
  Future<void> _handleIdPhoto() async {
    try {
      final XFile image = await _cameraController!.takePicture();
      final Uint8List imageBytes = await image.readAsBytes();

      await _cameraController?.dispose();

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
        _flipCamera = false;
      });

      widget.onStepChange?.call(currentStep);
    } catch (error) {
      print(error);
      setState(() => _takePicture = false);
    }
  }

  /// This handles the selfie process.
  /// TODO: this might probably be inside the [Camera] widget class.
  Future<void> _handleSelfie() async {
    try {
      final Map<String, Uint8List> bytes = await getSelfie(_cameraController!);

      await _apiService!.addSelfie(bytes['image']!, bytes['video']!);

      await _cameraController?.dispose();

      setState(() {
        currentStep = 9;
        _showLogo = true;
      });

      widget.onStepChange?.call(currentStep);
    } catch (error) {
      print(error);
      _handleSelfie();
    }
  }

  /// Helps to handle when an image gets cropped.
  /// TODO: this should be inside the [Cropper] widget class.
  Future<void> _handleCropper() async {
    try {
      setState(() => _loadingImage = true);

      final result = await (cropImage(_editorKey) as FutureOr<Uint8List>);

      await _apiService!.addDocument(
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
        _showLogo = false;
        _loadingImage = false;
        _takePicture = false;
      });
    } catch (error) {
      setState(() => {
            currentStep = _frontalIDLoaded && !_reverseIDLoaded ? 3 : 5,
            _loadingImage = false,
            _takePicture = false
          });
      print(error);
    }
  }

  /// Helps to handle when the user picks an image.
  /// TODO: This might be inside the [ImagePickerSelector] widget class.
  Future<void> _handlePickerImage() async {
    try {
      Uint8List image = await pickImage(_imagePicker);

      setState(() {
        _frontalID != null ? _reverseID = image : _frontalID = image;
        _loadingImage = true;
      });

      await setImage(
          image,
          _apiService!,
          _frontalID != null && _reverseID == null
              ? DocumentType.frontal
              : DocumentType.back);

      await Future.delayed(Duration(seconds: 10));

      setState(() => {_loadingImage = false, _loadedImage = true});
    } catch (error) {
      print(error);
      setState(() {
        _loadingImage = false;
        _loadedImage = false;
        _frontalID != null && _reverseID == null
            ? _frontalID = null
            : _reverseID = null;
      });
    }
  }

  /// Builds the widget based on different constrains.
  ///
  /// The color of the decoration property of [Container] changes depending on specific steps
  /// and the [_takePicture] flag.
  ///
  /// Logo is only displayed based on a flag (that changes depending on the step). It also
  /// scales based on the device size.
  ///
  /// What changes constantly (and what builds the whole screen) is based on the [_loadProcess]
  /// function.
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
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
                scale: width < 400 ? 2 : 1.6, package: 'idntify_widget')
          },
          _loadProcess()
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  /// Returns what widget to render based on the [currentStep] value.
  ///
  /// Each widget screen has their own activity and sometimes the widget changes depending
  /// on the step and some other variables.
  ///
  /// The steps should work like this:
  /// 1. The process tries to create a new transaction.
  /// 2. The user chooses between loading a device image or take a picture.
  /// If the user chooses to load an image then that process will be executed in that step.
  /// 3/5. If the user chooses to take a picture, then these are the steps when takes the
  /// frontal and reverse picture of its ID.
  /// 4/6. If the user chooses to take a picture, this is when the user can crop the
  /// frontal/reverse picture of its ID.
  /// 7. The selfie process, a one-second recording and a snapshot.
  /// 8. If the process was correct it'll render the confirmation.
  Widget _loadProcess() {
    switch (currentStep) {
      case 1:
        return _initProcess();
      case 2:
        return !_loadFiles ? _showIdInfo() : _loadPhotos();
      case 3:
      case 5:
        if (!_takePicture) {
          final String text = _frontalIDLoaded
              ? 'Captura el reverso de tu INE'
              : 'Captura el frente de tu INE';
          final InstructionImage image = _frontalIDLoaded
              ? InstructionImage.reverse
              : InstructionImage.front;
          return _showInstructions(text, image);
        }

        return _takeIdPhoto();
      case 4:
      case 6:
        return _cropper();
      case 7:
        return _showSelfieInfo();
      case 8:
        return !_takePicture
            ? _showInstructions('Captura de selfie', InstructionImage.selfie,
                cameraToSet: CameraLensDirection.front)
            : _captureSelfie();
      case 9:
        return _processFinished();
      default:
        return Container();
    }
  }

  /// Step 1.
  /// Tries to create a transaction.
  /// If an error happened (wrong [apiKey]/[origin]) it'll show an error screen and that's it.
  /// If it was successful then it'll render info about what the process is about, if the
  /// 'continue' button is pressed then the [currentStep] value will be updated to 2.
  Widget _initProcess() {
    return FutureBuilder(
        future: _apiService!.createTransaction(),
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

            print(error);
            return Info(
              title: 'ERROR',
              texts: [
                InfoText(error.toString(), color: Colors.red, bold: true)
              ],
            );
          }

          widget.onStepChange?.call(currentStep);
          return Info(
            icon: InfoIcon.identity,
            title: 'Valida tu identidad',
            texts: [
              InfoText('Sólo tomará unos minutos', bold: true, padding: 10),
              InfoText('Usa las cámaras de tu teléfono para tomar una foto de:',
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
  }

  /// Step 2.
  /// Displays information about the ID pictures and let the user choose between load images saved
  /// in their device or take a picture.
  /// If the user chooses to take a picture then the [currentStep] value will be updated to 3.
  /// If the user chooses to load the images then it'll render [_loadPhotos]
  Widget _showIdInfo() {
    var texts = [
      InfoText(
          'Usa las cámaras de tu teléfono para tomar una foto por cada lado de tu INE.',
          padding: 5),
      InfoText('Requerimos de:', bold: true, padding: 5),
      InfoText('1 foto de la parte frontal', icon: TextIcon.front, padding: 10),
      InfoText('1 foto de la parte posterior',
          icon: TextIcon.reverse, padding: 10),
    ];
    List<Button> buttons = [
      Button(
        'Cargar archivos',
        alternative: true,
        onPressed: () => setState(() => _loadFiles = true),
      ),
      Button('Tomar foto', onPressed: () {
        setState(() => {currentStep = 3, _showLogo = false});
        widget.onStepChange?.call(currentStep);
      })
    ];

    return Info(
      icon: InfoIcon.photo,
      title: 'Foto de identificación',
      texts: texts,
      buttons: buttons,
    );
  }

  /// Renders the widget that helps the user to select an image from its device.
  /// User is required to choose an image and wait until it is uploaded, after the first
  /// one (frontal) was uploaded then the second one (reverse) should be selected and wait until
  /// it gets uploaded.
  /// If everything was uploaded correctly, then the value of [currentStep] will be updated to 7.
  Widget _loadPhotos() {
    var texts = [
      InfoText(
          'Usa las cámaras de tu teléfono para tomar una foto por cada lado de tu INE.',
          padding: 5),
    ];
    List<Button> buttons = [
      if (_frontalID == null) ...{
        Button(
          'Cancelar',
          alternative: true,
          onPressed: () => setState(
              () => {_loadFiles = false, _frontalID = null, _reverseID = null}),
        )
      },
    ];
    String imageToLoad = 'Cargar frontal';

    if (_frontalIDLoaded) {
      imageToLoad = 'Cargar reverso';
    }

    if (_frontalID != null && _reverseID == null && _loadedImage) {
      Timer(
          Duration(seconds: 1),
          () =>
              setState(() => {_loadedImage = false, _frontalIDLoaded = true}));
    }

    if (_reverseID != null && _loadedImage) {
      Timer(Duration(seconds: 1), () {
        widget.onStepChange?.call(currentStep);
        setState(() => {_reverseIDLoaded = true, currentStep = 7});
      });
    }

    return Info(
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
              textIcon: TextIcon.front,
              onTap: _loadingImage ? null : _handlePickerImage)
          : null,
      buttons: buttons,
    );
  }

  /// Step 3/5.
  /// Renders a [Camera] widget that helps the user to take a photo.
  ///
  /// This will be rendered in both steps because of the frontal and reverse ID pictures.
  /// It first validates if the camera can be connected with the widget, if it's valid then
  /// the user should take a picture and the [currentStep] value will be updated to 4/6,
  /// if something went wrong with the camera, it'll retry to connect it.
  Widget _takeIdPhoto() {
    return FutureBuilder(
        future: getCamera(flip: _flipCamera),
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

            print(error);

            Timer(Duration(seconds: 5),
                () => setState(() => {_takePicture = false}));

            return Info(
              title: 'ERROR',
              texts: [
                InfoText('Error al inicializar la cámara... reintentando',
                    color: Colors.red, bold: true)
              ],
            );
          }

          widget.onStepChange?.call(currentStep);
          return Camera(
            _cameraController,
            changeCameraOption: _hasBothCameras,
            text: _frontalIDLoaded
                ? 'Toma una foto del reverso de tu INE'
                : 'Toma una foto del frente de tu INE',
            textIcon: _frontalIDLoaded ? TextIcon.reverse : TextIcon.front,
            takePhoto: _handleIdPhoto,
            changeCamera: () => setState(() => _flipCamera = true),
          );
        });
  }

  /// Step 4/6.
  /// Renders a [Cropper] widget based on the frontal/reverse picture the user has taken.
  /// If the image was cropped and uploaded the [currentStep] value will be updated to 7.
  Widget _cropper() {
    return Cropper(
      _editorKey,
      !_frontalIDLoaded ? _frontalID : _reverseID,
      loading: _loadingImage,
      onRetry: () => setState(() => {currentStep -= 1}),
      onContinue: _loadingImage ? () {} : _handleCropper,
    );
  }

  /// Step 7.
  /// Renders a [Info] widget with information about what the selfie process is all about.
  /// When the user pressed the 'continue' button, the value of [currentStep] will be updated to 8.
  Widget _showSelfieInfo() {
    return Info(
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
      buttons: [
        Button('Continuar', onPressed: () {
          setState(() => {currentStep = 8, _showLogo = false});
          widget.onStepChange?.call(currentStep);
        })
      ],
    );
  }

  /// Self explanatory. Show quick instructions about what is happening with the process.
  /// This will be rendered before the [_takeIdPhoto] or [_captureSelfie] are bout to happen.
  Widget _showInstructions(String text, InstructionImage image,
      {int seconds: 4,
      CameraLensDirection cameraToSet: CameraLensDirection.back}) {
    Timer(
        Duration(seconds: seconds), () => setState(() => _takePicture = true));

    return Instructions(text, image);
  }

  /// Step 8.
  /// Render that will atempt to record a one-second video and a snapshot.
  /// If it's valid then the value of [currentStep] will be updated to 9.
  /// If it can't get a proper validation it'll retry the step process.
  Widget _captureSelfie() {
    return FutureBuilder(
        future: getCamera(cameraToSet: CameraLensDirection.front),
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

            print(error);

            Timer(Duration(seconds: 5),
                () => setState(() => {_takePicture = false}));

            return Info(
              title: 'ERROR',
              texts: [
                InfoText('Error al inicializar la cámara... reintentando',
                    color: Colors.red, bold: true)
              ],
            );
          }

          widget.onStepChange?.call(currentStep);
          return Camera(
            _cameraController,
            changeCameraOption: false,
            takePhoto: _handleSelfie,
            recording: true,
          );
        });
  }

  /// Step 9.
  /// Renders a widget that tells the user that the process has finished.
  /// If a [onTransactionFinished] function was provided then it'll get called.
  Widget _processFinished() {
    Timer(Duration(seconds: 7), () => widget.onTransactionFinished?.call());
    return Info(
      icon: InfoIcon.complete,
      title: 'Gracias por validar tu identidad',
      texts: [InfoText('La verificación ha sido completada exitosamente')],
      imagePicker: null,
      buttons: [],
    );
  }
}
