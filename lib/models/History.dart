import 'package:agendai_ufsm/models/Model.dart';
import 'package:agendai_ufsm/models/RuSchedule.dart';
import 'package:intl/intl.dart';

class History extends Model {
  static const String _fileName = 'history.json';
  List<RuSchedule> lastScheduleMade = <RuSchedule>[];
  List<RuSchedule> nextScheduleToMake = <RuSchedule>[];
  DateTime? lastDayExecuted;
  bool stopped = false;

  History(
      {required this.lastScheduleMade,
      required this.nextScheduleToMake,
      required this.stopped,
      lastDayExecuted});

  void clear() {
    lastScheduleMade.clear();
    nextScheduleToMake.clear();
    lastDayExecuted = DateTime.now();
  }

  @override
  factory History.fromJson(Map<String, dynamic> data) => History(
      lastScheduleMade: (data['lastScheduleMade'] as List<dynamic>? ?? [])
          .map((v) => RuSchedule.fromJson(v))
          .toList(),
      nextScheduleToMake: (data['nextScheduleToMake'] as List<dynamic>? ?? [])
          .map((v) => RuSchedule.fromJson(v))
          .toList(),
      stopped: data['stopped'] as bool? ?? true,
      lastDayExecuted: (data['lastDayExecuted'] != null)
          ? DateFormat("dd/MM/yyyy").parse(data['lastDayExecuted'])
          : null);

  @override
  Map<String, dynamic> toJson() {
    return {
      'lastScheduleMade': lastScheduleMade,
      'nextScheduleToMake': nextScheduleToMake,
      'stopped': stopped,
      'lastDayExecuted': (lastDayExecuted != null)
          ? DateFormat("dd/MM/yyyy").format(lastDayExecuted!)
          : null
    };
  }

  static History load() {
    return Model.singletonFromFile<History>(_fileName);
  }

  void save() {
    saveInFile(_fileName);
  }
}
