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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text('Ola mundo')],));
  }
}
