import 'package:flutter/material.dart';
import 'package:physiotherapy/core/theme/theme.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.green : AppTheme.TurquoiseLagoon,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 0),
      child: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
