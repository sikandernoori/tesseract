import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tesseract Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tesseract Demo'),
        centerTitle: true,
        // elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  //TODO Add Example

                  // CustomCard(
                  //   label: 'Tesseract OCR',
                  //   featureStatus: FeatureStatus.Both,
                  //   viewPage: TesseractOCR(),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String label;
  final Widget viewPage;
  final FeatureStatus featureStatus;

  const CustomCard(
      {required this.label,
      required this.viewPage,
      required this.featureStatus});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (Platform.isIOS &&
              (featureStatus.index == 0 || featureStatus.index == 1)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    'This feature has not been implemented for iOS yet')));
          } else if (Platform.isAndroid &&
              (featureStatus.index == 0 || featureStatus.index == 2)) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text(
                    'This feature has not been implemented for Android yet')));
          } else if (!Platform.isAndroid && !Platform.isIOS) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: const Text('Platform Not Supported')));
          } else
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => viewPage));
        },
      ),
    );
  }
}

enum FeatureStatus { None, Android, IOS, Both }
