import 'login_register_page.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:flutter_task_manager/screens/home.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Home();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
