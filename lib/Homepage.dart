import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  File? _image;
  String text = '';
  String cardNumber = '';

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final firstCamera = cameras.first;
    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController?.initialize();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _cameraController?.takePicture();
      if (image == null) return;
      setState(() {
        _image = File(image.path);
      });
      print('Picture taken: ${_image!.path}');
      _textRecognition(_image!);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      setState(() {
        _image = File(image.path);
      });
      print('Image picked: ${_image!.path}');
      _textRecognition(_image!);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _textRecognition(File img) async {
    try {
      final textRecognizer =
          TextRecognizer(script: TextRecognitionScript.latin);
      final inputImage = InputImage.fromFilePath(img.path);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      final regex = RegExp(r'\d{14}');
      final matches = regex.allMatches(recognizedText.text);

      if (matches.isNotEmpty) {
        cardNumber = matches.first.group(0)!;
        _launchPhoneDialer(cardNumber);
      } else {
        cardNumber = "No card number found";
      }

      setState(() {
        text = recognizedText.text;
      });
      print('Recognized text: $text');
      print('Card number: $cardNumber');
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _launchPhoneDialer(String cardNumber) async {
    final url = 'tel:$cardNumber';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch phone dialer');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text(
            "Recharge Your Card",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w900,
              color: Color.fromARGB(255, 0, 153, 255),
            ),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      CameraPreview(_cameraController!),
                      Positioned(
                        top: 200.0,
                        left: 80.0,
                        child: ClipRect(
                          child: Container(
                            width: 200.0,
                            height: 200.0,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green,
                                width: 2.0,
                              ),
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          if (_image != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.file(_image!),
            ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor:
                      const Color.fromARGB(255, 0, 153, 255), // Button color
                ),
                onPressed: _takePicture,
                child: const Icon(Icons.camera, color: Colors.white),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor:
                      const Color.fromARGB(255, 0, 153, 255), // Button color
                ),
                onPressed: () {
                  _pickImage(ImageSource.gallery).then((value) {
                    if (_image != null) {
                      _textRecognition(_image!);
                    }
                  });
                },
                child: const Icon(Icons.photo, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}




































// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
// import 'package:camera/camera.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:projects/main.dart';
// import 'package:url_launcher/url_launcher.dart';

// class Homepage extends StatefulWidget {
//   const Homepage({Key? key}) : super(key: key);

//   @override
//   _HomepageState createState() => _HomepageState();
// }

// class _HomepageState extends State<Homepage> {
//   CameraController? _cameraController;
//   Future<void>? _initializeControllerFuture;
//   File? _image;
//   String text = '';
//   String cardNumber = '';
//   late Uri _url;

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   Future<void> _initCamera() async {
//     final firstCamera = cameras.first;
//     _cameraController = CameraController(
//       firstCamera,
//       ResolutionPreset.high,
//     );
//     _initializeControllerFuture = _cameraController?.initialize();
//   }

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final image = await ImagePicker().pickImage(source: source);
//       if (image == null) return;
//       setState(() {
//         _image = File(image.path);
//       });
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }

//   Future<void> textRecognition(File img) async {
//     final image = await _cameraController?.takePicture();

//     final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
//     final inputImage = InputImage.fromFilePath(img.path);
//     final RecognizedText recognizedText =
//         await textRecognizer.processImage(inputImage);

//     final regex = RegExp(r'\d{14}');
//     final matches = regex.allMatches(recognizedText.text);

//     if (matches.isNotEmpty) {
//       cardNumber = matches.first.group(0)!;
//       _launchPhoneDialer(cardNumber);
//     }

//     setState(() {
//       text = recognizedText.text;
//       cardNumber = int.tryParse(cardNumber)?.toString() ?? '';
//       _url = Uri.parse(cardNumber);
//     });
//     print(text);
//     print('رقم الشحن: $cardNumber');
//   }

//   Future<void> _launchPhoneDialer(String cardNumber) async {
//     final url = 'tel:$cardNumber';
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw Exception('Could not launch phone dialer');
//     }
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           title: const Align(
//               alignment: Alignment.centerRight,
//               child: Text(
//                 "اشحن كارتك",
//                 style: TextStyle(
//                   fontSize: 35,
//                   fontWeight: FontWeight.w900,
//                   color: Color.fromARGB(255, 0, 153, 255),
//                 ),
//               )),
//           backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
//       body: Container(
//         child: Column(
//           children: [
//             Expanded(
//               child: FutureBuilder<void>(
//                 future: _initializeControllerFuture,
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.done) {
//                     return Stack(
//                       alignment: Alignment.center,
//                       children: <Widget>[
//                         BackdropFilter(
//                             filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
//                             child: Container(
//                               alignment: Alignment.center,
//                               color: Colors.black.withOpacity(0.5),
//                             )),
//                         CameraPreview(_cameraController!),
//                         Positioned(
//                           top: 200.0,
//                           left: 80.0,
//                           child: ClipRect(
//                             child: Container(
//                               width: 200.0,
//                               height: 200.0,
//                               decoration: BoxDecoration(
//                                 border: Border.all(
//                                   color: Colors.green,
//                                   width: 2.0,
//                                 ),
//                                 color: Colors.transparent,
//                               ),
//                             ),
//                           ),
//                         )
//                       ],
//                     );
//                   } else {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                 },
//               ),
//             ),
//             MaterialButton(
//               padding: const EdgeInsets.all(10),
//               minWidth: 50,
//               height: 30,
//               color: const Color.fromARGB(255, 255, 255, 255),
//               onPressed: () {
//                 _pickImage(ImageSource.gallery).then((value) {
//                   if (_image != null) {
//                     textRecognition(_image!);
//                   }
//                 });
//               },
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(
//                     Icons.photo,
//                     color: Color.fromARGB(255, 0, 153, 255),
//                   ),
//                   SizedBox(
//                     width: 5,
//                   ),
//                   Text(
//                     'Gallery',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 0, 153, 255)),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
