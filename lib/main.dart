import 'package:flutter/material.dart';
import 'package:medishare/EntryWrapper.dart';
import 'package:medishare/models/global_medicine.dart';
import 'package:medishare/models/user.dart';
import 'package:medishare/screen/welcome_screen.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<User>.value(value: UserAuthService().user),
        StreamProvider<List<GlobalMedicine>>.value(
            value: GlobalMedicineService().globalMedicine)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Phone Auth',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blueGrey[600],
          accentColor: Colors.deepOrange[200],
        ),
        home: EntryWrapper(),
      ),
    );
  }
}
