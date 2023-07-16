import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_task_manager/screens/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // status bar color to transparent
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    return const MaterialApp(
      title: 'Task Manager',
      home: WidgetTree(),
    );
  }
}
