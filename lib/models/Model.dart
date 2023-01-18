import 'package:agendai_ufsm/controllers/FileController.dart';

abstract class Model {
  Map<String, dynamic> toJson();
  void fromJson(Map<String, dynamic> data);
}
