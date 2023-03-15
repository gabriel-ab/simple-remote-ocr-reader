import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:camera/camera.dart' as c;
import 'package:flutter/material.dart' as m;



Future<Uint8List> preprocess(Uint8List jpegImage) async {
  var request = http.MultipartRequest('POST', Uri.http('192.168.0.108:8000', '/preprocess'))
    ..files.add(http.MultipartFile.fromBytes('image', jpegImage, filename: 'image.jpg'));

  var response = await request.send();
  if (response.statusCode == 200) {
    return await response.stream.toBytes();
  } else {
    throw Exception("$response");
  }
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
      appBar: m.AppBar(title: const m.Text('Take a picture')),
      body: c.CameraPreview(controller),
      floatingActionButton: m.FloatingActionButton(
        onPressed: () async {
          try {
            final imagePath = await controller.takePicture();
            final processed = await preprocess(await imagePath.readAsBytes());
            m.Navigator.of(context).push(
              m.MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // image: m.Image.memory(i.encodeJpg(image)),
                  image: m.Image.memory(processed),
                  title: "Imagem Processada",
                ),
              ),
            );
          } catch (e) {
            await m.Navigator.of(context).push(
              m.MaterialPageRoute(
                builder: (context) => m.Center(
                  child: m.Text('$e', style: const m.TextStyle(color: m.Colors.green), textAlign: m.TextAlign.center, textScaleFactor: 0.2),
                ),
              ),
            );
          }
        },
        tooltip: "Tirar Foto",
        child: const m.Icon(m.Icons.camera_alt),
      ),
    ) : const m.Center(child: m.CircularProgressIndicator());
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
