import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
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
                                  visible: (med.seller_email != user.email &&
                                      med.isSold == false),
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
                                            'Total distance (Approx.): tap to reveal',
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

                StreamBuilder(
                    stream:
                        BoughtMedicineService(email: user.email).boughtMedicine,
                    builder: (context, snapshot) {
                      List<BoughtMedicine> boughtMeds = snapshot.data;

                      if (boughtMeds.length == 0) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 68.0),
                            child: Text(
                              'You have not purchased anything',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        );
                      }

                      return LimitedBox(
                        maxHeight: MediaQuery.of(context).size.height * 0.8,
                        child: ListView.builder(
                          itemCount: boughtMeds.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 26,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                            '${boughtMeds[index].med_name}',
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
                                        child: Container(
                                          width: 210,
                                          child: Text(
                                            'Seller email: ${boughtMeds[index].seller_email}',
                                            softWrap: true,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          'Medicines Quantitiy: ${boughtMeds[index].med_qty}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Text(
                                          'Total Price: ${boughtMeds[index].med_price}',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                      MaterialButton(
                                        child: Text(
                                          'Go to Seller',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        color: Colors.brown[700],
                                        onPressed: () {
                                          openMapsSheet(
                                              context,
                                              boughtMeds[index]
                                                  .seller_location);
                                        },
                                      )
                                    ],
                                  ),
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

  openMapsSheet(context, GeoPoint point) async {
    try {
      final title = "Seller House";
      final des = "";
      final coords = Coords(point.latitude, point.longitude);
      final availableMaps = await MapLauncher.installedMaps;

      print(availableMaps);

      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                child: Wrap(
                  children: <Widget>[
                    for (var map in availableMaps)
                      ListTile(
                        onTap: () => map.showMarker(
                            coords: coords, title: title, description: des),
                        title: Text(map.mapName),
                        leading: Image(
                          image: map.icon,
                          height: 30.0,
                          width: 30.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      print(e);
    }
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

//
}
