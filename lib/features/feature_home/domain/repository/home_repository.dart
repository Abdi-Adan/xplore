import 'package:cloud_firestore/cloud_firestore.dart';

abstract class HomeRepository {

  /// Get All Stores
  Stream<QuerySnapshot> getAllStores();

  /// Get All Products
  Stream<QuerySnapshot> getAllProducts({required String? filter});

  /// Get User Products
  Stream<QuerySnapshot> getStoreProducts({required String userId});
}
