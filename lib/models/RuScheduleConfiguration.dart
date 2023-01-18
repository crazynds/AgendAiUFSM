import 'dart:io';

import 'package:agendai_ufsm/controllers/FileController.dart';
import 'package:agendai_ufsm/controllers/RuController.dart';
import 'package:agendai_ufsm/models/Model.dart';
import 'package:intl/intl.dart';

class RuScheduleConfiguration extends Model {
  static const _fileName = 'scheduler.json';

  List<bool> dayOfWeeks;

  bool cafe, almoco, janta;
  RestauranteUFSM local;

  DateTime fimSchedule;
  static RuScheduleConfiguration? _instance;

  RuScheduleConfiguration()
      : cafe = false,
        almoco = false,
        janta = false,
        local = RestauranteUFSM.ru1,
        fimSchedule = DateTime.now(),
        dayOfWeeks = [false, false, false, false, false, false, false];

  static RuScheduleConfiguration load() {
    if (_instance != null) {
      return _instance as RuScheduleConfiguration;
    }
    RuScheduleConfiguration ru = RuScheduleConfiguration();
    Map<String, dynamic> data = FileController.read(_fileName);

    if (data.isNotEmpty) {
      ru.fromJson(data);
    }
    _instance = ru;
    return ru;
  }

  void save() {
    FileController.write(_fileName, this);
  }

  @override
  void fromJson(Map<String, dynamic> data) {
    almoco = data['almoco'] as bool;
    cafe = data['cafe'] as bool;
    janta = data['janta'] as bool;
    local = RestauranteUFSM.getByCode(data['local'] as int);
    fimSchedule = DateFormat("dd/MM/yyyy").parse(data['fimSchedule'] as String);
    dayOfWeeks = data['dayOfWeeks'] as List<bool>;
  }

  @override
  Map<String, dynamic> toJson() => {
        'cafe': cafe,
        'almoco': almoco,
        'janta': janta,
        'local': local.code,
        'fimSchedule': DateFormat('dd/MM/yyyy').format(fimSchedule),
        'dayOfWeeks': dayOfWeeks
      };
}
