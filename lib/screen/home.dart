import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:medishare/components/custom_drawer.dart';
import 'package:medishare/models/global_medicine.dart';
import 'package:medishare/models/sell_medicine.dart';
import 'package:medishare/models/user.dart';
import 'package:medishare/models/user_medicine.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

var maskTextInputFormatter =
    MaskTextInputFormatter(mask: "####-##-##", filter: {"#": RegExp(r'[0-9]')});
var format_notime = new DateFormat('yyyy.MM.dd');

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    List<GlobalMedicine> globalmedicine =
        Provider.of<List<GlobalMedicine>>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('DashBoard'),
          centerTitle: true,
        ),
        drawer: CustomDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //----------------------------MEDICINE SEARCH -----------------------------------------

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Your Medicines',
                      style: TextStyle(fontSize: 20, letterSpacing: 1),
                    ),
                    RaisedButton(
                      color: Colors.brown,
                      child: Text(
                        'Add Medicine',
                        style: TextStyle(
                            fontSize: 16,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w400),
                      ),
                      onPressed: () async {
                        showSearch(
                          context: context,
                          delegate: SearchPage<GlobalMedicine>(
                              items: globalmedicine,
                              searchLabel: 'Search Medicine',
                              suggestion: Center(
                                child: Text(
                                  'Find medicine by name, disease',
                                  style: TextStyle(fontSize: 19),
                                ),
                              ),
                              failure: Center(
                                child: Text('No medicine found :(',
                                    style: TextStyle(fontSize: 19)),
                              ),
                              filter: (med) => [med.name, med.category],
                              builder: (med) => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: () {
                                        print('I am tapped');
                                        Navigator.pop(context);
                                        addMedicinePersonal(
                                            context, med, user.email);
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('Name : ${med.name}'),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Text('Disease: ${med.category}')
                                        ],
                                      ),
                                    ),
                                  )),
                        );
                      },
                    ),
                  ],
                ),

                //----------------------------- MEDICINE LIST----------------------------
                StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .document(user.email)
                        .collection('user_medicine')
                        .snapshots(),
                    builder: (context, snapshot) {
                      List userMeds = snapshot.data.documents;

                      if (userMeds.length == 0) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 68.0),
                            child: Text(
                              'Add your medicines',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      }

                      return LimitedBox(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                        child: ListView.builder(
                          itemCount: userMeds.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 26,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 100,
                                    child: Column(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(1.0),
                                          child: Image(
                                            image: AssetImage(
                                                'images/capsule.png'),
                                            height: 90,
                                            width: 90,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            '${userMeds[index]['name']}',
                                            style: TextStyle(fontSize: 16),
                                            softWrap: true,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          'Daily dose: ${userMeds[index]['per_day']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          'Medicines to eat: ${userMeds[index]['q_prescribed']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          'Extra medicine left : ${userMeds[index]['q_left']}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          'Expiry date : ${format_notime.format(userMeds[index]['exp_date'].toDate())}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
//
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: InkWell(
                                          onTap: () async {
                                            if (userMeds[index]
                                                    ['q_prescribed'] >
                                                0)
                                              await Firestore.instance
                                                  .collection('users')
                                                  .document(user.email)
                                                  .collection('user_medicine')
                                                  .document(userMeds[index]
                                                      .documentID)
                                                  .updateData({
                                                'q_prescribed':
                                                    FieldValue.increment(-1)
                                              });
                                            else
                                              Fluttertoast.showToast(
                                                  msg:
                                                      'Your medicines are over');
                                          },
                                          child: Icon(
                                            Icons.done_outline,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: InkWell(
                                          onTap: () {
                                            UserMedicineService(
                                                    email: user.email)
                                                .deleteUserMedicine(
                                                    userMeds[index].documentID);
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: InkWell(
                                          onTap: () async {
                                            await addMedicineSell(
                                                context, userMeds[index], user);
                                          },
                                          child: Icon(
                                            Icons.share,
                                            size: 30,
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //--------------------------ADD SELL MED----------------------------------

  addMedicineSell(context, DocumentSnapshot med, User user) {
    TextEditingController medqty = TextEditingController();
    TextEditingController medprice = TextEditingController();

    TextEditingController expdate = TextEditingController();

    var key = GlobalKey<FormState>();

    Alert(
        context: context,
        title: "SELL",
        content: Form(
          key: key,
          child: Column(
            children: <Widget>[
              Text(
                'Medicine Name: ' + med['name'],
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                controller: medprice,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v.isEmpty) return 'Can not be empty';
                  return null;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.arrow_forward_ios),
                  labelText: 'Medicine price',
                ),
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              if (key.currentState.validate()) {
//                DateTime date = DateTime.parse(expdate.text);
//                Timestamp datet = Timestamp.fromDate(date);

                Position pos = await Geolocator().getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.bestForNavigation);

                if (pos == null) {
                  Permission.location.request();
                  Fluttertoast.showToast(
                      msg: 'Give location permission/enable location');
                }

                GeoPoint point = GeoPoint(pos.latitude, pos.longitude);
                await SellMedicineService().addSellMedicine(SellMedicine(
                    med_name: med['name'],
                    isSold: false,
                    exp_date: med['exp_date'],
                    seller_email: user.email,
                    seller_address: null,
                    med_price: int.parse(medprice.text),
                    med_qty: med['q_left'],
                    seller_name: user.name,
                    seller_location: point));

                print('updated');
                Navigator.pop(context);
                Fluttertoast.showToast(msg: 'Medicine marked for sale');
              }
            },
            child: Text(
              "SELL",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  //-----------------------------------------------ADD MEDICINE DIALOGUE-------------------------------

  addMedicinePersonal(context, GlobalMedicine med, String email) {
    TextEditingController qtyAvailable = TextEditingController();
    TextEditingController perday = TextEditingController();

    TextEditingController numberofdays = TextEditingController();

    TextEditingController expdate = TextEditingController();

    var key = GlobalKey<FormState>();

    Alert(
        context: context,
        title: "ADD",
        content: Form(
          key: key,
          child: Column(
            children: <Widget>[
              Text(
                'Medicine Name: ' + med.name,
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: qtyAvailable,
                validator: (v) {
                  if (v.isEmpty) return 'Can not be empty';
                  return null;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.arrow_forward_ios),
                  labelText: 'Quantity Available',
                ),
              ),
              TextFormField(
                controller: perday,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v.isEmpty) return 'Can not be empty';
                  return null;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.arrow_forward_ios),
                  labelText: 'Medicine per day',
                ),
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: numberofdays,
                validator: (v) {
                  if (v.isEmpty) return 'Can not be empty';
                  return null;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.arrow_forward_ios),
                  labelText: 'Medication Period(days)',
                ),
              ),
              TextFormField(
                controller: expdate,
                inputFormatters: [maskTextInputFormatter],
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v.isEmpty) return 'Can not be empty';
                  return null;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.arrow_forward_ios),
                  labelText: 'Expiry Date',
                  hintText: 'YYYY-MM-DD',
                ),
              ),
            ],
          ),
        ),
        buttons: [
          DialogButton(
            onPressed: () async {
              if (key.currentState.validate()) {
                DateTime date = DateTime.parse(expdate.text);
//                print(date.toString());
                Timestamp datet = Timestamp.fromDate(date);
                int q_left = int.parse(qtyAvailable.text) -
                    (int.parse(perday.text) * int.parse(numberofdays.text));
                if (q_left < 0) {
                  Fluttertoast.showToast(msg: 'Enter valid quantity');
                  return;
                }
                await UserMedicineService(email: email).addUserMedicine(
                    UserMedicine(
                        email: email,
                        name: med.name,
                        category: med.category,
                        exp_date: datet,
                        per_day: int.parse(perday.text),
                        period_to_eat: int.parse(numberofdays.text),
                        q_prescribed: int.parse(perday.text) *
                            int.parse(numberofdays.text),
                        q_purchased: int.parse(qtyAvailable.text),
                        q_left: q_left));

                print('updated');
                Navigator.pop(context);
              }
            },
            child: Text(
              "ADD",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }
}
