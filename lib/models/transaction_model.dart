import 'package:intl/intl.dart';

enum TransactionType {
  send,
  receive,
  payBill,
  withdraw,
  topUp,
  refund,
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final String currency;
  final String? description;
  final String? recipientPhone;
  final String? recipientName;
  final String? billType;
  final String? accountNumber;
  final String? reference;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    this.currency = 'USD',
    this.description,
    this.recipientPhone,
    this.recipientName,
    this.billType,
    this.accountNumber,
    this.reference,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  String get formattedAmount {
    final prefix = type == TransactionType.receive ||
            type == TransactionType.topUp ||
            type == TransactionType.refund
        ? '+'
        : '-';
    return '$prefix\$${amount.toStringAsFixed(2)}';
  }

  String get formattedDate {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(createdAt);
  }

  String get typeDisplayName {
    switch (type) {
      case TransactionType.send:
        return 'Send Money';
      case TransactionType.receive:
        return 'Received Money';
      case TransactionType.payBill:
        return 'Bill Payment';
      case TransactionType.withdraw:
        return 'Withdrawal';
      case TransactionType.topUp:
        return 'Top Up';
      case TransactionType.refund:
        return 'Refund';
    }
  }

  String get statusDisplayName {
    switch (status) {
      case TransactionStatus.pending:
        return 'Pending';
      case TransactionStatus.completed:
        return 'Completed';
      case TransactionStatus.failed:
        return 'Failed';
      case TransactionStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isCompleted => status == TransactionStatus.completed;
  bool get isPending => status == TransactionStatus.pending;
  bool get isFailed => status == TransactionStatus.failed;

  static TransactionType _parseTransactionType(String type) {
    switch (type.toLowerCase()) {
      case 'send':
        return TransactionType.send;
      case 'receive':
        return TransactionType.receive;
      case 'paybill':
      case 'pay_bill':
        return TransactionType.payBill;
      case 'withdraw':
        return TransactionType.withdraw;
      case 'topup':
      case 'top_up':
        return TransactionType.topUp;
      case 'refund':
        return TransactionType.refund;
      default:
        return TransactionType.send;
    }
  }

  static TransactionStatus _parseTransactionStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return TransactionStatus.pending;
      case 'completed':
        return TransactionStatus.completed;
      case 'failed':
        return TransactionStatus.failed;
      case 'cancelled':
        return TransactionStatus.cancelled;
      default:
        return TransactionStatus.pending;
    }
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: _parseTransactionType(json['type'] ?? 'send'),
      status: _parseTransactionStatus(json['status'] ?? 'pending'),
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'USD',
      description: json['description'],
      recipientPhone: json['recipientPhone'],
      recipientName: json['recipientName'],
      billType: json['billType'],
      accountNumber: json['accountNumber'],
      reference: json['reference'],
      metadata: json['metadata'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'amount': amount,
      'currency': currency,
      'description': description,
      'recipientPhone': recipientPhone,
      'recipientName': recipientName,
      'billType': billType,
      'accountNumber': accountNumber,
      'reference': reference,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    TransactionStatus? status,
    double? amount,
    String? currency,
    String? description,
    String? recipientPhone,
    String? recipientName,
    String? billType,
    String? accountNumber,
    String? reference,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      recipientName: recipientName ?? this.recipientName,
      billType: billType ?? this.billType,
      accountNumber: accountNumber ?? this.accountNumber,
      reference: reference ?? this.reference,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $typeDisplayName, amount: $formattedAmount, status: $statusDisplayName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
