import 'package:agendai_ufsm/controllers/AppController.dart';
import 'package:flutter/material.dart';

class DarkSwitch extends StatelessWidget {
  const DarkSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: AppController.instance.isDarkTheme,
      onChanged: (value) {
        AppController.instance.changeTheme();
      },
    );
  }
}
