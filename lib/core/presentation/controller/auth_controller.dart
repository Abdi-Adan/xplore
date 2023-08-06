import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shamiri/core/domain/model/user_prefs.dart';
import 'package:shamiri/core/domain/use_cases/auth_use_cases.dart';
import 'package:shamiri/core/presentation/controller/user_prefs_controller.dart';
import 'package:shamiri/di/locator.dart';

import '../../domain/model/response_state.dart';
import '../../domain/model/user_model.dart';

class AuthController extends GetxController {
  final authUseCases = locator.get<AuthUseCases>();
  final userController = Get.find<UserPrefsController>();

  final user = Rxn<UserModel>();

  final isUserLoggedIn = false.obs;
  final isUserProfileCreated = false.obs;

  final isPhoneNumberValid = false.obs;
  final isFullNameValid = false.obs;
  final isEmailValid = false.obs;

  final isVerifyButtonLoading = false.obs;
  final isVerifyOtpLoading = false.obs;
  final isCreateProfileLoading = false.obs;

  void setVerifyButtonLoading({required bool isLoading}) =>
      isVerifyButtonLoading.value = isLoading;

  void setVerifyOtpLoading({required bool isLoading}) =>
      isVerifyOtpLoading.value = isLoading;

  void setCreateProfileLoading({required bool isLoading}) =>
      isCreateProfileLoading.value = isLoading;

  void setUserLoggedIn({required bool isLoggedIn}) {
    isUserLoggedIn.value = isLoggedIn;

    userController.updateUserPrefs(
        userPrefs: UserPrefs(isLoggedIn: isLoggedIn));
  }

  void setIsPhoneNumberValid({required bool isValid}) =>
      this.isPhoneNumberValid.value = isValid;

  void setIsFullNameValid({required bool isValid}) =>
      this.isFullNameValid.value = isValid;

  void setIsEmailValid({required bool isValid}) =>
      this.isEmailValid.value = isValid;

  void setUserProfileCreated({required bool isProfileCreated}) {
    isUserProfileCreated.value = isProfileCreated;

    userController.updateUserPrefs(
        userPrefs: UserPrefs(isProfileCreated: isProfileCreated));
  }

  void setUser({required UserModel? user}) => this.user.value = user;

  /// sign in with phone
  Future<void> signInWithPhone(
      {required String phoneNumber,
      required Function(ResponseState response, String? error) response,
      required Function(String verificationId) onCodeSent}) async {
    await authUseCases.signInWithPhone.call(
        phoneNumber: phoneNumber.trim(),
        response: response,
        onCodeSent: onCodeSent);
  }

  /// Sign Out
  Future<void> signOut() async => await authUseCases.signOut();

  /// Verify Otp
  Future<void> verifyOtp(
      {required String verificationId,
      required String userOtp,
      required Function(ResponseState response, String? error) response,
      required Function(User user) onSuccess}) async {
    await authUseCases.verifyOtp.call(
        verificationId: verificationId,
        userOtp: userOtp,
        response: response,
        onSuccess: onSuccess);
  }

  /// Check if user exists
  Future<bool> checkUserExists({required String uid}) async =>
      await authUseCases.checkUserExists.call(uid: uid);

  /// Save User Data to Firestore
  Future<void> saveUserDataToFirestore(
          {required UserModel userModel,
          required File? userProfilePic,
          required Function(ResponseState response, String? error) response,
          required Function onSuccess}) async =>
      await authUseCases.saveUserDataToFirestore.call(
          userModel: userModel,
          userProfilePic: userProfilePic,
          response: response,
          onSuccess: onSuccess);

  /// Get User Data from Firestore
  Stream<DocumentSnapshot> getUserDataFromFirestore() =>
      authUseCases.getUserDataFromFirestore();

  /// Update User Data In Firestore
  Future<void> updateUserDataInFirestore({required UserModel newUser}) async {
    await authUseCases.updateUserDataInFirestore
        .call(oldUser: user.value!, newUser: newUser);
  }
}
