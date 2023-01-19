import 'package:agendai_ufsm/controllers/RuController.dart';
import 'package:agendai_ufsm/models/Model.dart';
import 'package:intl/intl.dart';

class RuScheduleConfiguration extends Model {
  static final String _fileName = 'scheduleConfig.json';
  List<bool> dayOfWeek;

  bool cafe, almoco, janta;
  RestauranteUFSM local;

  DateTime fimSchedule;

  RuScheduleConfiguration(
      {required this.cafe,
      required this.almoco,
      required this.janta,
      required this.local,
      required this.dayOfWeek,
      required this.fimSchedule});

  @override
  factory RuScheduleConfiguration.fromJson(Map<String, dynamic> data) =>
      RuScheduleConfiguration(
          cafe: data['cafe'] ?? false,
          almoco: data['almoco'] ?? false,
          janta: data['janta'] ?? false,
          local: RestauranteUFSM.values[data['restaurante'] ?? 0],
          fimSchedule: DateFormat("dd/MM/yyyy").parse(
              data['fimSchedule'] as String ??
                  DateFormat("dd/MM/yyyy").format(DateTime.now())),
          dayOfWeek: List<bool>.from(data['dayOfWeek'] ??
              [false, false, false, false, false, false, false]));

  @override
  Map<String, dynamic> toJson() => {
        'cafe': cafe,
        'almoco': almoco,
        'janta': janta,
        'restaurante': local.index,
        'fimSchedule': DateFormat('dd/MM/yyyy').format(fimSchedule),
        'dayOfWeek': dayOfWeek
      };

  static RuScheduleConfiguration load() {
    return Model.singletonFromFile<RuScheduleConfiguration>(_fileName);
  }

  void save() {
    saveInFile(_fileName);
  }
}
