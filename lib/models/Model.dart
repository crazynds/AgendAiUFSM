import 'package:agendai_ufsm/controllers/FileController.dart';
import 'package:agendai_ufsm/models/RuScheduleConfiguration.dart';

abstract class Model {
  static final Map _instaces = {};

  Map<String, dynamic> toJson();
  static T fromJson<T extends Model>(Map<String, dynamic> json) {
    switch (T) {
      case RuScheduleConfiguration:
        return RuScheduleConfiguration.fromJson(json) as T;
      default:
        throw UnimplementedError();
    }
  }

  static T singletonFromFile<T extends Model>(String fileName) {
    if (!_instaces.containsKey(T)) {
      Map<String, dynamic> data = FileController.read(fileName);
      _instaces[T] = Model.fromJson<T>(data);
    }
    return _instaces[T];
  }

  void saveInFile(String fileName) {
    FileController.write(fileName, this);
  }
}
