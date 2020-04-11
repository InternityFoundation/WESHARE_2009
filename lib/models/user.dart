import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class User {
  final String name;
  final String email;
  final String uid;

  User({this.name, this.email, this.uid});
}

class UserAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
//  FirebaseUser _user;
  Firestore _firestore = Firestore.instance;

  logOut() async {
    await _auth.signOut();
    print('logged out from funtion');
  }

  User _userFromFirebaseUser(FirebaseUser user) {
    return user != null ? User(uid: user.uid, email: user.email) : null;
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((user) {
        _firestore
            .collection('users')
            .document(user.user.email)
            .setData({'email': email, 'uid': user.user.uid, 'name': name});
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }
}
