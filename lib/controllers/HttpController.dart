import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:http/http.dart' as http;

class HttpController {
  static final instance = HttpController();

  final dio = Dio();
  final cookieJar = CookieJar();

  Map<String, String> globalHeaders = {
    HttpHeaders.acceptHeader: '*/*',
    HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
  };

  HttpController() {
    dio.interceptors.add(CookieManager(cookieJar));
  }

  Future<Response<dynamic>> post(String url, Options options, Map body) async {
    try {
      var response = await dio.post<String>(url, data: body, options: options);
      return response;
    } on DioError catch (e) {
      return e.response ??
          Response(
              data: '',
              statusCode: 599,
              requestOptions: RequestOptions(path: url));
    }
  }

  Future<Response<dynamic>> get(String url, Options options) async {
    try {
      var response = await dio.get(url, options: options);
      return response;
    } on DioError catch (e) {
      return e.response ??
          Response(
              data: '',
              statusCode: 599,
              requestOptions: RequestOptions(path: url));
    }
  }

  Future<Response<dynamic>> getFile(
      String url, Options options, String filePath) async {
    try {
      var response = await dio.download(url, filePath, options: options);
      return response;
    } on DioError catch (e) {
      return e.response ??
          Response(
              data: '',
              statusCode: 599,
              requestOptions: RequestOptions(path: url));
    }
  }
}
