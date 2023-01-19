import 'package:agendai_ufsm/controllers/RuController.dart';
import 'package:agendai_ufsm/models/Model.dart';
import 'package:intl/intl.dart';

class RuSchedule extends Model {
  String data;
  TipoRefeicao refeicao;
  RestauranteUFSM restaurante;
  bool vegetariano;

  RuSchedule()
      : data = DateFormat("dd/MM/yyyy").format(DateTime.now()),
        refeicao = TipoRefeicao.almoco,
        restaurante = RestauranteUFSM.ru1,
        vegetariano = false;

  @override
  void fromJson(Map<String, dynamic> data) {
    data = data['data'];
    refeicao = TipoRefeicao.values[data['tipoRefeicao']];
    restaurante = RestauranteUFSM.values[data['restaurante']];
    vegetariano = data['vegetariano'];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'tipoRefeicao': refeicao.index,
      'restaurante': restaurante.index,
      'vegetariano': vegetariano
    };
  }
}
