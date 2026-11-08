import 'dart:math' as math;

import 'package:flutter/material.dart';

enum Mood { calm, happy, thirsty }

enum Season { spring, summer, autumn, winter }

class TreeView extends StatelessWidget {
  final int stage;
  final Mood mood;
  final Season season;
  final int apples;
  final double size;
  const TreeView({super.key, required this.stage, this.mood = Mood.calm, this.season = Season.summer, this.apples = 0, this.size = 160});

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: SizedBox.square(dimension: size, child: CustomPaint(painter: TreePainter(stage, mood, season, apples))));
}

/// Where apples hang, in the painter's 200 by 200 box.
List<Offset> appleSpots(int stage) => stage >= 4
    ? const [Offset(50, 76), Offset(148, 74), Offset(66, 110), Offset(132, 110), Offset(32, 98), Offset(168, 98), Offset(100, 30), Offset(74, 38), Offset(128, 38)]
    : const [Offset(58, 104), Offset(142, 104), Offset(46, 88), Offset(154, 88), Offset(74, 46), Offset(128, 46)];

class TreePainter extends CustomPainter {
  final int stage;
  final Mood mood;
  final Season season;
  final int apples;
  TreePainter(this.stage, this.mood, this.season, this.apples);

  static const _trunk = Color(0xFF8A5A33);
  static const _trunkDark = Color(0xFF6F4526);

  Color get _leaf {
    final base = switch (season) {
      Season.spring => const Color(0xFF86D047),
      Season.summer => const Color(0xFF58B22E),
      Season.autumn => const Color(0xFFDFA031),
      Season.winter => const Color(0xFF6DA568),
    };
    return mood == Mood.thirsty ? Color.lerp(base, const Color(0xFFC6B56B), 0.5)! : base;
  }

  Color get _leafLight => Color.lerp(_leaf, Colors.white, 0.24)!;

