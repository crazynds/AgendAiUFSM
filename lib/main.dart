import 'package:agendai_ufsm/MyApp.dart';
import 'package:agendai_ufsm/controllers/FileController.dart';
import 'package:agendai_ufsm/controllers/OCRController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:workmanager/workmanager.dart';

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print(task);

    await OCRController.instance.fixRecycle();
    print('Fix corrigido');
    return true;
  });
}

void main() async {
  await dotenv.load(fileName: ".env");
  await FileController.loadDirectory();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    return const MyApp();
  }
}
