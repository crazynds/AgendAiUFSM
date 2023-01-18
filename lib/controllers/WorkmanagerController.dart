import 'package:agendai_ufsm/models/RuScheduleConfiguration.dart';

class WorkmanagerController {
  static Future<void> callable(task, inputData) async {
    print('callable');

    var ru = RuScheduleConfiguration.load();
    print(ru);
    print(task);
  }
}
