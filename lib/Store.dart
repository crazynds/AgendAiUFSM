import 'package:agendai_ufsm/controllers/RuController.dart';
import 'package:agendai_ufsm/models/User.dart';

class Store{

  static final instance = Store();

  String? matricula;
  String? senha;

  Store(){
    load();
  }

  setCredentials(String matricula, String senha){
    this.matricula = matricula;
    this.senha = senha;
    save();
  }


  hasCredentials(){
    return matricula!=null && senha!=null;
  }

  Future<User?> testCredentials(){
    if(!hasCredentials())return Future.value(null);
    return RuController.auth(matricula!, senha!);
  }

  save(){

  }

  load(){

  }


}