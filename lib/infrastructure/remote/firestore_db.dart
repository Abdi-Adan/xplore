import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:xplore/infrastructure/remote/firebase_auth.dart';

FirebaseFirestore globalFirestoreInstance = FirebaseFirestore.instance;

class XploreFirestore {
  Future<void> createRemoteUserEntity() async {
    final User? _user = globalFirebaseAuthInstance.currentUser;

    assert(_user != null);

    globalFirestoreInstance.collection("Users").add({
      "key": 'Users',
      "UID": _user!.uid,
      "PhoneNumber": _user.phoneNumber,
      "IsAnonymous": _user.isAnonymous,
    }).then((_) {
      if (kDebugMode) {
        print("User collection created");
      }
    }).catchError((_) {
      print("an error occured");
    });
  }
}
