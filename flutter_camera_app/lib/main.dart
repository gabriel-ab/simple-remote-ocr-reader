import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/src/media_type.dart' as mt;
import 'package:camera/camera.dart' as c;
import 'package:flutter/material.dart' as m;


Future<Uint8List> preprocess(Uint8List imageData) async {
  var request = http.MultipartRequest('POST', Uri.parse('192.168.0.108:8000/preprocess'));
  request.fields['title'] = 'MyImage';

  var pic = http.MultipartFile.fromBytes('image', imageData, contentType: mt.MediaType('image', 'jpeg'));
  request.files.add(pic);

  var response = await request.send();
  var data = await response.stream.toBytes();
  return data;
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
  void initState() async {
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
            final image = await controller.takePicture();
            final processed = await preprocess(await image.readAsBytes());
            await m.Navigator.of(context).push(
              m.MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  image: m.Image.memory(processed),
                  title: "Imagem Processada",
                ),
              ),
            );
          } catch (e) {
            await m.Navigator.of(context).push(
              m.MaterialPageRoute(
                builder: (context) => const m.Center(
                  child: m.Text('Um erro inesperado ocorreu', style: m.TextStyle(color: m.Colors.green), textAlign: m.TextAlign.center,),
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
