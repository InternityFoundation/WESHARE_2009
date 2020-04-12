import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire/geoflutterfire.dart';

class SellMedicine {
  final String med_name,
      seller_name,
      ID,
      seller_address,
      seller_email,
      med_category;
  final int med_qty, med_price;
  final GeoPoint seller_location;
  final Timestamp exp_date;
  final bool isSold;
  SellMedicine(
      {this.med_name,
      this.isSold,
      @required this.med_category,
      this.exp_date,
      this.ID,
      this.seller_email,
      this.med_price,
      this.med_qty,
      this.seller_address,
      this.seller_location,
      this.seller_name});
}

class SellMedicineService {
  void addSellMedicine(SellMedicine sellMedicine) async {
    await Firestore.instance.collection('sell_medicine').add({
      'med_name': sellMedicine.med_name,
      'isSold': sellMedicine.isSold,
      'exp_date': sellMedicine.exp_date,
      'med_category': sellMedicine.med_category,
      'seller_email': sellMedicine.seller_email,
      'med_price': sellMedicine.med_price,
      'med_qty': sellMedicine.med_qty,
      'med_qty': sellMedicine.med_qty,
      'seller_address': sellMedicine.seller_address,
      'seller_location': sellMedicine.seller_location,
      'seller_name': sellMedicine.seller_name
    });
  }

  void deleteSellMedicine(String id) async {
    await Firestore.instance.collection('sell_medicine').document(id).delete();
  }

  void updateisSold(String id) async {
    await Firestore.instance
        .collection('sell_medicine')
        .document(id)
        .updateData({'isSold': true});
  }

  List<SellMedicine> _sellMedicinefromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return SellMedicine(
        med_category: doc.data['med_category'],
        ID: doc.documentID,
        exp_date: doc.data['exp_date'],
        med_name: doc.data['med_name'] ?? '',
        isSold: doc.data['isSold'] ?? false,
        seller_email: doc.data['seller_email'] ?? '',
        med_price: doc.data['med_price'] ?? 0,
        med_qty: doc.data['med_qty'] ?? 0,
        seller_address: doc.data['seller_address'] ?? '',
        seller_location: doc.data['seller_location'] ?? '',
        seller_name: doc.data['seller_name'] ?? '',
      );
    }).toList();
  }

  Stream<List<SellMedicine>> get sellMedicine {
    return Firestore.instance
        .collection('sell_medicine')
        .snapshots()
        .map(_sellMedicinefromSnapshot);
  }
}
