// Domino tile widget: rounded ivory tile with pip faces.
import 'package:flutter/material.dart';
import '../game/engine.dart';

class DominoTileWidget extends StatelessWidget {
  final DominoTile tile;
  final double width;
  final bool horizontal;
  final Color face;
  final Color ink;
  final bool dimmed;
  final bool selected;

  const DominoTileWidget({
    super.key,
    required this.tile,
    this.width = 56,
    this.horizontal = true,
    required this.face,
    required this.ink,
    this.dimmed = false,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = horizontal ? width / 2 : width * 2;
    final w = horizontal ? width : width / 2;
    return Opacity(
      opacity: dimmed ? 0.45 : 1.0,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: face,
          borderRadius: BorderRadius.circular(width * 0.12),
          border: Border.all(
            color: selected ? Colors.amber : ink.withValues(alpha: 0.55),
            width: selected ? 3 : 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 8)
                ]
              : [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 3,
                      offset: const Offset(0, 2))
                ],
        ),
        child: CustomPaint(
          painter: _PipPainter(
              tile, horizontal: horizontal, ink: ink),
        ),
      ),
    );
  }
}

class _PipPainter extends CustomPainter {
  final DominoTile tile;
  final bool horizontal;
  final Color ink;
  _PipPainter(this.tile, {required this.horizontal, required this.ink});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ink;
    // Divider line.
    final div = Paint()
      ..color = ink.withValues(alpha: 0.6)
      ..strokeWidth = 1.4;
    if (horizontal) {
      final y = size.height / 2;
      canvas.drawLine(Offset(size.width * 0.12, y),
          Offset(size.width * 0.88, y), div);
      _half(canvas, size, Rect.fromLTWH(0, 0, size.width, size.height / 2),
          tile.a, paint);
      _half(canvas, size, Rect.fromLTWH(0, size.height / 2, size.width, size.height / 2),
          tile.b, paint);
    } else {
      final x = size.width / 2;
      canvas.drawLine(Offset(x, size.height * 0.12),
          Offset(x, size.height * 0.88), div);
      _half(canvas, size, Rect.fromLTWH(0, 0, size.width / 2, size.height),
          tile.a, paint);
      _half(canvas, size, Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height),
          tile.b, paint);
    }
  }

  void _half(Canvas canvas, Size size, Rect r, int value, Paint paint) {
    if (value == 0) return;
    final cx = r.center.dx, cy = r.center.dy;
    final dx = r.width * 0.26, dy = r.height * 0.26;
    final rad = (r.shortestSide * 0.09).clamp(2.0, 6.0);
    void dot(double x, double y) =>
        canvas.drawCircle(Offset(cx + x, cy + y), rad, paint);
    switch (value) {
      case 1:
        dot(0, 0);
      case 2:
        dot(-dx, -dy);
        dot(dx, dy);
      case 3:
        dot(-dx, -dy);
        dot(0, 0);
        dot(dx, dy);
      case 4:
        dot(-dx, -dy);
        dot(dx, -dy);
        dot(-dx, dy);
        dot(dx, dy);
      case 5:
        dot(-dx, -dy);
        dot(dx, -dy);
        dot(0, 0);
        dot(-dx, dy);
        dot(dx, dy);
      case 6:
        dot(-dx, -dy);
        dot(dx, -dy);
        dot(-dx, 0);
        dot(dx, 0);
        dot(-dx, dy);
        dot(dx, dy);
    }
  }

  @override
  bool shouldRepaint(covariant _PipPainter old) =>
      old.tile != tile || old.ink != ink || old.horizontal != horizontal;
}

/// Face-down tile back.
class TileBackWidget extends StatelessWidget {
  final double width;
  final Color back;
  final Color trim;
  const TileBackWidget(
      {super.key, this.width = 40, required this.back, required this.trim});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width / 2,
      decoration: BoxDecoration(
        color: back,
        borderRadius: BorderRadius.circular(width * 0.12),
        border: Border.all(color: trim, width: 1.5),
      ),
      child: Center(
        child: Container(
          width: width * 0.4,
          height: width * 0.2,
          decoration: BoxDecoration(
            border: Border.all(color: trim.withValues(alpha: 0.7)),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
