import 'package:agendai_ufsm/models/Model.dart';

class User extends Model {
  static final String _fileName = 'user.json';
  String name;
  String code;
  String password;

  User({required this.name, this.code = '', this.password = ''});

  factory User.fromJson(Map<String, dynamic> data) => User(
      name: data['name'] ?? 'No Name',
      code: data['code'] ?? '',
      password: data['password'] ?? '');

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'password': password,
    };
  }

  static User load() {
    return Model.singletonFromFile<User>(_fileName);
  }

  void save() {
    saveInFile(_fileName);
  }
}
