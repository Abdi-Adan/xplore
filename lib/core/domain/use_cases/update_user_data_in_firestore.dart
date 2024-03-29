import 'dart:io';

import 'package:shamiri/core/domain/repository/auth_repository.dart';
import 'package:shamiri/di/locator.dart';

import '../model/response_state.dart';
import '../model/user_model.dart';

class UpdateUserDataInFirestore {
  final repository = locator.get<AuthRepository>();

  Future<void> call({
    required UserModel oldUser,
    required UserModel newUser,
    required String uid,
    bool deleteImage = false,
    File? userProfilePic,
    Function(ResponseState response, String? error)? response,
  }) async =>
      await repository.updateUserDataInFirestore(
          oldUser: oldUser,
          newUser: newUser,
          uid: uid,
          deleteImage: deleteImage,
          userProfilePic: userProfilePic,
          response: response);
}
