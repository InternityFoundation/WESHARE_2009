import 'package:flutter/material.dart';
import 'package:medishare/models/user.dart';
import 'package:medishare/screen/home.dart';
import 'package:medishare/screen/welcome_screen.dart';
import 'package:provider/provider.dart';

class EntryWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    if (user == null) {
      return WelcomeScreen();
    } else {
      return MainScreen();
    }
  }
}
