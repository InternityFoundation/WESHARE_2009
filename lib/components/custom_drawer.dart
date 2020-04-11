import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medishare/models/user.dart';
import 'package:medishare/screen/sell_medicine.dart';
import 'package:medishare/screen/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

var _auth = FirebaseAuth.instance;

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Drawer(
      child: ScrollConfiguration(
        behavior: NoScrollGlow(),
        child: ListView(
          children: <Widget>[
            Image(
              image: AssetImage('images/logo.jpeg'),
              width: double.infinity,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 18.0),
              child: Text(
                user.email,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Divider(
              thickness: 1.2,
              color: Colors.white24,
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
//                Navigator.push(
//                    context,
//                    MaterialPageRoute(
//                        builder: (context) => CustomerUpdater(
//                              phno: user.phoneNo,
//                            )));
//                Navigator.pop(context);
              },
              child: ListTile(
                title: Text('My Account'),
                leading: Icon(Icons.person, color: Color(0xff3FC890)),
              ),
            ),
            InkWell(
//              onTap: () {
//                Navigator.pop(context);
//                Navigator.push(context,
//                    MaterialPageRoute(builder: (context) => MyOrders()));
//              },
              child: ListTile(
                title: Text('Buy Medicines'),
                leading: Icon(Icons.shopping_basket, color: Color(0xff3FC890)),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SellMedicine()));
              },
              child: ListTile(
                title: Text('Sell Medicines'),
                leading: Icon(Icons.show_chart, color: Color(0xff3FC890)),
              ),
            ),
            Divider(
              thickness: 1.2,
              color: Colors.white30,
            ),
            InkWell(
              onTap: () async {},
              child: ListTile(
                title: Text('Settings'),
                leading: Icon(
                  Icons.settings,
                  color: Colors.teal[400],
                ),
              ),
            ),
            InkWell(
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                print('kicked');
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => WelcomeScreen()));
              },
              child: ListTile(
                title: Text('Logout'),
                leading: Icon(
                  Icons.exit_to_app,
                  color: Colors.teal[500],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NoScrollGlow extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      ClampingScrollPhysics();
}
