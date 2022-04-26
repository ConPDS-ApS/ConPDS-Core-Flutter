import 'package:flutter/services.dart';

class OCRProvider {
  String apiKey;
  String licenseKey;

  static const platformOCR =
      MethodChannel('com.conpds.ocrenginedemo.java.ocrenginedemoapp/ocr');

  OCRProvider({
    required this.apiKey,
    required this.licenseKey,
  });

  Future<void> ocr(String filePath) async {
    await platformOCR.invokeMethod('fromFile', [apiKey, licenseKey, filePath]);
  }

  void getOCR(Function(dynamic) getOCR) async {
    platformOCR.setMethodCallHandler((call) async {
      if (call.method == 'sendData') {
        getOCR(call.arguments);
      }
    });
  }
}
