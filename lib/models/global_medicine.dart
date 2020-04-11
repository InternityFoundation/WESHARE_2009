import 'package:cloud_firestore/cloud_firestore.dart';

class GlobalMedicine {
  final String name, category, ID;
  final bool prescription_required;
  GlobalMedicine(
      {this.ID, this.name, this.category, this.prescription_required});
}

class GlobalMedicineService {
  List<GlobalMedicine> _globalmedicineFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return GlobalMedicine(
        name: doc.data['name'] ?? '',
        category: doc.data['category'] ?? '',
        ID: doc.documentID,
        prescription_required: doc.data['prescription_required'] ?? false,
      );
    }).toList();
  }

  Stream<List<GlobalMedicine>> get globalMedicine {
    return Firestore.instance
        .collection('global_medicine')
        .snapshots()
        .map(_globalmedicineFromSnapshot);
  }
}
