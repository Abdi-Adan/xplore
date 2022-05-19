// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import 'package:shamiri/domain/models/products/product.dart';
import 'package:shamiri/domain/value_objects/app_enums.dart';

part 'transaction.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  Order({
    required this.businessUID,
    required this.name,
    required this.status,
    required this.productsList,
  });

  final String? businessUID;
  final String? name;
  final TransactionStatus? status;
  final List<Product> productsList;
  String? transactionRefId;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  factory Order.fromSnapshot(DocumentSnapshot snapshot) {
    final newTransaction =
        Order.fromJson(snapshot.data() as Map<String, dynamic>);
    newTransaction.transactionRefId = snapshot.reference.id;
    return newTransaction;
  }

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}