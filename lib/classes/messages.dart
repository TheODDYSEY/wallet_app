import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final List<Map<String, dynamic>> _messages = [
    {
      'title': 'Transaction Successful',
      'message': 'Your payment of \$25.00 to Coffee Shop was successful.',
      'time': DateTime.now().subtract(const Duration(minutes: 30)),
      'type': 'success',
      'read': false,
    },
    {
      'title': 'Security Alert',
      'message':
          'New device login detected. If this wasn\'t you, please contact support.',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'type': 'warning',
      'read': false,
    },
    {
      'title': 'Monthly Statement',
      'message': 'Your monthly statement for December is now available.',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'type': 'info',
      'read': true,
    },
    {
      'title': 'Money Received',
      'message': 'You received \$150.00 from John Doe.',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'type': 'success',
      'read': true,
    },
    {
      'title': 'Bill Payment Reminder',
      'message':
          'Your electricity bill is due in 3 days. Pay now to avoid late fees.',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'type': 'reminder',
      'read': true,
    },
    {
      'title': 'Account Update',
      'message': 'Your account information has been successfully updated.',
      'time': DateTime.now().subtract(const Duration(days: 5)),
      'type': 'info',
      'read': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: _messages.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageItem(_messages[index], index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 80,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 16),
          Text(
            'No Messages',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'ll see your notifications here',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> message, int index) {
    final isUnread = !message['read'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildMessageIcon(message['type']),
        title: Row(
          children: [
            Expanded(
              child: Text(
                message['title'],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E88E5),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message['message'],
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF718096),
                fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(message['time']),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        onTap: () {
          _markAsRead(index);
          _showMessageDetails(message);
        },
      ),
    );
  }

  Widget _buildMessageIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'success':
        icon = Icons.check_circle;
        color = const Color(0xFF4ECDC4);
        break;
      case 'warning':
        icon = Icons.warning;
        color = const Color(0xFFFFD93D);
        break;
      case 'info':
        icon = Icons.info;
        color = const Color(0xFF1E88E5);
        break;
      case 'reminder':
        icon = Icons.schedule;
        color = const Color(0xFF9B59B6);
        break;
      default:
        icon = Icons.notifications;
        color = const Color(0xFF718096);
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(time);
    }
  }

  void _markAsRead(int index) {
    if (!_messages[index]['read']) {
      setState(() {
        _messages[index]['read'] = true;
      });
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var message in _messages) {
        message['read'] = true;
      }
    });
  }

  void _showMessageDetails(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            _buildMessageIcon(message['type']),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message['title'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['message'],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Received: ${DateFormat('MMM dd, yyyy \'at\' HH:mm').format(message['time'])}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
