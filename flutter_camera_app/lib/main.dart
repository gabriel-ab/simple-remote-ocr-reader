import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart' as c;
import 'package:flutter/material.dart' as m;



Future<http.ByteStream> request(Uint8List jpegImage, {String method = '/read'}) async {
  var request = http.MultipartRequest('POST', Uri.http('192.168.0.108:8000', method))
    ..files.add(http.MultipartFile.fromBytes('image', jpegImage, filename: 'image.jpg'));

  var response = await request.send();
  if (response.statusCode == 200) {
    return response.stream;
  } else {
    throw Exception("$response");
  }
}

Future<http.ByteStream> takePictureAndRequest(c.CameraController controller, {String method = '/read'}) async {
  final imagePath = await controller.takePicture();
  return request(await imagePath.readAsBytes(), method: method);
}

Future<void> main() async {
  m.WidgetsFlutterBinding.ensureInitialized();
  final cameras = await c.availableCameras();
  final firstCamera = cameras.first;
  m.runApp(
    m.MaterialApp(
      theme: m.ThemeData.dark(),
      home: TakePictureScreen(
        camera: firstCamera,
      ),
    ),
  );
}

class TakePictureScreen extends m.StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final c.CameraDescription camera;

  @override
  m.State<TakePictureScreen> createState() => TakePictureScreenState();
  
}

class TakePictureScreenState extends m.State<TakePictureScreen> {
  late c.CameraController controller;
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    controller = c.CameraController(
      widget.camera,
      c.ResolutionPreset.high,
    );
    controller.initialize().then((value) {
      if (!mounted) return;
      initialized = true;
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  m.Widget build(m.BuildContext context) {
    return initialized ? m.Scaffold(
      appBar: m.AppBar(
        title: const m.Text('Take a picture'),
        actions: <Widget>[
          
          m.Tooltip(
            message: 'Foco Automático',
            child: m.ElevatedButton(
              onPressed: () async {
                  await controller.setFocusMode(c.FocusMode.auto);
                  await controller.setFocusMode(c.FocusMode.locked);
              },
              style: m.ElevatedButton.styleFrom(backgroundColor: m.Colors.transparent),
              child: const m.Icon(m.Icons.center_focus_strong),
            ),
          ),
          m.ElevatedButton(
            onPressed: () {
              controller.setFlashMode(c.FlashMode.off);
            },
            style: m.ElevatedButton.styleFrom(backgroundColor: m.Colors.transparent),
            child: const m.Icon(m.Icons.flashlight_off),
          ),
          m.ElevatedButton(
            onPressed: () {
              controller.setFlashMode(c.FlashMode.torch);
            },
            style: m.ElevatedButton.styleFrom(backgroundColor: m.Colors.transparent),
            child: const m.Icon(m.Icons.flashlight_on),
          ),
        ],
      ),
      body: Column(
        children: [
          c.CameraPreview(controller),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              m.FloatingActionButton(
                onPressed: () async {
                  controller.setFlashMode(c.FlashMode.off);
                  m.Navigator.of(context).push(m.MaterialPageRoute(builder: (context) => const ProcessingScreen(text: 'Lendo o texto...')));

                  try {
                    final text = await (await takePictureAndRequest(controller, method: '/read')).bytesToString();
                    
                    if (!mounted) return;
                    await m.Navigator.of(context).pushReplacement(
                      m.MaterialPageRoute(
                        builder: (context) => ExtractedTextScreen(text: text)
                      )
                    );
                  } on Exception {
                    m.Navigator.of(context).pop();
                  }
                    
                },
                tooltip: "Ler Texto",
                heroTag: 'read',
                child: const m.Icon(m.Icons.camera_alt),
              ),
              m.FloatingActionButton(
                onPressed: () async {
                  m.Navigator.of(context).push(m.MaterialPageRoute(builder: (context) => const ProcessingScreen(text: 'Lendo e desenhando detecções...')));
                  try {
                    final image = await (await takePictureAndRequest(controller, method: '/draw')).toBytes();
                    if (!mounted) return;
                    m.Navigator.of(context).pushReplacement(
                      m.MaterialPageRoute(
                        builder: (context) => DisplayPictureScreen(
                          title: "Textos encontrados",
                          image: m.Image.memory(image),
                        ),
                      ),
                    );
                  } on Exception {
                    m.Navigator.of(context).pop();
                  }
                },
                tooltip: 'Desenhar detecções',
                heroTag: 'draw',
                child: const m.Icon(m.Icons.draw),
              ),
            ],
          ),
        ],
      ),
    ) : const ProcessingScreen(text: 'Carregando');
  }
}

class ProcessingScreen extends m.StatelessWidget {
  final String text;
  const ProcessingScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return m.Scaffold(
      appBar: m.AppBar(title: m.Text(text)),
      body: const m.Center(child: m.CircularProgressIndicator()),
    );
  }
}

class ExtractedTextScreen extends m.StatelessWidget {
  final String text;
  const ExtractedTextScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return m.Scaffold(
      appBar: m.AppBar(title: const m.Text("Texto Extraido"),),
      body: m.Center(
        child: m.Text(text, textScaleFactor: 2.0,),
      ),
    );
  }
}

class ErrorScreen extends m.StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return m.Center(
      child: m.Text(error, style: const m.TextStyle(color: m.Colors.green), textAlign: m.TextAlign.center, textScaleFactor: 0.2),
    );
  }
}

class DisplayPictureScreen extends m.StatelessWidget {
  final String title;
  final m.Image image;
  const DisplayPictureScreen({super.key, required this.image, required this.title});

  @override
  m.Widget build(m.BuildContext context) {
    return m.Scaffold(
      appBar: m.AppBar(title: m.Text(title)),
      body: image,
    );
  }
}
