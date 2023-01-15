import 'dart:convert' as convert;
import 'dart:io';

import 'package:agendai_ufsm/controllers/HttpController.dart';

class RuController {
  static Future<bool> auth(String code, String password) async {
    var response = await HttpController.post(
        Uri.parse('https://portal.ufsm.br/ru/j_security_check'), {
      HttpHeaders.refererHeader: 'https://portal.ufsm.br/ru/index.html',
    }, {
      'j_username': code,
      'j_password': password
    });

    if (response.statusCode >= 200 && response.statusCode <= 299) {
      // sucess
      var responseStr = response.body;
      if (responseStr.contains('Página de login</title>')) {
        // Fail login
        return false;
      } else {
        // Login sucess
        return true;
      }
    } else {
      return false;
    }
  }
}
