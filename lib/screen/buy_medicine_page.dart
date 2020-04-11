import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:medishare/models/bought_product.dart';
import 'package:medishare/models/global_medicine.dart';
import 'package:medishare/models/sell_medicine.dart';
import 'package:medishare/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medishare/screen/medicine_bought_page.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

Geoflutterfire geo = Geoflutterfire();
var maskTextInputFormatter =
    MaskTextInputFormatter(mask: "####-##-##", filter: {"#": RegExp(r'[0-9]')});
var format_notime = new DateFormat('yyyy.MM.dd');

class BuyMedicinePage extends StatefulWidget {
  @override
  _BuyMedicinePageState createState() => _BuyMedicinePageState();
}

class _BuyMedicinePageState extends State<BuyMedicinePage> {
  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    List<SellMedicine> sellmedicine = Provider.of<List<SellMedicine>>(context);

    List<GlobalMedicine> globalmedicine =
        Provider.of<List<GlobalMedicine>>(context);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff191919),
          title: Text('Buy Medicine'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                //----------------------------MEDICINE SEARCH -----------------------------------------

                Center(
                  child: RaisedButton(
                    color: Colors.brown[600],
                    child: Text(
                      'Search Medicine',
                      style: TextStyle(
                          fontSize: 16,
                          letterSpacing: 1,
                          fontWeight: FontWeight.w400),
                    ),
                    onPressed: () async {
                      showSearch(
                        context: context,
                        delegate: SearchPage<SellMedicine>(
                            items: sellmedicine,
                            searchLabel: 'Search Medicine',
                            suggestion: Center(
                              child: Text(
                                'Find medicine by name, disease',
                                style: TextStyle(fontSize: 19),
                              ),
                            ),
                            failure: Center(
                              child: Text('None are currently selling this :(',
                                  style: TextStyle(fontSize: 19)),
                            ),
                            filter: (med) => [med.med_name, med.med_category],
                            builder: (med) => Visibility(
                                  visible: med.seller_email != user.email,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
//                                        Text(
//                                          'seller : ${med.seller_email}',
//                                          style: TextStyle(fontSize: 18),
//                                        ),
//                                        SizedBox(
//                                          height: 4,
//                                        ), //-------------------------------------------------
                                        Text(
                                          'Name : ${med.med_name}',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Disease: ${med.med_category}',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Total price: ${med.med_price}',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          'Total quantitiy: ${med.med_qty}',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            double di =
                                                await getCurrentDistance(
                                                    med.seller_location);
                                            print('${di} KM');
                                            Alert(
                                                    context: context,
                                                    title: "DISTANCE",
                                                    desc:
                                                        "${di.toStringAsFixed(2)} KM")
                                                .show();

//                                            print(x);
                                          },
                                          child: Text(
                                            'Total distance: tap to reveal',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white)),
                                          child: InkWell(
                                            onTap: () {
                                              Alert(
                                                context: context,
                                                title: "UPLOAD PRESCRIPTION",
                                                desc:
                                                    "Upload prescription of medicine to continue",
                                                buttons: [
                                                  DialogButton(
                                                    child: Text(
                                                      "TAKE PICTURE",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15),
                                                    ),
                                                    onPressed: () async {
//                                                      Navigator.pop(context);
                                                      await getImage();
                                                      if (_image == null) {
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                'Upload prescription');
                                                        return;
                                                      }
                                                      Navigator.pop(context);
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MedicineBoughtPage(
                                                                    med: med,
                                                                  )));
                                                      print('done');
                                                    },
                                                    width: 120,
                                                  )
                                                ],
                                              ).show();
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                'BUY',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    letterSpacing: 1.5,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Divider(
                                          thickness: 1.5,
                                        )
                                      ],
                                    ),
                                  ),
                                )),
                      );
                    },
                  ),
                ),

//-----------------------------BOUGHT MEDICINE LIST----------------------------

