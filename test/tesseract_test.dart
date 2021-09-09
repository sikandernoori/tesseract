import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tesseract/tesseract.dart';

void main() {
  const MethodChannel channel = MethodChannel('tesseract');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('initTesseract', () async {
    expect(await Tesseract.initTesseract(language: "eng"), true);
  });
}
