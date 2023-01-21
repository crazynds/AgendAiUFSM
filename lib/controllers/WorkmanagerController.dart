import 'package:agendai_ufsm/controllers/RuController.dart';
import 'package:agendai_ufsm/models/History.dart';
import 'package:agendai_ufsm/models/Model.dart';
import 'package:agendai_ufsm/models/RuSchedule.dart';
import 'package:agendai_ufsm/models/RuScheduleConfiguration.dart';
import 'package:agendai_ufsm/models/User.dart';
import 'package:workmanager/workmanager.dart';

class WorkmanagerController {
  static Future<void> callable(task, inputData) async {
    switch (task) {
      case 'agendar-ru':
        print('Entrou agendar ru');
        await WorkmanagerController.agendarRu();
        print('Saiu agendar ru');
        break;
    }
  }

  static Future<void> agendarRu() async {
    History hist = History.load();
    User user = User.load();
    bool? autenticado = null;
    RuScheduleConfiguration config = RuScheduleConfiguration.load();

    // Verificar se terminou os agendamentos e finaliza o grupo de tarefas
    if (hist.stopped ||
        config.fimSchedule
            .add(Duration(days: 1))
            .compareTo(DateTime.now())
            .isNegative) {
      print("cancelamo a tarefa por chegar no dia final");
      // Cancela a tarefa
      Workmanager().cancelByUniqueName('agendar-ru');
      hist.stopped = true;
      // TODO - Envia notificação que chegou ao fim do schedule e o bot vai ser finalizado.
      return;
    }

    for (var currentSchedule = DateTime.now().add(Duration(days: 1));
        DateTime.now().difference(currentSchedule).inDays <= 4 &&
            currentSchedule.weekday < 7;
        currentSchedule = currentSchedule.add(Duration(days: 1))) {
      var dayWeek = currentSchedule.weekday;
      if (dayWeek == 7) dayWeek = 0;

      if (config.dayOfWeek[dayWeek] == false) continue;

      // Pega o próximo dia e começa a crias as entradas dos agendamentos
      if (config.cafe) {
        hist.nextScheduleToMake.add(RuSchedule(
            data: currentSchedule,
            refeicao: TipoRefeicao.cafe,
            restaurante: config.local,
            vegetariano: config.vegano));
        print("Gerou cafe para: " + currentSchedule.toIso8601String());
      }
      if (config.almoco) {
        hist.nextScheduleToMake.add(RuSchedule(
            data: currentSchedule,
            refeicao: TipoRefeicao.almoco,
            restaurante: config.local,
            vegetariano: config.vegano));
        print("Gerou almoco para: " + currentSchedule.toIso8601String());
      }
      if (config.janta) {
        hist.nextScheduleToMake.add(RuSchedule(
            data: currentSchedule,
            refeicao: TipoRefeicao.janta,
            restaurante: config.local,
            vegetariano: config.vegano));
        print("Gerou janta para: " + currentSchedule.toIso8601String());
      }
    }

    // Função para fazer a autenticação
    authUser() async {
      if (autenticado == null) {
        User? u = await RuController.auth(user);
        autenticado = u != null;
      }
      if (autenticado!) {
        print("cancelamo a tarefa por n conseguir autenticar");
        Workmanager().cancelByUniqueName('agendar-ru');
        hist.stopped = true;
        // TODO - Emite notificação que não foi possivel autenticar
        return;
      }
    }

    // Verificar se os agendamentos feitos e que estão de ontem para tras foram comparecidos]
    var now = DateTime.now().subtract(Duration(days: 1));
    for (RuSchedule sc in hist.lastScheduleMade) {
      // Verificar o agendamento
      if (now.compareTo(sc.data) < 0) {
        await authUser();
        // É possivel comparar e ver se ele foi no agendamento realizado
        var r = await RuController.checkSchedule(sc);
        if (r == null) continue;
        if (r) {
          // O agendamento foi comparecido, então só remove ele da fila
          hist.lastScheduleMade.remove(sc);
        } else {
          print("cancelamo a tarefa por não ter comparecido um dia antes");
          // O agendamento não foi comparecido,
          Workmanager().cancelByUniqueName('agendar-ru');
          hist.stopped = true;

          // TODO - Envia notificação que ocorreu uma falta de agendamento, e logo vai ser cancelado o bot.
          return;
        }
      }
    }
    // Se não terminou os agendamentos, tentar efetuar os agendamentos em aberto
    for (RuSchedule sc in hist.nextScheduleToMake) {
      if (sc.data.compareTo(DateTime.now()) < 0) {
        hist.nextScheduleToMake.remove(sc);
        continue;
      }
      await authUser();
      RuAgendamentoErro erro = await RuController.schedule(sc);
      switch (erro) {
        case RuAgendamentoErro.ok:
          // OK adiciona na fila de verificacao e remove da fila de fazer
          hist.lastScheduleMade.add(sc);
          hist.nextScheduleToMake.remove(sc);
          // TODO - Envia notificação que foi agendado com sucesso para o dia X.
          break;
        case RuAgendamentoErro.agendamentoCheio:
        // Erro que o RU está cheio, ou que o tempo limite foi atingido, cancel
        case RuAgendamentoErro.bseNecessario:
        // Erro que precisa do bse para esse dia, cancel
        case RuAgendamentoErro.naoEhPossivelAgendar:
        // Erro de não pode agendar nesse dia, cancel
        case RuAgendamentoErro.unknown:
          // Erro desconhecido, cancel
          hist.nextScheduleToMake.remove(sc);
          // TODO - Envia notificação que o agendamento não foi possivel com a mensagem de erro.
          break;
        case RuAgendamentoErro.matricula:
          // Erro no login e senha cancel, cancel all agendamentos
          hist.nextScheduleToMake.clear();
          // TODO - Envia notificação que deu problema ao na matricula
          break;
        case RuAgendamentoErro.captcha:
        // Erro no captcha, retry na próxima vez
        case RuAgendamentoErro.conexao:
        // Erro na conexão, retry na próxima vez
        default:
          break;
      }
    }
  }
}
