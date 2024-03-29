import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';
import 'package:shamiri/core/domain/model/user_prefs.dart';
import 'package:shamiri/core/domain/repository/auth_repository.dart';
import 'package:shamiri/core/utils/constants.dart';
import 'package:shamiri/core/utils/extensions/string_extensions.dart';

import '../../../di/locator.dart';
import '../../domain/model/response_state.dart';
import '../../domain/model/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final userPrefsBox = Hive.box(Constants.USER_PREFS_BOX);
  final auth = locator.get<FirebaseAuth>();
  final firestore = locator.get<FirebaseFirestore>();
  final storage = locator.get<FirebaseStorage>();

  int? _resendToken;

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
            _resendToken = forceResendingToken;
          },
          timeout: const Duration(seconds: 30),
          forceResendingToken: _resendToken,
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseException catch (error) {
      response(ResponseState.failure, error.message);
      throw Exception(error.code);
    }
  }

  @override
  Future<void> signOut() async => await FirebaseAuth.instance.signOut();

  @override
  Future<void> deleteAccount() async {
    final user = await FirebaseAuth.instance.currentUser;
    await user!.delete();
  }

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
  Stream<DocumentSnapshot> getUserDataFromFirestore() {
    try {
      final uid = auth.currentUser!.uid;

      return firestore
          .collection(Constants.USER_COLLECTION)
          .doc(uid)
          .snapshots();
    } on FirebaseAuthException catch (error) {
      throw Exception(error);
    }
  }

  @override
  Future<UserModel> getSpecificUserFromFirestore({required String uid}) async {
    try {
      final snapshot =
          await firestore.collection(Constants.USER_COLLECTION).doc(uid).get();

      return UserModel.fromJson(snapshot.data()!);
    } catch (error) {
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
      {required UserModel oldUser,
      required UserModel newUser,
      required String uid,
      bool deleteImage = false,
      File? userProfilePic,
      Function(ResponseState response, String? error)? response}) async {
    response!(ResponseState.loading, null);
    try {
      //  only delete user profile image
      if (deleteImage && userProfilePic == null) {
        await deleteFileFromFirebaseStorage(
            ref: 'profilePics/${oldUser.userProfilePicUrl!.getImagePath}',
            response: (state, error) {});

        newUser.userProfilePicUrl = '';
      } else if (userProfilePic != null) {
        //  delete the current image
        await deleteFileFromFirebaseStorage(
            ref: 'profilePics/${oldUser.userProfilePicUrl!.getImagePath}',
            response: (state, error) {});
        //  upload the new one
        await storeFileToFirebaseStorage(
                ref: 'profilePics/${auth.currentUser!.uid}',
                file: userProfilePic)
            .then((downloadUrl) {
          //  update the new user profile pic
          newUser.userProfilePicUrl = downloadUrl;
        });
      }

      await firestore.collection(Constants.USER_COLLECTION).doc(uid).update({
        "userName": newUser.userName ?? oldUser.userName,
        "userProfilePicUrl":
            newUser.userProfilePicUrl ?? oldUser.userProfilePicUrl,
        "userEmail": newUser.userEmail ?? oldUser.userEmail,
        "userPhoneNumber": newUser.userPhoneNumber ?? oldUser.userPhoneNumber,
        "storeLocation": newUser.storeLocation ?? oldUser.storeLocation,
        "storeName": newUser.storeName ?? oldUser.storeName,
        "storeDescription":
            newUser.storeDescription ?? oldUser.storeDescription,
        "itemsInCart":
            newUser.itemsInCart?.map((item) => item.toJson()).toList() ??
                oldUser.itemsInCart?.map((item) => item.toJson()).toList(),
        "transactions": newUser.transactions
                ?.map((transaction) => {
                      "buyerId": transaction.buyerId,
                      "product": {
                        "sellerId": transaction.product!.sellerId,
                        "sellerName": transaction.product!.sellerName,
                        "productId": transaction.product!.productId,
                        "productName": transaction.product!.productName,
                        "productUnit": transaction.product!.productUnit,
                        "productStockCount":
                            transaction.product!.productStockCount,
                        "productBuyingPrice":
                            transaction.product!.productBuyingPrice,
                        "productSellingPrice":
                            transaction.product!.productSellingPrice,
                        "productCategoryId":
                            transaction.product!.productCategoryId,
                        "productImageUrls":
                            transaction.product!.productImageUrls,
                        "productDescription":
                            transaction.product!.productDescription,
                        "productCreatedAt":
                            transaction.product!.productCreatedAt
                      },
                      "itemsBought": transaction.itemsBought,
                      "amountPaid": transaction.amountPaid,
                      "transactionDate": transaction.transactionDate,
                      "transactionCompletedDate":
                          transaction.transactionCompletedDate,
                      "isFulfilled": transaction.isFulfilled,
                      "transactionType": transaction.transactionType,
                      "transactionPaymentMethod":
                          transaction.transactionPaymentMethod,
                    })
                .toList() ??
            oldUser.transactions
                ?.map((transaction) => {
                      "buyerId": transaction.buyerId,
                      "product": {
                        "sellerId": transaction.product!.sellerId,
                        "sellerName": transaction.product!.sellerName,
                        "productId": transaction.product!.productId,
                        "productName": transaction.product!.productName,
                        "productUnit": transaction.product!.productUnit,
                        "productStockCount":
                            transaction.product!.productStockCount,
                        "productBuyingPrice":
                            transaction.product!.productBuyingPrice,
                        "productSellingPrice":
                            transaction.product!.productSellingPrice,
                        "productCategoryId":
                            transaction.product!.productCategoryId,
                        "productImageUrls":
                            transaction.product!.productImageUrls,
                        "productDescription":
                            transaction.product!.productDescription,
                        "productCreatedAt":
                            transaction.product!.productCreatedAt
                      },
                      "itemsBought": transaction.itemsBought,
                      "amountPaid": transaction.amountPaid,
                      "transactionDate": transaction.transactionDate,
                      "transactionCompletedDate":
                          transaction.transactionCompletedDate,
                      "isFulfilled": transaction.isFulfilled,
                      "transactionType": transaction.transactionType,
                      "transactionPaymentMethod":
                          transaction.transactionPaymentMethod,
                    })
                .toList()
      }).then((value) => response(ResponseState.success, null));

      response(ResponseState.success, null);
    } on FirebaseException catch (error) {
      response(ResponseState.failure, error.message);
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

  @override
  Future<void> deleteFileFromFirebaseStorage(
      {required String ref,
      Function(ResponseState response, String? error)? response}) async {
    response!(ResponseState.loading, null);
    try {
      await FirebaseStorage.instance.ref().child(ref).delete().then((value) {
        print("Deleted Successfully");
        response(ResponseState.success, null);
      });
    } on FirebaseException catch (error) {
      response(ResponseState.failure, error.message);
    }
  }

  @override
  Future<bool> checkFileExistsInFirebaseStorage({required String ref}) async {
    try {
      // final storageFile = storage.bucket.file();
      throw UnimplementedError();
    } on FirebaseException catch (error) {
      throw Exception(error);
    }
  }
}
