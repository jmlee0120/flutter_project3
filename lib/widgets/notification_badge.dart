// lib/widgets/notification_badge.dart
import 'package:flutter/material.dart';

class NotificationBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color color;
  final double size;
  final double fontSize;

  const NotificationBadge({
    Key? key,
    required this.child,
    required this.count,
    this.color = Colors.red,
    this.size = 18.0,
    this.fontSize = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (count > 0)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(size < 16 ? 1.0 : 2.0),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: size,
                minHeight: size,
              ),
              child: Center(
                child: count > 99
                    ? Text(
                  '99+',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                )
                    : Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}