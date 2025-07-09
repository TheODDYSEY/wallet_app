import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';

class AnimationUtils {
  // Fade animations
  static Widget fadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0,
  }) {
    return FadeIn(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  static Widget fadeInUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0,
  }) {
    return FadeInUp(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  static Widget fadeInDown({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0,
  }) {
    return FadeInDown(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  static Widget fadeInLeft({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0,
  }) {
    return FadeInLeft(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  static Widget fadeInRight({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0,
  }) {
    return FadeInRight(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  // Scale animations
  static Widget bounceIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0,
  }) {
    return BounceInDown(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  static Widget zoomIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0,
  }) {
    return ZoomIn(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  // Slide animations
  static Widget slideInUp({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0,
  }) {
    return SlideInUp(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  static Widget slideInDown({
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    double delay = 0,
  }) {
    return SlideInDown(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  // Elastic animations
  static Widget elasticIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 800),
    double delay = 0,
  }) {
    return ElasticIn(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  // Flash animations
  static Widget flash({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    double delay = 0,
  }) {
    return Flash(
      duration: duration,
      delay: Duration(milliseconds: (delay * 1000).round()),
      child: child,
    );
  }

  // Custom staggered list animation
  static List<Widget> staggeredList({
    required List<Widget> children,
    Duration duration = const Duration(milliseconds: 300),
    double staggerDelay = 0.1,
  }) {
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;

      return fadeInUp(
        child: child,
        duration: duration,
        delay: index * staggerDelay,
      );
    }).toList();
  }

  // Custom card entrance animation
  static Widget cardEntrance({
    required Widget child,
    double delay = 0,
  }) {
    return fadeInUp(
      child: child,
      duration: const Duration(milliseconds: 400),
      delay: delay,
    );
  }

  // Button press animation
  static Widget buttonScale({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 100),
      tween: Tween<double>(begin: 1.0, end: 1.0),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          // Scale down animation would be implemented here
        },
        onTapUp: (_) {
          // Scale up animation would be implemented here
          onTap?.call();
        },
        onTapCancel: () {
          // Reset scale animation would be implemented here
        },
        child: child,
      ),
    );
  }
}

class UIUtils {
  // Show snackbar with animation
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor ?? Colors.black87,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        action: action,
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AnimationUtils.fadeIn(
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Show error dialog
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (context) => AnimationUtils.fadeIn(
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onOk?.call();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  // Show success dialog
  static void showSuccessDialog(
    BuildContext context,
    String title,
    String message, {
    VoidCallback? onOk,
  }) {
    showDialog(
      context: context,
      builder: (context) => AnimationUtils.bounceIn(
        child: AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(title),
            ],
          ),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onOk?.call();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }

  // Show confirmation dialog
  static void showConfirmationDialog(
    BuildContext context,
    String title,
    String message, {
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) {
    showDialog(
      context: context,
      builder: (context) => AnimationUtils.fadeIn(
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel?.call();
              },
              child: Text(cancelText),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              child: Text(confirmText),
            ),
          ],
        ),
      ),
    );
  }

  // Haptic feedback
  static void hapticFeedback() {
    HapticFeedback.lightImpact();
  }

  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
    }
    return phone;
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone number
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?[1-9]\d{1,14}$')
        .hasMatch(phone.replaceAll(RegExp(r'[^\d+]'), ''));
  }

  // Generate color from string
  static Color generateColorFromString(String text) {
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }

    final r = (hash & 0xFF0000) >> 16;
    final g = (hash & 0x00FF00) >> 8;
    final b = hash & 0x0000FF;

    return Color.fromRGBO(r, g, b, 1.0);
  }

  // Custom page route with animation
  static PageRouteBuilder<T> createRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}
