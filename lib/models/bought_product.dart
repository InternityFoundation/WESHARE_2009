import 'package:cloud_firestore/cloud_firestore.dart';

class BoughtMedicine {
  final String buyer_email, ID, seller_email, med_name;
  final int med_qty, med_price;
  final GeoPoint seller_location;

  BoughtMedicine(
      {this.ID,
      this.seller_location,
      this.med_qty,
      this.seller_email,
      this.med_name,
      this.buyer_email,
      this.med_price});
}

class BoughtMedicineService {
  final String email;
  BoughtMedicineService({this.email});

  Firestore _firestore = Firestore.instance;
  String ref = 'users';
  String ref1 = 'bought_medicine';

  void addBoughtMedicine(BoughtMedicine boughtMedicine) async {
    await _firestore.collection(ref).document(email).collection(ref1).add({
      'email': email,
      'buyer_email': boughtMedicine.buyer_email,
      'seller_email': boughtMedicine.seller_email,
      'med_name': boughtMedicine.med_name,
      'med_qty': boughtMedicine.med_qty,
      'med_price': boughtMedicine.med_price,
      'seller_location': boughtMedicine.seller_location,
    });
  }

  List<BoughtMedicine> _boughtFromSnap(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return BoughtMedicine(
        ID: doc.documentID,
        buyer_email: doc.data['buyer_email'] ?? '',
        seller_email: doc.data['seller_email'] ?? '',
        med_name: doc.data['med_name'] ?? '',
        med_qty: doc.data['med_qty'] ?? 0,
        med_price: doc.data['med_price'] ?? 0,
        seller_location: doc.data['seller_location'] ?? '',
      );
    }).toList();
  }

  Stream<List<BoughtMedicine>> get userMedicine {
    return _firestore
        .collection(ref)
        .document(email)
        .collection(ref1)
        .snapshots()
        .map(_boughtFromSnap);
  }
}