  Paint _p(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  @override
  void paint(Canvas c, Size size) {
    final s = size.shortestSide / 200;
    c.save();
    c.translate((size.width - 200 * s) / 2, (size.height - 200 * s) / 2);
    c.scale(s);
    _ground(c);
    switch (stage) {
      case 0:
        _seed(c, const Offset(100, 160), 1);
        _face(c, const Offset(100, 165), 0.72);
      case 1:
        _stem(c, 150, 104, 6);
        _leafShape(c, const Offset(100, 112), -0.75, 38);
        _leafShape(c, const Offset(100, 106), 0.75 + math.pi, 38);
        _seed(c, const Offset(100, 164), 0.82);
        _face(c, const Offset(100, 168), 0.6);
      case 2:
        _stem(c, 178, 100, 9);
        _leafShape(c, const Offset(100, 142), -0.5, 30);
        _leafShape(c, const Offset(100, 128), 0.5 + math.pi, 30);
        _crown(c, const [(100.0, 80.0, 36.0), (74.0, 92.0, 20.0), (126.0, 92.0, 20.0)]);
        _face(c, const Offset(100, 84), 0.82);
      case 3:
        _trunkShape(c, 178, 100, 20, 12);
        const blobs = [(100.0, 74.0, 46.0), (62.0, 98.0, 30.0), (138.0, 98.0, 30.0)];
        _crown(c, blobs);
        _extras(c, blobs);
        _face(c, const Offset(100, 84), 1);
      default:
        _trunkShape(c, 178, 104, 26, 15);
        _branch(c, const Offset(100, 128), const Offset(66, 108));
        _branch(c, const Offset(100, 122), const Offset(136, 104));
        const blobs = [(100.0, 62.0, 52.0), (54.0, 88.0, 36.0), (146.0, 88.0, 36.0), (78.0, 106.0, 26.0), (122.0, 106.0, 26.0)];
        _crown(c, blobs);
        _extras(c, blobs);
        if (stage == 4 && season != Season.winter) _blossoms(c, 15);
        _face(c, const Offset(100, 74), 1.08);
    }
    if (stage >= 3 && apples > 0) _apples(c, apples);
    if (stage == 5) _apples(c, math.max(apples, 7));
    if (season == Season.winter) _snowfall(c);
    if (season == Season.autumn && stage >= 2) _fallingLeaves(c);
    c.restore();
  }

  void _ground(Canvas c) {
    final color = season == Season.winter
        ? const Color(0xFFE6F0F8)
        : mood == Mood.thirsty
            ? const Color(0xFFD8C08D)
            : const Color(0xFFA9DA6E);
    c.drawOval(Rect.fromCenter(center: const Offset(100, 180), width: 156, height: 32), _p(color));
    if (season == Season.winter) {
      c.drawOval(Rect.fromCenter(center: const Offset(76, 176), width: 54, height: 12), _p(Colors.white));
    }
  }

  void _seed(Canvas c, Offset o, double k) {
    c.save();
    c.translate(o.dx, o.dy);
    c.scale(k);
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: 58, height: 46), _p(const Color(0xFFB87A40)));
    c.drawOval(Rect.fromCenter(center: const Offset(-10, -8), width: 18, height: 10), _p(const Color(0xFFD29A62)));
    if (stage == 0) {
      final cap = Path()
        ..moveTo(-26, -8)
        ..quadraticBezierTo(0, -40, 26, -8)
        ..quadraticBezierTo(0, -16, -26, -8);
      c.drawPath(cap, _p(const Color(0xFF7A4E2A)));
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-2.5, -36, 5, 10), const Radius.circular(3)), _p(const Color(0xFF7A4E2A)));
    }
    c.restore();
  }

  void _stem(Canvas c, double from, double to, double w) {
    final p = Paint()
      ..color = stage < 2 ? const Color(0xFF6DB83A) : _trunk
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(100, from)
      ..quadraticBezierTo(104, (from + to) / 2, 100, to);
    c.drawPath(path, p);
  }

  void _trunkShape(Canvas c, double from, double to, double bottom, double top) {
    final path = Path()
      ..moveTo(100 - bottom / 2 - 4, from)
      ..quadraticBezierTo(100 - bottom / 2 + 1, (from + to) / 2, 100 - top / 2, to)
      ..lineTo(100 + top / 2, to)
      ..quadraticBezierTo(100 + bottom / 2 - 1, (from + to) / 2, 100 + bottom / 2 + 4, from)
      ..close();
    c.drawPath(path, _p(_trunk));
    final shade = Path()
      ..moveTo(100 + 1, from)
      ..lineTo(100 + 1, to)
      ..lineTo(100 + top / 2, to)
      ..quadraticBezierTo(100 + bottom / 2 - 1, (from + to) / 2, 100 + bottom / 2 + 4, from)
      ..close();
    c.drawPath(shade, _p(_trunkDark.withValues(alpha: 0.35)));
  }

  void _branch(Canvas c, Offset a, Offset b) => c.drawLine(
      a,
      b,
      Paint()
        ..color = _trunk
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round);

  void _leafShape(Canvas c, Offset at, double angle, double len) {
    c.save();
    c.translate(at.dx, at.dy);
    c.rotate(angle + (mood == Mood.thirsty ? 0.35 * (angle.abs() < 1.5 ? 1 : -1) : 0));
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(len * 0.5, -len * 0.5, len, 0)
      ..quadraticBezierTo(len * 0.5, len * 0.42, 0, 0);
    c.drawPath(path, _p(_leaf));
    c.drawLine(Offset(len * 0.15, 0), Offset(len * 0.8, 0), Paint()
      ..color = _leafLight
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round);
    c.restore();
  }

  void _crown(Canvas c, List<(double, double, double)> blobs) {
    for (final (x, y, r) in blobs) {
      c.drawCircle(Offset(x, y), r, _p(_leaf));
    }
    for (final (x, y, r) in blobs) {
      c.drawCircle(Offset(x - r * 0.3, y - r * 0.34), r * 0.42, _p(_leafLight.withValues(alpha: 0.55)));
    }
  }

  void _extras(Canvas c, List<(double, double, double)> blobs) {
    if (season == Season.winter) {
      for (final (x, y, r) in blobs.take(3)) {
        c.drawOval(Rect.fromCenter(center: Offset(x, y - r * 0.72), width: r * 1.5, height: r * 0.62), _p(Colors.white));
      }
    }
    if (season == Season.spring && stage == 3) _blossoms(c, 9);
  }

  void _blossoms(Canvas c, int n) {
    const spots = [
      Offset(62, 62), Offset(138, 60), Offset(100, 24), Offset(40, 90), Offset(160, 92), Offset(76, 36), Offset(126, 34),
      Offset(58, 112), Offset(146, 112), Offset(150, 72), Offset(50, 72), Offset(88, 120), Offset(116, 122), Offset(30, 100), Offset(170, 100),
    ];
    for (final o in spots.take(n)) {
      for (var i = 0; i < 5; i++) {
        final a = i * 2 * math.pi / 5 - math.pi / 2;
        c.drawCircle(o + Offset(math.cos(a), math.sin(a)) * 4.4, 3.6, _p(const Color(0xFFFFB6CF)));
      }
      c.drawCircle(o, 2.6, _p(const Color(0xFFF7D154)));
    }
  }

  void _apples(Canvas c, int n) {
    for (final o in appleSpots(stage).take(n)) {
      c.drawCircle(o, 9, _p(const Color(0xFFE5392F)));
      c.drawCircle(o + const Offset(-3, -3), 2.6, _p(const Color(0xFFFF9C8F)));
      c.drawLine(o + const Offset(0, -8), o + const Offset(2, -13), Paint()
        ..color = _trunkDark
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round);
    }
  }

  void _face(Canvas c, Offset o, double k) {
    c.save();
    c.translate(o.dx, o.dy);
    c.scale(k);
    const ink = Color(0xFF2A2A22);
    c.drawCircle(const Offset(-23, 10), 6.5, _p(const Color(0x66FF8FA3)));
    c.drawCircle(const Offset(23, 10), 6.5, _p(const Color(0x66FF8FA3)));
    final line = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    if (mood == Mood.happy) {
      for (final x in [-14.0, 14.0]) {
        c.drawPath(Path()..moveTo(x - 6.5, 1)..quadraticBezierTo(x, -9, x + 6.5, 1), line);
      }
      final mouth = Path()
        ..moveTo(-10, 8)
        ..quadraticBezierTo(0, 12, 10, 8)
        ..quadraticBezierTo(8, 23, 0, 23)
        ..quadraticBezierTo(-8, 23, -10, 8)
        ..close();
      c.drawPath(mouth, _p(const Color(0xFF7D2B2B)));
      c.drawOval(Rect.fromCenter(center: const Offset(0, 20), width: 10, height: 5.5), _p(const Color(0xFFFF8A8A)));
    } else {
      for (final x in [-14.0, 14.0]) {
        c.drawCircle(Offset(x, -2), 5.6, _p(ink));
        c.drawCircle(Offset(x + 1.8, -4), 1.9, _p(Colors.white));
      }
      if (mood == Mood.thirsty) {
        c.drawLine(const Offset(-21, -11), const Offset(-9, -14), line..strokeWidth = 2.6);
        c.drawLine(const Offset(21, -11), const Offset(9, -14), line);
        c.drawPath(Path()..moveTo(-7, 14)..quadraticBezierTo(0, 9, 7, 14), line..strokeWidth = 3);
      } else {
        c.drawPath(Path()..moveTo(-8, 9)..quadraticBezierTo(0, 17, 8, 9), line);
      }
    }
    c.restore();
  }

  void _snowfall(Canvas c) {
    const flakes = [Offset(18, 30), Offset(44, 12), Offset(176, 22), Offset(150, 8), Offset(14, 92), Offset(186, 84), Offset(26, 142), Offset(178, 140), Offset(120, 6), Offset(66, 150), Offset(146, 152)];
    for (final f in flakes) {
      c.drawCircle(f, 3, _p(Colors.white));
    }
  }

  void _fallingLeaves(Canvas c) {
    _leafShape(c, const Offset(30, 136), 0.5, 13);
    _leafShape(c, const Offset(172, 150), -0.6, 13);
    _leafShape(c, const Offset(150, 166), 0.3, 11);
  }

  @override
  bool shouldRepaint(TreePainter o) => o.stage != stage || o.mood != mood || o.season != season || o.apples != apples;
}

