import 'package:agendai_ufsm/controllers/AppController.dart';
import 'package:agendai_ufsm/pages/ExempleTesseractPage.dart';
import 'package:agendai_ufsm/pages/LoginPage.dart';
import 'package:agendai_ufsm/pages/MyHomePage.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: AppController.instance,
        builder: (context, child) {
          return MaterialApp(
              title: 'Titulo ola mundo',
              theme: ThemeData(
                  primarySwatch: Colors.blueGrey,
                  brightness: AppController.instance.isDarkTheme
                      ? Brightness.dark
                      : Brightness.light),
              home: LoginPage());
            //home: ExempleTesseractPage(title: "Ola mundo"));
        });
  }
}
