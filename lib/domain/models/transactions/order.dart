// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
import 'package:shamiri/domain/value_objects/app_enums.dart';

part 'order.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  Order({
    required this.businessUID,
    required this.status,
    required this.products,
    this.date,
    this.orderRefId,
  });

  final String? businessUID;
  final TransactionStatus? status;
  final List<String> products;
  String? orderRefId;
  final String? date;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);

  factory Order.fromSnapshot(DocumentSnapshot snapshot) {
    final newTransaction =
        Order.fromJson(snapshot.data() as Map<String, dynamic>);
    newTransaction.orderRefId = snapshot.reference.id;
    return newTransaction;
  }

  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