//                LimitedBox(
//                  maxHeight: MediaQuery.of(context).size.height * 0.8,
//                  child: ListView.builder(
//                    itemCount: sellmedicine.length,
//                    itemBuilder: (context, index) {
//                      if (sellmedicine.length == 0)
//                        return Center(
//                          child: Text('You are not selling anything'),
//                        );
//                      return Card(
//                        color: Color(0xff191919),
//                        elevation: 26,
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                          crossAxisAlignment: CrossAxisAlignment.start,
//                          children: <Widget>[
//                            Container(
//                              width: 100,
//                              child: Column(
//                                children: <Widget>[
//                                  Padding(
//                                    padding: const EdgeInsets.all(1.0),
//                                    child: Image(
//                                      image: AssetImage('images/capsule.png'),
//                                      height: 90,
//                                      width: 90,
//                                      fit: BoxFit.cover,
//                                    ),
//                                  ),
//                                  Padding(
//                                    padding: const EdgeInsets.all(4.0),
//                                    child: Text(
//                                      '${sellmedicine[index].med_name}',
//                                      style: TextStyle(fontSize: 16),
//                                      softWrap: true,
//                                    ),
//                                  )
//                                ],
//                              ),
//                            ),
//                            Column(
//                              mainAxisSize: MainAxisSize.max,
//                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: <Widget>[
//                                Padding(
//                                  padding: const EdgeInsets.all(4.0),
//                                  child: Text(
//                                    'Quantity available: ${sellmedicine[index].med_qty}',
//                                    style: TextStyle(fontSize: 16),
//                                  ),
//                                ),
//                                Padding(
//                                  padding: const EdgeInsets.all(4.0),
//                                  child: Text(
//                                    'Total Price: ${sellmedicine[index].med_price}',
//                                    style: TextStyle(fontSize: 16),
//                                  ),
//                                ),
//
//                                Padding(
//                                  padding: const EdgeInsets.all(4.0),
//                                  child: Text(
//                                    'Expiry date : ${format_notime.format(sellmedicine[index].exp_date.toDate())}',
//                                    style: TextStyle(fontSize: 16),
//                                  ),
//                                ),
////
//                              ],
//                            ),
//                            Column(
//                              mainAxisSize: MainAxisSize.max,
//                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                              children: <Widget>[
//                                Padding(
//                                  padding: const EdgeInsets.all(4.0),
//                                  child: InkWell(
//                                    onTap: () {
//                                      SellMedicineService().deleteSellMedicine(
//                                          sellmedicine[index].ID);
//                                    },
//                                    child: Icon(
//                                      Icons.delete,
//                                      size: 30,
//                                    ),
//                                  ),
//                                ),
//                              ],
//                            )
//                          ],
//                        ),
//                      );
//                    },
//                  ),
//                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  getCurrentDistance(GeoPoint geoPoint) async {
    Position pos = await Geolocator().getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation);

    if (pos == null) {
      Permission.location.request();
      Fluttertoast.showToast(msg: 'Give location permission/enable location');
    }

    double distanceInMeters = await Geolocator().distanceBetween(
        pos.latitude, pos.longitude, geoPoint.latitude, geoPoint.longitude);

    return distanceInMeters * 0.001;
  }

  //-----------------------------------------------ADD MEDICINE DIALOGUE-------------------------------

  addMedicineSell(context, GlobalMedicine med, User user) {
    TextEditingController medqty = TextEditingController();
    TextEditingController medprice = TextEditingController();

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
                controller: medqty,
                validator: (v) {
                  if (v.isEmpty) return 'Can not be empty';
                  return null;
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.arrow_forward_ios),
                  labelText: 'Quantity Available For Sale',
                ),
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
                Timestamp datet = Timestamp.fromDate(date);

                Position pos = await Geolocator().getCurrentPosition(
                    desiredAccuracy: LocationAccuracy.bestForNavigation);

                if (pos == null) {
                  Permission.location.request();
                  Fluttertoast.showToast(
                      msg: 'Give location permission/enable location');
                }

                GeoPoint point = GeoPoint(pos.latitude, pos.longitude);
                await SellMedicineService().addSellMedicine(
                  SellMedicine(
                      med_name: med.name,
                      med_category: med.category,
                      isSold: false,
                      exp_date: datet,
                      seller_email: user.email,
                      seller_address: null,
                      med_price: int.parse(medprice.text),
                      med_qty: int.parse(medqty.text),
                      seller_name: user.name,
                      seller_location: point),
                );

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
