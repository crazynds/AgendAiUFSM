import 'dart:io';

import 'package:agendai_ufsm/controllers/HttpController.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:path_provider/path_provider.dart';

class OCRController {
  static OCRController instance = OCRController();

  Future<String> getText(String url, List<String> selectList, Map args) async {
    if (kIsWeb == false &&
        (url.indexOf("http://") == 0 || url.indexOf("https://") == 0)) {
      Directory tempDir = await getTemporaryDirectory();
      // HttpClient httpClient = HttpClient();
      // HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      // HttpClientResponse response = await request.close();
      // Uint8List bytes = await consolidateHttpClientResponseBytes(response);
    

      String dir = tempDir.path;
      String fullPath = '$dir/test.jpg';
      await HttpController.instance.getFile(url, Options(), fullPath);
      url = fullPath;
    }
    var langs = selectList.join("+");
    print('start processing');
    String _ocrText =
        await FlutterTesseractOcr.extractText(url, language: langs, args: args);
    print(_ocrText);
    print('end processing');
    return _ocrText;
  }
  Future<bool> fixRecycle()async {
      await getText('https://tesseract.projectnaptha.com/img/eng_bw.png', ['eng'], {});
      return true;
  }
}
