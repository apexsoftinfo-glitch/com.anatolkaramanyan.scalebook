import 'package:flutter/material.dart';
import '../app_colors.dart';

class LimitDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onAction;
  final String actionLabel;

  const LimitDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onAction,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(), // Tamiya box style
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.red, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.navyBlue,
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: AppColors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navyBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(),
              ),
              child: Text(actionLabel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('MAYBE LATER', style: TextStyle(color: AppColors.grey)), // L10N
            ),
          ],
        ),
      ),
    );
  }
}
