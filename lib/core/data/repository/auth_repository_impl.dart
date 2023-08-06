import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:pinput/pinput.dart';
import 'package:shamiri/core/domain/model/user_prefs.dart';
import 'package:shamiri/core/domain/repository/auth_repository.dart';
import 'package:shamiri/core/utils/constants.dart';

import '../../../di/locator.dart';
import '../../domain/model/response_state.dart';
import '../../domain/model/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final userPrefsBox = Hive.box(Constants.USER_PREFS_BOX);
  final auth = locator.get<FirebaseAuth>();
  final firestore = locator.get<FirebaseFirestore>();
  final storage = locator.get<FirebaseStorage>();

  @override
  Future<void> signInWithPhone(
      {required String phoneNumber,
      required Function(ResponseState response, String? error) response,
      required Function(String verificationId) onCodeSent}) async {
    try {
      response(ResponseState.loading, null);

      await auth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            //  when verification is complete, sign in
            await auth.signInWithCredential(phoneAuthCredential);
            response(ResponseState.success, null);
          },
          verificationFailed: (error) {
            response(ResponseState.failure, error.message);
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            response(ResponseState.success, null);
            onCodeSent(verificationId);
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseException catch (error) {
      response(ResponseState.failure, error.message);
      throw Exception(error.code);
    }
  }

  @override
  Future<void> signOut() async => await FirebaseAuth.instance.signOut();

  @override
  Future<void> verifyOtp(
      {required String verificationId,
      required String userOtp,
      required Function(ResponseState response, String? error) response,
      required Function(User user) onSuccess}) async {
    response(ResponseState.loading, null);

    try {
      //  get login credentials
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOtp);

      final User? user = (await auth.signInWithCredential(credential)).user!;

      if (user != null) {
        response(ResponseState.success, null);
        onSuccess(user);
      }
    } on FirebaseAuthException catch (error) {
      response(ResponseState.failure, error.message);
      throw Exception(error);
    }
  }

  @override
  Future<bool> checkUserExists({required String uid}) async {
    final DocumentSnapshot snapshot =
        await firestore.collection(Constants.USER_COLLECTION).doc(uid).get();

    return snapshot.exists ? true : false;
  }

  /// FIRESTORE
  @override
  Future<void> getUserDataFromFirestore(
      {required Function(UserModel user) onSuccess}) async {
    try {
      final uid = auth.currentUser!.uid;

      await firestore
          .collection(Constants.USER_COLLECTION)
          .doc(uid)
          .get()
          .then((document) {
        final data = document.data();

        if (data != null) {
          onSuccess(UserModel.fromJson(data));
        } else {
          print("NO DATA FOUND!!");
        }
      });
    } on FirebaseAuthException catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<void> saveUserDataToFirestore(
      {required UserModel userModel,
      required File? userProfilePic,
      required Function(ResponseState response, String? error) response,
      required Function onSuccess}) async {
    response(ResponseState.loading, null);

    try {
      //  upload image to firebase storage
      if (userProfilePic != null) {
        await storeFileToFirebaseStorage(
                ref: 'profilePics/${auth.currentUser!.uid}',
                file: userProfilePic)
            .then((downloadUrl) {
          userModel.userProfilePicUrl = downloadUrl;
          userModel.createdAt = DateTime.now().toString();
          userModel.userPhoneNumber = auth.currentUser!.phoneNumber;
          userModel.userId = auth.currentUser!.uid;
        });
      } else {
        userModel.createdAt = DateTime.now().toString();
        userModel.userPhoneNumber = auth.currentUser!.phoneNumber;
        userModel.userId = auth.currentUser!.uid;
      }

      await firestore
          .collection(Constants.USER_COLLECTION)
          .doc(auth.currentUser!.uid)
          .set(userModel.toJson())
          .then((value) async {
        //  save data locally to hive
        await userPrefsBox.put(
            'userPrefs',
            UserPrefs(
                isLoggedIn: true,
                isProfileCreated: true,
                userModel: userModel));

        response(ResponseState.success, null);
        onSuccess();
      });
    } on FirebaseAuthException catch (error) {
      response(ResponseState.failure, error.message);
      throw Exception(error);
    }
  }

  @override
  Future<void> updateUserDataInFirestore(
      {required UserModel oldUser, required UserModel newUser}) async {
    final updatedUser = UserModel(
        userId: auth.currentUser!.uid,
        userName: newUser.userName ?? oldUser.userName,
        userProfilePicUrl:
            newUser.userProfilePicUrl ?? oldUser.userProfilePicUrl,
        userEmail: newUser.userEmail ?? oldUser.userEmail,
        userPhoneNumber: newUser.userPhoneNumber ?? oldUser.userPhoneNumber,
        createdAt: newUser.createdAt ?? oldUser.createdAt,
        storeLocation: newUser.storeLocation ?? oldUser.storeLocation);

    try {
      await firestore
          .collection(Constants.USER_COLLECTION)
          .doc(auth.currentUser!.uid)
          .update({
        "userId": auth.currentUser!.uid,
        "userName": newUser.userName ?? oldUser.userName,
        "userProfilePicUrl":
            newUser.userProfilePicUrl ?? oldUser.userProfilePicUrl,
        "userEmail": newUser.userEmail ?? oldUser.userEmail,
        "userPhoneNumber": newUser.userPhoneNumber ?? oldUser.userPhoneNumber,
        "createdAt": newUser.createdAt ?? oldUser.createdAt,
        "storeLocation": newUser.storeLocation ?? oldUser.storeLocation,
        "itemsInCart":
            newUser.itemsInCart?.map((item) => item.toJson()).toList() ??
                oldUser.itemsInCart?.map((item) => item.toJson()).toList()
      }).then((value) => print("SUCCESS!!!"));
    } on FirebaseException catch (error) {
      throw Exception(error.message);
    }
  }

  @override
  Future<String> storeFileToFirebaseStorage(
      {required String ref, required File file}) async {
    final UploadTask uploadTask = storage.ref().child(ref).putFile(file);
    final TaskSnapshot taskSnapshot = await uploadTask;

    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
