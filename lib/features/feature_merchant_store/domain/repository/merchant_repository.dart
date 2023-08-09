import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shamiri/features/feature_merchant_store/domain/model/product_model.dart';

import '../../../../core/domain/model/response_state.dart';

abstract class MerchantRepository {
  Future<void> addProductToFirestore(
      {required ProductModel product,
      required File? productPic,
      required Function(ResponseState response) response,
      required Function onSuccess});

  Future<void> updateProduct(
      {required ProductModel oldProduct,
        required ProductModel newProduct,
      required Function(ResponseState response) response});

  Future<void> deleteProduct({required String productId});

  Stream<QuerySnapshot> getMerchantProducts();
}
