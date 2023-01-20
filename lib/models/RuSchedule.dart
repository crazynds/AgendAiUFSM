import 'package:agendai_ufsm/controllers/RuController.dart';
import 'package:agendai_ufsm/models/Model.dart';
import 'package:intl/intl.dart';

class RuSchedule extends Model {
  DateTime data;
  TipoRefeicao refeicao;
  RestauranteUFSM restaurante;
  bool vegetariano;

  RuSchedule({
    required this.data,
    required this.refeicao,
    required this.restaurante,
    required this.vegetariano,
  });

  @override
  factory RuSchedule.fromJson(Map<String, dynamic> data) => RuSchedule(
      data: DateFormat('dd/MM/yyyy').parse(
          data['data'] ?? DateFormat('dd/MM/yyyy').format(DateTime.now())),
      refeicao: TipoRefeicao.values[data['tipoRefeicao'] ?? 0],
      restaurante: RestauranteUFSM.values[data['restaurante'] ?? 0],
      vegetariano: data['vegetariano'] as bool? ?? false);

  @override
  Map<String, dynamic> toJson() {
    return {
      'data': DateFormat('dd/MM/yyyy').format(data),
      'tipoRefeicao': refeicao.index,
      'restaurante': restaurante.index,
      'vegetariano': vegetariano
    };
  }
}
