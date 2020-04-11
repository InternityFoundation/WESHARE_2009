import 'package:fluttertoast/fluttertoast.dart';
import 'package:medishare/EntryWrapper.dart';
import 'package:medishare/components/rounded_button.dart';
import 'package:medishare/models/user.dart';
import 'package:medishare/screen/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import '../constants.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'LoginScreen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String email, password;
  final _auth = FirebaseAuth.instance;
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
                      hintText: 'Enter your password')),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Log In',
                colour: Colors.lightBlueAccent,
                onPressed: () async {
                  setState(() {
                    loading = true;
                  });
                  try {
//                    var user = await _auth.signInWithEmailAndPassword(
//                        email: email, password: password);
                    var user = await UserAuthService().signIn(email, password);
                    if (user == true) {
                      Fluttertoast.showToast(msg: 'LoggedIn');

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EntryWrapper()));
                    } else {
                      Fluttertoast.showToast(msg: 'User does not exsist');
                    }
                    setState(() {
                      loading = false;
                    });
                  } catch (e) {
                    print(e);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
