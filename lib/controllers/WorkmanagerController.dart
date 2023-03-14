import 'package:agendai_ufsm/controllers/NotificationController.dart';
import 'package:agendai_ufsm/controllers/RuController.dart';
import 'package:agendai_ufsm/models/History.dart';
import 'package:agendai_ufsm/models/Model.dart';
import 'package:agendai_ufsm/models/RuSchedule.dart';
import 'package:agendai_ufsm/models/RuScheduleConfiguration.dart';
import 'package:agendai_ufsm/models/User.dart';
import 'package:intl/intl.dart';
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
    RuScheduleConfiguration config = RuScheduleConfiguration.load();
    History hist = History.load();
    User user = User.load();
    bool? autenticado = null;
    RuScheduleConfiguration config = RuScheduleConfiguration.load();
    int id = 5;
    var currentSchedule = DateTime.now();
    if (currentSchedule.compareTo(hist.lastDayExecuted).isNegative) {
      currentSchedule = hist.lastDayExecuted;
    }

    // Verificar se terminou os agendamentos e finaliza o grupo de tarefas
    if (hist.stopped ||
        config.fimSchedule.compareTo(currentSchedule).isNegative) {
      print("cancelamo a tarefa por chegar no dia final");
      print(hist.stopped);
      print(DateFormat("dd/MM/yyyy").format(config.fimSchedule));
      print(DateFormat("dd/MM/yyyy").format(currentSchedule));
      // Cancela a tarefa
      Workmanager().cancelByUniqueName('agendar-ru');
      hist.clear();
      hist.stopped = true;
      hist.save();
      NotificationController.instance.showNotification(
          ChannelNotification.lembrete,
          NotificationPopup(
              id: id++,
              title: 'Agendamento automático desativado',
              body:
                  'O sistema de agendamento automático foi desativo por ter chego na data programada ou erros em relação ao login no portal.'));
      return;
    }

    print("Adicionando agendamentos a fila");
    for (currentSchedule = currentSchedule.add(Duration(days: 1));
        currentSchedule
                    .difference(DateTime.now().subtract(Duration(seconds: 20)))
                    .inDays <
                4 &&
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
    hist.lastDayExecuted = currentSchedule;

    // Função para fazer a autenticação
    authUser() async {
      if (autenticado == null) {
        User? u = await RuController.auth(user);
        autenticado = u != null;
      }
      if (autenticado == false) {
        print("não foi possivel autenticar");
        return false;
      }
      return true;
    }

    print("Verificando agendamentos antigos");
    // Verificar se os agendamentos feitos e que estão de ontem para tras foram comparecidos]
    var now = DateTime.now().subtract(Duration(days: 1));
    for (RuSchedule sc in hist.lastScheduleMade) {
      if (now.compareTo(sc.data) < 0) {
        await authUser();
        // É possivel comparar e ver se ele foi no agendamento realizado
        var r = await RuController.checkSchedule(sc);
        // Por algum motivo não possivel verificar, apenas ignora e vai para a próxima iteração
        if (r == null) continue;
        if (r) {
          // O agendamento foi comparecido, então só remove ele da fila
          hist.lastScheduleMade.remove(sc);
        } else {
          print("cancelamo a tarefa por não ter comparecido um dia antes");
          // O agendamento não foi comparecido,
          Workmanager().cancelByUniqueName('agendar-ru');
          hist.stopped = true;

          NotificationController.instance.showNotification(
              ChannelNotification.erro,
              NotificationPopup(
                  id: id++,
                  title: 'Problemas no login',
                  body: 'Houve problemas ao tentar fazer login no portal.'));
          return;
        }
      }
    }
    print("Fazendo agendamentos");
    // Se não terminou os agendamentos, tentar efetuar os agendamentos em aberto
    for (var x = 0; x < hist.nextScheduleToMake.length; x++) {
      RuSchedule sc = hist.nextScheduleToMake.elementAt(x);
      if (sc.data.compareTo(DateTime.now()) < 0) {
        hist.nextScheduleToMake.remove(sc);
        continue;
      }
      if (!await authUser()) {
        return;
      }
      RuAgendamentoErro erro = await RuController.schedule(sc);
      print(erro.msg);
      switch (erro) {
        case RuAgendamentoErro.ok:
          // OK adiciona na fila de verificacao e remove da fila de fazer
          hist.lastScheduleMade.add(sc);
          hist.nextScheduleToMake.remove(sc);
          x--;

          final day = DateFormat("dd/MM/yyyy").format(sc.data);
          final refeicao = sc.refeicao.name;
          NotificationController.instance.showNotification(
              ChannelNotification.avisos,
              NotificationPopup(
                  id: id++,
                  title: 'Agendamento realizado!',
                  body: 'Dia ${day} para o ${refeicao}'));
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
          x--;
          NotificationController.instance.showNotification(
              ChannelNotification.avisos,
              NotificationPopup(
                  id: id++,
                  title: 'Agendamento não realizado!',
                  body: erro.msg));
          break;
        case RuAgendamentoErro.matricula:
          // Erro no login e senha cancel, cancel all agendamentos
          hist.nextScheduleToMake.clear();
          NotificationController.instance.showNotification(
              ChannelNotification.avisos,
              NotificationPopup(
                  id: id++,
                  title: 'Agendamento não realizado!',
                  body: erro.msg));
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
