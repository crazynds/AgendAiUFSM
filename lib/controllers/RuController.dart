import 'dart:convert' as convert;
import 'dart:io';

import 'package:agendai_ufsm/controllers/HttpController.dart';
import 'package:agendai_ufsm/controllers/OCRController.dart';
import 'package:agendai_ufsm/models/RuSchedule.dart';
import 'package:agendai_ufsm/models/User.dart';
import 'package:dio/dio.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:intl/intl.dart';

enum RestauranteUFSM {
  ru1(1),
  ru2(41),
  ruPalmeiraDasMissoes(3);

  final int code;
  const RestauranteUFSM(this.code);

  static RestauranteUFSM getByCode(int c) {
    switch (c) {
      case 1:
        return RestauranteUFSM.ru1;
      case 41:
        return RestauranteUFSM.ru2;
      case 3:
        return RestauranteUFSM.ruPalmeiraDasMissoes;
      default:
        return RestauranteUFSM.ru1;
    }
  }
}

enum TipoRefeicao {
  cafe(1),
  almoco(2),
  janta(3);

  final int code;
  const TipoRefeicao(this.code);
}

enum RuAgendamentoErro {
  ok("Agendamento feito!"),
  conexao("Problema de conexao com o servidor"),
  matricula("Problema no login (matricula e senha)"),
  unknown("Não sei pq esse erro aconteceu. Isso me deixa triste"),
  captcha("Não foi possivel adivinhar o captcha ;-;"),
  agendamentoCheio("O limite de agendamentos no restaurante já foi atingido."),
  naoEhPossivelAgendar("Não é possivel agendar para essa data"),
  bseNecessario(
      "É necessário ter o benefício do BSE para agendar para esse dia.");

  final String msg;
  const RuAgendamentoErro(this.msg);
}

class RuController {
  static Future<User?> auth(User user) async {
    var response = await HttpController.instance.post(
        'https://portal.ufsm.br/ru/j_security_check',
        Options(contentType: Headers.formUrlEncodedContentType),
        {'j_username': user.code, 'j_password': user.password});
    String? responseStr = response.data;

    if (response.statusCode != 302) return null;

    var response2 = await HttpController.instance.get(
        'https://portal.ufsm.br/ru/usuario/extratoSimplificado.html',
        Options());

    responseStr = response2.data;

    if (response2.statusCode! >= 200 &&
        response2.statusCode! <= 299 &&
        responseStr != null &&
        responseStr.contains('<title>Controle de restaurantes universit')) {
      final regex = RegExp(
          r'<i class="icon-user"><\/i> (.+) <span class="caret"><\/span>');
      final match = regex.firstMatch(responseStr);
      user.name = match?.group(1) ?? 'Nome não encontrado';
      user.save();
      return user;
    } else {
      return null;
    }
  }

  static Future<RuAgendamentoErro> schedule(RuSchedule schedule) async {
    var response2 = await HttpController.instance.get(
        'https://portal.ufsm.br/ru/usuario/extratoSimplificado.html',
        Options());
    if (response2.statusCode == 599) return RuAgendamentoErro.conexao;
    if (response2.statusCode! < 200 ||
        response2.statusCode! > 299 ||
        response2.data == null) return RuAgendamentoErro.conexao;
    if (!response2.data.contains('<title>Controle de restaurantes universit')) {
      return RuAgendamentoErro.matricula;
    }
    String responseStr;
    int tries = 0;
    do {
      String captcha = await OCRController.instance
          .getText('https://portal.ufsm.br/ru/usuario/captcha.html', [
        "por"
      ], {
        'tessedit_char_whitelist': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'tessedit_pageseg_mode': 'SINGLE_WORD',
      });
      var data = {
        'periodo.inicio': DateFormat('dd/MM/yyyy').format(schedule.data),
        'periodo.fim': DateFormat('dd/MM/yyyy').format(schedule.data),
        'restaurante': schedule.restaurante.code,
        'tiposRefeicao': schedule.refeicao.code,
        'opcaoVegetariana': schedule.vegetariano ? "true" : 'false',
        'captcha': captcha
      };
      var response = await HttpController.instance.post(
          'https://portal.ufsm.br/ru/usuario/agendamento/form.html',
          Options(contentType: Headers.formUrlEncodedContentType),
          data);
      if (response.data == Null || response.statusCode != 200) {
        return RuAgendamentoErro.conexao;
      }
      responseStr = response.data as String;
      tries++;
    } while (
        responseStr.contains('<span class="pill error" id="_captcha">Campo') &&
            tries <= 8);

    if (tries > 8 &&
        responseStr.contains('<span class="pill error" id="_captcha">Campo')) {
      return RuAgendamentoErro.captcha;
    }

    if (responseStr.contains('Resultado da solicita')) {
      final problemaRegex = RegExp(
          r'<span class="sr-only">.*<\/span>[\s]*<span class="(.*) pill">.*<\/span>[\s]*<\/td>[\s]*<td>[\s]*(.*)[\s]*<\/td>');
      final match = problemaRegex.firstMatch(responseStr);
      if (match == null) return RuAgendamentoErro.unknown;
      final String tag = match.group(1) as String;
      final String message = match.group(2) as String;
      if (tag == 'error') {
        if (message.contains('existe um agendamento com estes dados')) {
          return RuAgendamentoErro.ok;
        } else if (message
            .contains('O limite de agendamentos no restaurante')) {
          return RuAgendamentoErro.agendamentoCheio;
        } else if (message.contains('o autoriza para o final de semana')) {
          return RuAgendamentoErro.bseNecessario;
        } else {
          return RuAgendamentoErro.naoEhPossivelAgendar;
        }
      } else if (tag == 'success') {
        return RuAgendamentoErro.ok;
      } else {
        return RuAgendamentoErro.unknown;
      }
    } else {
      return RuAgendamentoErro.unknown;
    }
  }

  static Future<bool?> checkSchedule(RuSchedule agedamento) async {
    return null;
  }
}