class ConfettiPainter extends CustomPainter {
  /// 0 at the start of the burst, 1 when the pieces have fallen.
  final double t;
  ConfettiPainter(this.t);

  @override
  void paint(Canvas c, Size size) {
    final r = math.Random(11);
    const colors = [Color(0xFFFF5A1F), Color(0xFF58B22E), Color(0xFFF7C72F), Color(0xFF4AA8E8), Color(0xFFE5392F), Color(0xFFFF9CC2)];
    for (var i = 0; i < 90; i++) {
      final x = r.nextDouble() * size.width;
      final start = -40 - r.nextDouble() * size.height * 0.5;
      final y = start + (size.height * 1.1 - start) * t * (0.7 + r.nextDouble() * 0.3);
      final turn = r.nextDouble() * math.pi;
      c.save();
      c.translate(x, y);
      c.rotate(turn + t * 8);
      final p = Paint()..color = colors[i % colors.length];
      if (i % 3 == 0) {
        c.drawCircle(Offset.zero, 4, p);
      } else {
        c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-6, -3, 12, 6), const Radius.circular(2)), p);
      }
      c.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter o) => o.t != t;
}

class RingPainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  RingPainter(this.value, this.color, this.track);

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final r = Rect.fromLTWH(3, 3, s.width - 6, s.height - 6);
    c.drawArc(r, 0, 2 * math.pi, false, p..color = track);
    c.drawArc(r, -math.pi / 2, 2 * math.pi * value, false, p..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
