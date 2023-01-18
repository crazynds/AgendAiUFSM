import 'package:agendai_ufsm/components/DarkSwitch.dart';
import 'package:agendai_ufsm/controllers/AppController.dart';
import 'package:agendai_ufsm/controllers/RuController.dart';
import 'package:agendai_ufsm/models/RuScheduleConfiguration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _cafe, _almoco, _janta;
  RestauranteUFSM _restauranteUfsm;
  List<bool> _diasDaSemana;

  TextEditingController _dateController;

  _MyHomePageState()
      : _almoco = true,
        _cafe = false,
        _janta = false,
        _restauranteUfsm = RestauranteUFSM.ru1,
        _diasDaSemana = [false, true, true, true, true, true, false],
        _dateController = TextEditingController() {
    final ruConfig = RuScheduleConfiguration.load();
    _almoco = ruConfig.almoco;
    _cafe = ruConfig.cafe;
    _janta = ruConfig.janta;
    _restauranteUfsm = ruConfig.local;
    _diasDaSemana = List<bool>.from(ruConfig.dayOfWeeks);
    _dateController.text =
        DateFormat("dd/MM/yyyy").format(ruConfig.fimSchedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [DarkSwitch()],
      ),
      body: Center(
        child: Container(
            height: double.infinity,
            width: MediaQuery.of(context).size.width * 0.80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //todo
                    Text(
                      "Agendar até:",
                      style: TextStyle(fontSize: 18, letterSpacing: 2),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 8, bottom: 8, left: 10, right: 10),
                        child: TextField(
                            controller: _dateController,
                            readOnly: true,
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now().add(
                                      Duration(days: 1)), //get today's date
                                  firstDate: DateTime.now().add(Duration(
                                      days:
                                          1)), //DateTime.now() - not to allow to choose before today.
                                  lastDate:
                                      DateTime.now().add(Duration(days: 180)));
                              if (pickedDate != null) {
                                String formattedDate =
                                    DateFormat('dd/MM/yyyy').format(pickedDate);
                                setState(() {
                                  if (formattedDate == null) return;
                                  _dateController.text = formattedDate;
                                });
                              }
                            },
                            decoration: InputDecoration(
                                icon: Icon(
                                    Icons.calendar_today), //icon of text field
                                labelText: "Enter Date" //label text of field
                                ))),
                    //todo
                    Text(
                      "Refeiçoes:",
                      style: TextStyle(fontSize: 18, letterSpacing: 2),
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: _cafe,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _cafe = value;
                              });
                            }),
                        Text("Café")
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _almoco,
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _almoco = value;
                            });
                          },
                        ),
                        Text("Alomoço")
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                            value: _janta,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _janta = value;
                              });
                            }),
                        Text("Janta")
                      ],
                    ),
                    Text(
                      "Dias da semana:",
                      style: TextStyle(fontSize: 18, letterSpacing: 2),
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
                            Text("Seg"),
                            Checkbox(
                                value: _diasDaSemana[1],
                                onChanged: (value) => setState(() {
                                      if (value == null) return;
                                      _diasDaSemana[1] = value;
                                    })),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Ter"),
                            Checkbox(
                                value: _diasDaSemana[2],
                                onChanged: (value) => setState(() {
                                      if (value == null) return;
                                      _diasDaSemana[2] = value;
                                    })),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Qua"),
                            Checkbox(
                                value: _diasDaSemana[3],
                                onChanged: (value) => setState(() {
                                      if (value == null) return;
                                      _diasDaSemana[3] = value;
                                    })),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Qui"),
                            Checkbox(
                                value: _diasDaSemana[4],
                                onChanged: (value) => setState(() {
                                      if (value == null) return;
                                      _diasDaSemana[4] = value;
                                    })),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Sex"),
                            Checkbox(
                                value: _diasDaSemana[5],
                                onChanged: (value) => setState(() {
                                      if (value == null) return;
                                      _diasDaSemana[5] = value;
                                    })),
                          ],
                        ),
                        Column(
                          children: [
                            Text("Sab"),
                            Checkbox(
                                value: _diasDaSemana[6],
                                onChanged: (value) => setState(() {
                                      if (value == null) return;
                                      _diasDaSemana[6] = value;
                                    })),
                          ],
                        ),
                      ],
                    ),
                    // todo
                    Text(
                      "Restaurante:",
                      style: TextStyle(fontSize: 18, letterSpacing: 2),
                    ),
                    Row(
                      children: [
                        Radio<RestauranteUFSM>(
                          groupValue: _restauranteUfsm,
                          value: RestauranteUFSM.ru1,
                          onChanged: (RestauranteUFSM? restaurante) {
                            if (restaurante == null) return;
                            setState(() {
                              _restauranteUfsm = restaurante;
                            });
                          },
                        ),
                        Text("RU 1 - Campus SM")
                      ],
                    ),
                    Row(
                      children: [
                        Radio<RestauranteUFSM>(
                          groupValue: _restauranteUfsm,
                          value: RestauranteUFSM.ru2,
                          onChanged: (RestauranteUFSM? restaurante) {
                            if (restaurante == null) return;
                            setState(() {
                              _restauranteUfsm = restaurante;
                            });
                          },
                        ),
                        Text("RU 2 - Campus SM")
                      ],
                    ),
                    Row(
                      children: [
                        Radio<RestauranteUFSM>(
                          groupValue: _restauranteUfsm,
                          value: RestauranteUFSM.ruPalmeiraDasMissoes,
                          onChanged: (RestauranteUFSM? restaurante) {
                            if (restaurante == null) return;
                            setState(() {
                              _restauranteUfsm = restaurante;
                            });
                          },
                        ),
                        Text("RU - Campus Palmeira D. Missoes")
                      ],
                    ),
                    // todo
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 28.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      var ru = await RuScheduleConfiguration.load();
                      ru.cafe = _cafe;
                      ru.almoco = _almoco;
                      ru.janta = _janta;
                      ru.dayOfWeeks = new List<bool>.from(_diasDaSemana);
                      ru.fimSchedule =
                          DateFormat("dd/MM/yyyy").parse(_dateController.text);
                      ru.local = _restauranteUfsm;
                      ru.save();
                      Workmanager().cancelByUniqueName("agendar-ru");
                      Workmanager().registerPeriodicTask(
                          "agendar-ru", "agendar-ru",
                          frequency: Duration(minutes: 15),
                          initialDelay: Duration(minutes: 1));
                    },
                    child: Text('Iniciar agendamento'),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
