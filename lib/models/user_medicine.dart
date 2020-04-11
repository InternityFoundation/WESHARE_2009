import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medishare/models/user.dart';

class UserMedicine {
  final email;
  final ID;
  final name, category;
  final q_purchased, q_prescribed, per_day, period_to_eat, q_left;
  final exp_date;
  UserMedicine(
      {this.ID,
      this.name,
      this.category,
      this.email,
      this.q_left,
      this.exp_date,
      this.per_day,
      this.period_to_eat,
      this.q_prescribed,
      this.q_purchased});
}

class UserMedicineService {
  final String email;
  UserMedicineService({this.email});

  Firestore _firestore = Firestore.instance;
  String ref = 'users';
  String ref1 = 'user_medicine';

  void addUserMedicine(UserMedicine userMedicine) async {
    _firestore.settings(timestampsInSnapshotsEnabled: true);

    await _firestore.collection(ref).document(email).collection(ref1).add({
      'email': email,
      'category': userMedicine.category,
      'name': userMedicine.name,
      'exp_date': userMedicine.exp_date,
      'per_day': userMedicine.per_day,
      'period_to_eat': userMedicine.period_to_eat,
      'q_prescribed': userMedicine.q_prescribed,
      'q_purchased': userMedicine.q_purchased,
      'q_left': userMedicine.q_left
    });
  }

  void deleteUserMedicine(String id) async {
    await _firestore
        .collection(ref)
        .document(email)
        .collection(ref1)
        .document(id)
        .delete();
  }

  List<UserMedicine> _UserMedicineFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return UserMedicine(
        ID: doc.documentID,
        name: doc.data['name'] ?? '',
        category: doc.data['category'] ?? '',
        email: doc.data['email'] ?? '',
        q_purchased: doc.data['q_purchased'] ?? 0,
        q_left: doc.data['q_left'] ?? 0,
        q_prescribed: doc.data['q_prescribed'] ?? 0,
        per_day: doc.data['per_day'] ?? 0,
        period_to_eat: doc.data['period_to_eat'] ?? 0,
        exp_date: doc.data['exp_date'] ?? '',
      );
    }).toList();
  }

  Stream<List<UserMedicine>> get userMedicine {
    _firestore.settings(timestampsInSnapshotsEnabled: true);
    return _firestore
        .collection(ref)
        .document(email)
        .collection(ref1)
        .snapshots()
        .map(_UserMedicineFromSnapshot);
  }
}
