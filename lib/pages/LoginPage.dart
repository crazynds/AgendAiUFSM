import 'dart:io';

import 'package:agendai_ufsm/controllers/AppController.dart';
import 'package:agendai_ufsm/controllers/RuController.dart';
import 'package:agendai_ufsm/models/User.dart';
import 'package:agendai_ufsm/pages/MyHomePage.dart';
import 'package:agendai_ufsm/pages/TermosPage.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginPage extends StatefulWidget {
  LoginPage();

  @override
  State<LoginPage> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _matricula = dotenv.env['DEFAULT_MATRICULA'] as String;
  String _senha = dotenv.env['DEFAULT_PASSWORD'] as String;

  bool _isNumeric(String s) {
    return int.parse(
          s,
          onError: (source) => -1,
        ) !=
        -1;
  }

  String? _matriculaValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Digite alguma matricula';
    }
    if (!_isNumeric(value)) {
      return 'A matricula deve ser válida';
    }
    return null;
  }

  String? _senhaValidator(value) {
    if (value == null || value.isEmpty) {
      return 'Digite alguma senha';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                  height: 5,
                  child: Visibility(
                    visible: AppController.instance.isLoading,
                    child: LinearProgressIndicator(),
                  )),
              Form(
                key: _formKey,
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            height: 90,
                            child: TextFormField(
                              onChanged: (value) {
                                _matricula = value;
                              },
                              initialValue: _matricula,
                              decoration: InputDecoration(
                                  labelText: 'Matricula',
                                  border: OutlineInputBorder()),
                              validator: _matriculaValidator,
                            )),
                        SizedBox(
                            height: 100,
                            child: TextFormField(
                              onChanged: (value) {
                                _senha = value;
                              },
                              initialValue: _matricula,
                              decoration: InputDecoration(
                                  labelText: 'Senha',
                                  border: OutlineInputBorder()),
                              validator: _senhaValidator,
                              obscureText: true,
                            )),
                        ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                AppController.instance.setLoading(true);
                                User user = User.load();
                                user.code = _matricula;
                                user.password = _senha;
                                RuController.auth(user).then((value) {
                                  var bar;
                                  if (value != null) {
                                    bar = SnackBar(
                                        content: Text('Login com sucesso'));
                                    Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                MyHomePage(title: value.name)));
                                  } else {
                                    bar = SnackBar(
                                        content: Text('Não feito login'));
                                  }
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(bar);
                                  AppController.instance.setLoading(false);
                                });
                              }
                            },
                            child: Text('Entrar')),
                        ElevatedButton(
                            onPressed: () {
                              Workmanager().cancelByUniqueName("agendar-ru");
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Agendamento automático desativo')));
                            },
                            child: Text('Desativar agendamento automático')),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => TermosPage()));
                            },
                            child: Text('Entenda como funciona!')),
                      ]),
                ),
              ),
            ],
          )),
    );
  }
}
