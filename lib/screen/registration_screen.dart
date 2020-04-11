import 'package:fluttertoast/fluttertoast.dart';
import 'package:medishare/EntryWrapper.dart';
import 'package:medishare/components/rounded_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medishare/models/user.dart';
import 'package:medishare/screen/home.dart';
import '../constants.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'RegistrationScreen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email, password, name;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: loading,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.jpeg'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    email = value;
                  },
                  style: TextStyle(color: Colors.black),
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your email')),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                },
                style: TextStyle(color: Colors.black),
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                  keyboardType: TextInputType.emailAddress,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    name = value;
                  },
                  style: TextStyle(color: Colors.black),
                  decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter your name')),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                colour: Colors.blueAccent,
                title: 'Register',
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  try {
//                    final newUser = await _auth.createUserWithEmailAndPassword(
//                        email: email, password: password);

                    final newUser =
                        await UserAuthService().signUp(email, password, name);
                    if (newUser == true) {
                      Fluttertoast.showToast(msg: 'User Registered');

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EntryWrapper()));
                    } else {
                      Fluttertoast.showToast(msg: 'SignUp failed');
                    }
                    setState(() {
                      loading = false;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
