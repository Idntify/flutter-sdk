# idntify_widget

A flutter plugin to use the implementation of the [IDntify](idntify.io) service.

## Installation

First, add `idntify_widget` and `camera` as a dependency in your pubspec.yaml file.

```
environment:
  sdk: '>=2.12.0 <3.0.0'
  flutter: '>=2.0'
dependencies:
  extended_image: ^1.0.0
  camera:
```

Due to the use on some package dependencies you'll need to change some configuration on your Flutter app.

If you want to know more about these packages you can read the documentation of the [camera](https://pub.dev/packages/camera) and [image_picker](https://pub.dev/packages/image_picker) packages.

If you just want to use the API then don't add the `camera` package and you're just ready to use it.

### iOS

In order to use this package iOS 10.0 or higher is needed.

For the `camera` package add two rows to the `ios/Runner/Info.plist`:
* one with the key `Privacy - Camera Usage Description` and a usage description.
* and one with the key `Privacy - Microphone Usage Description` and a usage description.

Or in text format add the key:

```
<key>NSCameraUsageDescription</key>
<string>Can I use the camera please?</string>
<key>NSMicrophoneUsageDescription</key>
<string>Can I use the mic please?</string>
```

For the `image_picker` package you must add the following keys to your Info.plist file, located in `<project root>/ios/Runner/Info.plist`:

* `NSPhotoLibraryUsageDescription` - describe why your app needs permission for the photo library. This is called Privacy - Photo Library Usage Description in the visual editor.
* `NSCameraUsageDescription` - describe why your app needs access to the camera. This is called Privacy - Camera Usage Description in the visual editor.
* `NSMicrophoneUsageDescription` - describe why your app needs access to the microphone, if you intend to record videos. This is called Privacy - Microphone Usage Description in the visual editor.

### Android

In order to use this package Android sdk version 21 or higher is needed.

For the `camera` package change the minimum Android sdk version to 21 (or higher) in your `android/app/build.gradle file`.

`minSdkVersion 21`

For the `image_picker` package the configuration depends on the sdk version.

API < 29

No configuration required - the plugin should work out of the box.

API 29+

Add `android:requestLegacyExternalStorage="true"` as an attribute to the `<application>` tag in AndroidManifest.xml. The attribute is `false` by default on apps targeting Android Q.

## Usage

Before starting to write code you must have already set your application 'origin' and genereated your API key.

If everything is ready then it'd depend on what kind of integration would you like to use.

## Widget

The widget goes through all the steps of the process doing all the though work for you. Keep in mind that each time the widget is recreated a new transaction process will be created.

When the widget is rendered it'll try to expand as the same size of its parent widget.

After that then it's time to write code!

You must need to get a list of the available cameras on the device. Don't worry, is a single line.

Then you just call the Idntify widget with three required parameters: your API key, your 'origin' and your reference of the available cameras. You can also include the stage and the callbacks functions that executes when the user changes the current step and when the transaction is finished.

Here is a simple example.

## API

This works really simple. Just create an instance of the `IdntifyApiService` class sending your API key, your 'origin' and the stage.

At this point you just call the functions whenever you want. Keep in mind that the correct process is to create a transaction first, then add two documents and at the add the selfie and it'll retrieve if the transaction was completed.

Here is a simple example.

```
import 'package:idntify_widget/idntify_widget.dart';
import 'dart:typed_data';

IdntifyApiService api = IdntifyApiService('<<API_KEY>>', <<ORIGIN>>, Stage.dev);

// If it is correct then the other functions will work.
await api.createTransaction();

Uint8List frontalID = your_file_in_bytes.
Uint8List reverseID = your_file_in_bytes.

await api.addDocument(frontalID, DocumentType.frontal);
await api.addDocument(frontalID, DocumentType.reverse);

Uint8List selfiePicture = your_file_in_bytes;
// A 1-2 seconds video.
Uint8list selfieVideo = your_file_in_bytes;

await api.addSelfie(selfiePicture, selfieVideo);

```


