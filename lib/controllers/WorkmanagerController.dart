import 'package:agendai_ufsm/models/Model.dart';
import 'package:agendai_ufsm/models/RuScheduleConfiguration.dart';

class WorkmanagerController {
  static Future<void> callable(task, inputData) async {
    print('callable');

    var ru =
        Model.singletonFromFile<RuScheduleConfiguration>('scheduleConfig.json');
    print(ru);
    print(task);
  }
}
