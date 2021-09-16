import 'dart:async';
import 'dart:convert';
import 'dart:io' as IO;
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Tesseract {
  static const String TESS_DATA_CONFIG = 'assets/tessdata_config.json';
  static const String TESS_DATA_PATH = 'assets/tessdata';
  static const MethodChannel _channel = const MethodChannel('tesseract');

  static Future<bool> initTesseractIOS({String? language, Map? args}) async {
    if (IO.Platform.isIOS) {
      String tessData = await _loadTessData();
      tessData = tessData + "/tessdata";
      final bool status =
          await _channel.invokeMethod('initswiftyTesseract', <String, dynamic>{
        'tessData': tessData,
        'language': language,
        'args': args,
      });
      return status;
    } else {
      return false;
    }
  }

  static Future<bool> initTesseractAndroid(
      {String? language, Map? args}) async {
    if (IO.Platform.isAndroid) {
      final String tessData = await _loadTessData();
      final bool status =
          await _channel.invokeMethod('initTesseract', <String, dynamic>{
        'tessData': tessData,
        'language': language,
        'args': args,
      });
      return status;
    } else {
      return false;
    }
  }

  static Future<bool> initTesseract({String? language, Map? args}) async {
    if (IO.Platform.isIOS) {
      return initTesseractIOS(language: language, args: args);
    } else if (IO.Platform.isAndroid) {
      return initTesseractAndroid(language: language, args: args);
    } else {
      return false;
    }
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

  static Future<String> _loadTessData() async {
    final IO.Directory appDirectory = await getApplicationDocumentsDirectory();
    final String tessdataDirectory = appDirectory.path + '/tessdata';

    if (await IO.Directory(tessdataDirectory).exists()) {
      if (Platform.isIOS) {
        print("TessData Directory Already exists: " +
            appDirectory.path +
            "/tessdata");
      } else {
        print("TessData Directory Already exists: " + appDirectory.path);
      }
      return appDirectory.path;
    }

    if (!await IO.Directory(tessdataDirectory).exists()) {
      await IO.Directory(tessdataDirectory).create();
    }
    await _copyTessDataToAppDocumentsDirectory(tessdataDirectory);

    return appDirectory.path;
  }

  static Future _copyTessDataToAppDocumentsDirectory(
      String tessdataDirectory) async {
    try {
      final String config = await rootBundle.loadString(TESS_DATA_CONFIG);
      Map<String, dynamic> files = jsonDecode(config);
      for (var zipFile in files["files"]) {
        final ByteData data =
            await rootBundle.load(TESS_DATA_PATH + "/" + zipFile);

        final Uint8List bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );

        var content = GZipCodec().decode(bytes);
        File(tessdataDirectory +
            "/" +
            zipFile.toString().substring(0, zipFile.toString().length - 3))
          ..createSync(recursive: true)
          ..writeAsBytesSync(content);
      }
    } catch (ex) {
      print(" >>>>>>>> Error Occured while Copying tessData: " + ex.toString());
    }
  }
}
