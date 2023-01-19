import 'package:agendai_ufsm/models/Model.dart';
import 'package:agendai_ufsm/models/RuSchedule.dart';

class History extends Model {
  List<RuSchedule> lastScheduleMade = <RuSchedule>[];
  List<RuSchedule> nextScheduleToMake = <RuSchedule>[];

  @override
  void fromJson(Map<String, dynamic> data) {
    List<Map<String, dynamic>> arr = data['lastScheduleMade'];

    for (var mp in arr) {
      RuSchedule v = RuSchedule();
      v.fromJson(mp);
      lastScheduleMade.add(v);
    }
    arr = data['nextScheduleToMake'];

    for (var mp in arr) {
      RuSchedule v = RuSchedule();
      v.fromJson(mp);
      nextScheduleToMake.add(v);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'lastScheduleMade': lastScheduleMade,
      'nextScheduleToMake': nextScheduleToMake
    };
  }
}
