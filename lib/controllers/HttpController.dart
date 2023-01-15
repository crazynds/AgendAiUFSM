import 'dart:convert' as convert;
import 'dart:io';

import 'package:http/http.dart' as http;

class HttpController {
  static Map<String, String> globalHeaders = {
    HttpHeaders.acceptHeader:
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3',
    HttpHeaders.acceptLanguageHeader: 'pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7',
    HttpHeaders.cacheControlHeader: 'max-age=0',
    HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    'upgrade-insecure-requests': '1',
  };
  static Map<String, String> globalCookies = {};

  static Future<http.Response> post(
      Uri url, Map<String, String> headers, Map body) async {
    final String data = convert.jsonEncode(body);

    final Map<String, String> head = {}
      ..addAll(headers)
      ..addAll(globalHeaders);

    var response = await http.post(url, headers: head, body: data);
    _updateCookie(response);
    return response;
  }

  static Future<http.Response> get(Uri url, Map<String, String> headers) async {
    final Map<String, String> head = {}
      ..addAll(headers)
      ..addAll(globalHeaders);

    var response = await http.get(url, headers: head);
    _updateCookie(response);
    return response;
  }

  static _updateCookie(http.Response response) {
    String? allSetCookie = response.headers['set-cookie'];
    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var rawCookie in cookies) {
          if (rawCookie.isNotEmpty) {
            var keyValue = rawCookie.split('=');
            if (keyValue.length == 2) {
              var key = keyValue[0].trim();
              var value = keyValue[1];
              if (key == 'path' || key == 'expires') return;
              globalCookies[key] = value;
            }
          }
        }
      }

      globalHeaders['cookie'] = _generateCookieHeader();
    }
  }

  static String _generateCookieHeader() {
    String cookie = "";
    globalCookies.forEach((key, value) {
      if (cookie.isNotEmpty) cookie += ";";
      cookie += "$key=$value";
    });
    return cookie;
  }
}
