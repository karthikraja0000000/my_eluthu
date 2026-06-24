import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TapeStrip extends StatelessWidget {
  final Color color;
  final Widget child;
  const TapeStrip({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(1),
        topRight: Radius.circular(2),
        bottomLeft: Radius.circular(2),
        bottomRight: Radius.circular(1),
      ),
    ),
    child: child,
  );
}

class HolePunch extends StatelessWidget {
  const HolePunch({super.key});

  @override
  Widget build(BuildContext context) => Container(
    width: 14.r,
    height: 14.r,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: const Color(0xFFF7F0E6),
      border: Border.all(
        color: const Color(0xFFBCAAA4).withOpacity(0.5),
        width: 0.8,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
  );
}

class RuledLinePainter extends CustomPainter {
  final double startY;
  final double spacing;
  final Color? color;

  RuledLinePainter({this.startY = 34.0, this.spacing = 22.0, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color ?? const Color(0xFF90CAF9).withOpacity(0.3)
      ..strokeWidth = 0.6;
    for (double y = startY; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BackgroundLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFD7C9A0).withOpacity(0.4)
      ..strokeWidth = 0.5;
    for (double y = 0; y < size.height; y += 28) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
