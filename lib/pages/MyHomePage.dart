import 'package:agendai_ufsm/AppController.dart';
import 'package:agendai_ufsm/components/DarkSwitch.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [DarkSwitch()],
        ),
        body: Container(
            height: double.infinity,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  color: AppController.instance.isDarkTheme
                      ? Colors.white
                      : Colors.black,
                ),
                DarkSwitch(),
                Text(
                  "Ola mundo",
                  style: TextStyle(fontSize: 15),
                )
              ],
            )));
  }
}
