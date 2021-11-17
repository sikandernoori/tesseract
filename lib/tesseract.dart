import 'dart:async';
import 'dart:io' as IO;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;

class Tesseract {
  static const String TESS_DATA_PATH = 'assets/tessdata';
  static const MethodChannel _channel = const MethodChannel('tesseract');

  static Future<bool> initTesseract(
      {required String language, Map? args}) async {
    final String tessData = await _loadTessData(language);
    final bool status =
        await _channel.invokeMethod('initTesseract', <String, dynamic>{
      'tessData': tessData,
      'language': language,
      'args': args,
    });
    return status;
  }

  static Future<Map> performOCR(
      {required Uint8List image, String? language, Map? args}) async {
    final extractMap =
        await _channel.invokeMethod('performOCR', <String, dynamic>{
      'imageData': image,
      'language': language,
      'args': args,
    });

    return extractMap;
  }

  static Future<String> _loadTessData(String prefix) async {
    final IO.Directory appDirectory = await getApplicationDocumentsDirectory();
    final String tessdataDirectory = appDirectory.path + '/tessdata';

    if (!await IO.Directory(tessdataDirectory).exists()) {
      await IO.Directory(tessdataDirectory).create();
    } else {
      print('TessData directory already exists.');
    }

    var filePath = '$tessdataDirectory/$prefix.traineddata';
    if (!await IO.File(filePath).exists()) {
      await _copyTessDataToAppDocumentsDirectory(filePath, prefix);
    } else {
      print('Trained data file already exists.');
    }

    return appDirectory.path;
  }

  static Future _copyTessDataToAppDocumentsDirectory(
      String filePath, String prefix) async {
    try {
      final ByteData data =
          await rootBundle.load('$TESS_DATA_PATH/$prefix.traineddata.gz');

      final Uint8List bytes = data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      var content = GZipCodec().decode(bytes);
      File(filePath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(content);
      print('Trained data file copied');
    } catch (ex) {
      print(" >>>>>>>> Error Occured while Copying tessData: " + ex.toString());
    }
  }
}
