import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionCard({
    super.key,
    required this.transaction,
  });

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case TransactionType.send:
        return Icons.send;
      case TransactionType.receive:
        return Icons.call_received;
      case TransactionType.payBill:
        return Icons.receipt_long;
      case TransactionType.withdraw:
        return Icons.atm;
      case TransactionType.topUp:
        return Icons.add_circle;
      case TransactionType.refund:
        return Icons.refresh;
    }
  }

  Color _getTransactionColor() {
    switch (transaction.type) {
      case TransactionType.send:
        return const Color(0xFFE53E3E);
      case TransactionType.receive:
        return const Color(0xFF38A169);
      case TransactionType.payBill:
        return const Color(0xFF2196F3);
      case TransactionType.withdraw:
        return const Color(0xFFFF9800);
      case TransactionType.topUp:
        return const Color(0xFF4CAF50);
      case TransactionType.refund:
        return const Color(0xFF9C27B0);
    }
  }

  Color _getAmountColor() {
    switch (transaction.type) {
      case TransactionType.receive:
      case TransactionType.topUp:
      case TransactionType.refund:
        return const Color(0xFF38A169);
      default:
        return const Color(0xFFE53E3E);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Transaction Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getTransactionColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTransactionIcon(),
                color: _getTransactionColor(),
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Transaction Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.typeDisplayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (transaction.recipientName != null) ...[
                        Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            transaction.recipientName!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else if (transaction.description != null) ...[
                        Icon(
                          Icons.notes,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            transaction.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          transaction.formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getAmountColor(),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: transaction.isCompleted
                        ? const Color(0xFF38A169).withOpacity(0.1)
                        : transaction.isPending
                            ? const Color(0xFFFF9800).withOpacity(0.1)
                            : const Color(0xFFE53E3E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transaction.statusDisplayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: transaction.isCompleted
                          ? const Color(0xFF38A169)
                          : transaction.isPending
                              ? const Color(0xFFFF9800)
                              : const Color(0xFFE53E3E),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
