import 'dart:convert' as convert;
import 'dart:io';

import 'package:agendai_ufsm/controllers/HttpController.dart';
import 'package:agendai_ufsm/controllers/OCRController.dart';
import 'package:agendai_ufsm/models/User.dart';
import 'package:dio/dio.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:intl/intl.dart';

enum RestauranteUFSM{
  ru1(1),
  ru2(41),
  ruPalmeiraDasMissoes(3);

  final int code;
  const RestauranteUFSM(this.code);
}

enum TipoRefeicao{
  cafe(1),
  almoco(2),
  janta(3);

  final int code;
  const TipoRefeicao(this.code);
}

class RuController {

  static Future<User?> auth(String code, String password) async {

    var response = await HttpController.instance.post('https://portal.ufsm.br/ru/j_security_check', Options(contentType: Headers.formUrlEncodedContentType), {
      'j_username': code,
      'j_password': password
    });
    String? responseStr = response.data;
    if (response.statusCode != 302)return null;

    var response2 = await HttpController.instance.get('https://portal.ufsm.br/ru/usuario/extratoSimplificado.html', Options());

    responseStr = response2.data;
    
    if (response2.statusCode! >= 200 && response2.statusCode! <= 299 && responseStr!=null && responseStr.contains('<title>Controle de restaurantes universit')) {
      final regex = RegExp(r'<i class="icon-user"><\/i> (.+) <span class="caret"><\/span>');
      final mathc = regex.firstMatch(responseStr);
      return User(mathc?.group(1) ?? 'Nome não encontrado');
    } else {
      return null;
    }
  }

  static Future<bool> agendar(RestauranteUFSM restaurante,DateTime day,TipoRefeicao refeicao,bool vegetariano) async{
    var response2 = await HttpController.instance.get('https://portal.ufsm.br/ru/usuario/extratoSimplificado.html', Options());
    if (response2.statusCode! < 200 || response2.statusCode! > 299 || response2.data==null || !response2.data.contains('<title>Controle de restaurantes universit')) {
      return false;
    }
    String responseStr;
    do{

      String captcha =await OCRController.instance.getText('https://portal.ufsm.br/ru/usuario/captcha.html', ["por"], {
        'tessedit_char_whitelist': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'tessedit_pageseg_mode': 'SINGLE_WORD',
      });
      print(captcha);
      var data ={
        'periodo.inicio': DateFormat('dd/MM/yyyy').format(day),
        'periodo.fim': DateFormat('dd/MM/yyyy').format(day),
        'restaurante': restaurante.code,
        'tiposRefeicao': refeicao.code,
        'opcaoVegetariana': vegetariano? "true": 'false',
        'captcha': captcha
      };
      var response = await HttpController.instance.post('https://portal.ufsm.br/ru/usuario/agendamento/form.html', Options(contentType: Headers.formUrlEncodedContentType),data );
      if(response.data==Null) {
        return false;
      }
      if(response.statusCode!=200){
        return false;
      }
      responseStr = response.data as String;
    }while(responseStr.contains('<span class="pill error" id="_captcha">Campo'));
    for(String l in responseStr.split('\n')){
      print(l);
    }
    if(responseStr.contains('Resultado da solicita')){
      print('Foi com sucesso');
      return true;
    }else{
      print('Foi com sucesso');
      return false;
    }
  }
}
