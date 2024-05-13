import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locket_flutter/connection/auth/AuthSystem.dart';

class LocketAuth implements AuthSystem {
  final usersCollection = FirebaseFirestore.instance.collection("Users");

  static final LocketAuth _LocketAuth = LocketAuth._internal();
  
  factory LocketAuth() {
    return _LocketAuth;
  }
  
  LocketAuth._internal();

  @override
  Stream? getAuthState() {
    return FirebaseAuth.instance.authStateChanges();
  }

  @override
  Future signIn(String email, String password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future signUp(String email, String password) async {
          // try register
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

      // create new doc in firebase
      FirebaseFirestore.instance
        .collection("Users")
        .doc(userCredential.user!.email)
        .set({
          'username' : email.split('@')[0],
          'handphone' : 'Not set',
          'homeLat' : 0.0,
          'homeLong' : 0.0,
          'homeLoc' : 'Not set',
          'isCashier' : false,
          'isOrdering' : false
        });

      FirebaseFirestore.instance
        .collection("Checkout")
        .doc(userCredential.user!.email)
        .set({
          'items' : [],
          'total' : 0
        });
  }
  
  @override
  Future signOut() {
    return FirebaseAuth.instance.signOut();
  }
  
  @override
  getCurrentUserInstance() {
    return FirebaseAuth.instance.currentUser!;
  }
  
  @override
  Future<void> updateUserData(String field, newData) {
    return usersCollection.doc(getCurrentUserInstance().email).update({field: newData});
  }
  
  @override
  Stream? getCurrentUserSnapShot() {
    return FirebaseFirestore.instance.collection("Users").doc(getCurrentUserInstance().email).snapshots();
  }
  
}