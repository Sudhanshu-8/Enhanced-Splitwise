import 'package:equatable/equatable.dart';

class Settlement extends Equatable {
  const Settlement({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.amount,
    required this.status,
    required this.createdAt,
    required this.paymentLink,
  });

  final String id;
  final String fromUser;
  final String toUser;
  final double amount;
  final String status;
  final DateTime createdAt;
  final String? paymentLink;

  factory Settlement.fromJson(Map<String, dynamic> json) {
    return Settlement(
      id: json['id'] as String,
      fromUser: json['from_user'] as String,
      toUser: json['to_user'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      status: json['status'] as String,
      paymentLink: json['payment_link'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  @override
  List<Object?> get props =>
      [id, fromUser, toUser, amount, status, createdAt, paymentLink];
}


