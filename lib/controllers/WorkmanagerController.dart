import 'package:agendai_ufsm/controllers/RuController.dart';
import 'package:agendai_ufsm/models/History.dart';
import 'package:agendai_ufsm/models/Model.dart';
import 'package:agendai_ufsm/models/RuSchedule.dart';
import 'package:agendai_ufsm/models/RuScheduleConfiguration.dart';
import 'package:agendai_ufsm/models/User.dart';
import 'package:workmanager/workmanager.dart';

class WorkmanagerController {
  static Future<void> callable(task, inputData) async {
    print('Tarefa passou no callable');
    switch (task) {
      case 'agendar-ru':
        print('chamou o agendar RU');
        await WorkmanagerController.agendarRu();
        break;
    }
    print('Tarefa saiu do callable');
  }

  static User? _auth = null;

  static Future<User?> authRu(User user) async {
    if (_auth != null) return Future.value(_auth);

    _auth = await RuController.auth(user);
    return _auth;
  }

  static Future<void> agendarRu() async {
    RuScheduleConfiguration config = RuScheduleConfiguration.load();
    History hist = History.load();
    User user = User.load();
    // Calcular os próximos agendamentos
    //WorkmanagerController.calculateNextScheduleDate();

    // Verificar se terminou os agendamentos e finaliza o grupo de tarefas
    if (hist.stopped ||
        config.fimSchedule
            .add(Duration(days: 1))
            .compareTo(DateTime.now())
            .isNegative) {
      // Cancela a tarefa
      Workmanager().cancelByUniqueName('agendar-ru');
      hist.stopped = true;
      // TODO - Envia notificação que chegou ao fim do schedule e o bot vai ser finalizado.
      return;
    }
    print('Tarefa dentro do ok!!');

    // Verificar se os agendamentos feitos e que estão de ontem para tras foram comparecidos
    var now = DateTime.now().subtract(Duration(days: 1));
    for (RuSchedule sc in hist.lastScheduleMade) {
      if (now.compareTo(sc.data) < 0) {
        // É possivel comparar e ver se ele foi no agendamento realizado
        User? u = await authRu(user);
        if (u == null) {
          Workmanager().cancelByUniqueName('agendar-ru');
          hist.stopped = true;
          // TODO - Emite notificação que não foi possivel autenticar
          return;
        }
        var r = await RuController.checkSchedule(sc);
        // Por algum motivo não possivel verificar, apenas ignora e vai para a próxima iteração
        if (r == null) continue;
        if (r) {
          // O agendamento foi comparecido, então só remove ele da fila
          hist.lastScheduleMade.remove(sc);
        } else {
          // O agendamento não foi comparecido, desliga o agendador
          Workmanager().cancelByUniqueName('agendar-ru');
          hist.stopped = true;

          // TODO - Envia notificação que ocorreu uma falta de agendamento.
          return;
        }
      }
    }
    // Se não terminou os agendamentos, tentar efetuar os agendamentos em aberto
    for (RuSchedule sc in hist.nextScheduleToMake) {
      User? u = await authRu(user);
      if (u == null) {
        Workmanager().cancelByUniqueName('agendar-ru');
        hist.stopped = true;
        // TODO - Emite notificação que não foi possivel autenticar
        return;
      }
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
          // Erro no login, cancela todos os agendamentos
          hist.clear();
          Workmanager().cancelByUniqueName('agendar-ru');
          hist.stopped = true;
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
    user.save();
    hist.save();
    config.save();
  }
}
