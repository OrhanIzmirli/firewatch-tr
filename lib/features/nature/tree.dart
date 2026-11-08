import 'dart:math' as math;

import 'package:flutter/material.dart';

enum Mood { calm, happy, thirsty }

enum Season { spring, summer, autumn, winter }

class TreeView extends StatelessWidget {
  final int stage;
  final Mood mood;
  final Season season;
  final int apples;

  /// One big flower for each finished section of lessons.
  final int flowers;
  final double size;
  const TreeView({super.key, required this.stage, this.mood = Mood.calm, this.season = Season.summer, this.apples = 0, this.flowers = 0, this.size = 160});

  @override
  Widget build(BuildContext context) =>
      ExcludeSemantics(child: SizedBox.square(dimension: size, child: CustomPaint(painter: TreePainter(stage, mood, season, apples, flowers))));
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
  final int flowers;
  TreePainter(this.stage, this.mood, this.season, this.apples, [this.flowers = 0]);

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
    if (flowers > 0) _rewardFlowers(c, flowers);
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

  /// Section rewards, big enough to tell apart from spring blossom and
  /// placed so that even a small sapling can carry all of them.
  void _rewardFlowers(Canvas c, int n) {
    final spots = switch (stage) {
      0 || 1 => const [Offset(58, 88), Offset(142, 88), Offset(100, 74), Offset(46, 128), Offset(154, 128)],
      2 => const [Offset(76, 66), Offset(124, 66), Offset(100, 48), Offset(56, 96), Offset(144, 96)],
      _ => const [Offset(64, 56), Offset(136, 54), Offset(100, 24), Offset(36, 92), Offset(164, 92)],
    };
    const petals = [Color(0xFFFF7A59), Color(0xFFFFD84D), Color(0xFFFF9CC2), Color(0xFF7CC8FF), Color(0xFFC9A6FF)];
    for (final (i, o) in spots.take(n).indexed) {
      for (var p = 0; p < 6; p++) {
        final a = p * math.pi / 3;
        c.drawCircle(o + Offset(math.cos(a), math.sin(a)) * 8, 6.2, _p(petals[i % petals.length]));
      }
      c.drawCircle(o, 5.2, _p(const Color(0xFFFFF3B0)));
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
  bool shouldRepaint(TreePainter o) => o.stage != stage || o.mood != mood || o.season != season || o.apples != apples || o.flowers != flowers;
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

/// The little pictures on lesson cards, drawn like Fidan: flat shapes, no
/// outlines, a friendly face where there is someone to have one.
enum LessonArt {
  phone, smoke, satellite, truck, house, ember, match, grill, wind, calendar,
  rings, roots, seed, leaf, rain, pine, cone, squirrel, bird, bee, bat, worm,
  bear, hedgehog, sprout, burned, bag, family, exit, quake, flood, mask,
}

/// A drawing on a soft coloured disc.
class LessonArtView extends StatelessWidget {
  final LessonArt art;
  final double size;
  const LessonArtView(this.art, {super.key, this.size = 170});

  static const _discs = [Color(0xFFD8F1FF), Color(0xFFFFE9C7), Color(0xFFDFF3C9), Color(0xFFFFDDE3), Color(0xFFE8E0FF)];

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: _discs[art.index % _discs.length], shape: BoxShape.circle),
      padding: EdgeInsets.all(size * 0.13),
      child: CustomPaint(painter: LessonArtPainter(art)),
    ),
  );
}

class LessonArtPainter extends CustomPainter {
  final LessonArt art;
  LessonArtPainter(this.art);

  Paint _p(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  Paint _line(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  static const _ink = Color(0xFF2A2A22);
  static const _wood = Color(0xFF8A5A33);
  static const _green = Color(0xFF58B22E);
  static const _lime = Color(0xFF86D047);
  static const _orange = Color(0xFFFF8A3C);
  static const _yellow = Color(0xFFF7C72F);
  static const _red = Color(0xFFE5392F);
  static const _grey = Color(0xFF9AA3A8);
  static const _blue = Color(0xFF4AA8E8);

  void _r(Canvas c, double x, double y, double w, double h, double r, Color col) => c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)), _p(col));

  void _o(Canvas c, double x, double y, double w, double h, Color col) => c.drawOval(Rect.fromCenter(center: Offset(x, y), width: w, height: h), _p(col));

  void _dot(Canvas c, double x, double y, double r, Color col) => c.drawCircle(Offset(x, y), r, _p(col));

  /// Two eyes and a smile, the same as on Fidan.
  void _smile(Canvas c, double x, double y, double k) {
    _dot(c, x - 12 * k, y, 4.4 * k, _ink);
    _dot(c, x + 12 * k, y, 4.4 * k, _ink);
    _dot(c, x - 10.6 * k, y - 1.6 * k, 1.5 * k, Colors.white);
    _dot(c, x + 13.4 * k, y - 1.6 * k, 1.5 * k, Colors.white);
    c.drawPath(Path()..moveTo(x - 6 * k, y + 8 * k)..quadraticBezierTo(x, y + 14 * k, x + 6 * k, y + 8 * k), _line(_ink, 2.8 * k));
  }

  void _flame(Canvas c, double x, double y, double k, Color col) => c.drawPath(
    Path()
      ..moveTo(x, y - 34 * k)
      ..quadraticBezierTo(x + 26 * k, y - 8 * k, x + 18 * k, y + 14 * k)
      ..quadraticBezierTo(x, y + 28 * k, x - 18 * k, y + 14 * k)
      ..quadraticBezierTo(x - 26 * k, y - 8 * k, x, y - 34 * k)
      ..close(),
    _p(col),
  );

  void _puff(Canvas c, double x, double y, double k, Color col) {
    for (final (dx, dy, r) in const [(-22.0, 6.0, 18.0), (0.0, -6.0, 24.0), (24.0, 6.0, 17.0)]) {
      _dot(c, x + dx * k, y + dy * k, r * k, col);
    }
  }

  void _leaf(Canvas c, double x, double y, double angle, double len, Color col) {
    c.save();
    c.translate(x, y);
    c.rotate(angle);
    c.drawPath(Path()..moveTo(0, 0)..quadraticBezierTo(len * 0.5, -len * 0.5, len, 0)..quadraticBezierTo(len * 0.5, len * 0.45, 0, 0), _p(col));
    c.restore();
  }

  void _pine(Canvas c, double x, double base, double k, Color col) {
    _r(c, x - 6 * k, base - 26 * k, 12 * k, 26 * k, 3 * k, _wood);
    for (var i = 0; i < 3; i++) {
      final y = base - 22 * k - i * 28 * k;
      final w = (56 - i * 12) * k;
      c.drawPath(Path()..moveTo(x, y - 46 * k)..lineTo(x + w, y)..lineTo(x - w, y)..close(), _p(col));
    }
  }

  void _sproutAt(Canvas c, double x, double base, double k) {
    c.drawLine(Offset(x, base), Offset(x, base - 42 * k), _line(_lime, 6 * k));
    _leaf(c, x, base - 38 * k, -0.7, 36 * k, _green);
    _leaf(c, x, base - 34 * k, math.pi + 0.7, 36 * k, _lime);
  }

  @override
  void paint(Canvas c, Size size) {
    final s = size.shortestSide / 200;
    c.save();
    c.translate((size.width - 200 * s) / 2, (size.height - 200 * s) / 2);
    c.scale(s);
    switch (art) {
      case LessonArt.phone:
        _r(c, 58, 18, 84, 164, 16, const Color(0xFF37474F));
        _r(c, 66, 34, 68, 124, 6, Colors.white);
        for (var y = 0; y < 3; y++) {
          for (var x = 0; x < 3; x++) {
            _dot(c, 80 + x * 20.0, 62 + y * 22.0, 7, x == 1 && y == 2 ? _red : const Color(0xFFCFD8DC));
          }
        }
        _r(c, 78, 134, 44, 14, 7, _green);
      case LessonArt.smoke:
        _puff(c, 100, 62, 1.25, _grey);
        _puff(c, 96, 104, 0.8, const Color(0xFFBFC6CA));
        _flame(c, 100, 158, 0.6, _orange);
        _o(c, 100, 184, 150, 18, _lime);
      case LessonArt.satellite:
        _r(c, 80, 62, 40, 40, 6, const Color(0xFFB0BEC5));
        _r(c, 20, 70, 54, 24, 4, _blue);
        _r(c, 126, 70, 54, 24, 4, _blue);
        c.drawLine(const Offset(100, 62), const Offset(100, 40), _line(const Color(0xFF607D8B), 4));
        _dot(c, 100, 36, 6, _red);
        _smile(c, 100, 80, 0.62);
        _puff(c, 100, 158, 1.3, Colors.white);
        _puff(c, 44, 170, 0.7, const Color(0xFFE3EAEE));
      case LessonArt.truck:
        _r(c, 16, 92, 114, 58, 8, _red);
        _r(c, 130, 108, 54, 42, 8, const Color(0xFFD62C22));
        _r(c, 142, 116, 32, 18, 4, const Color(0xFFBEE3F8));
        c.drawLine(const Offset(24, 82), const Offset(116, 72), _line(const Color(0xFFCFD8DC), 8));
        for (final x in [48.0, 150.0]) {
          _dot(c, x, 152, 16, _ink);
          _dot(c, x, 152, 7, const Color(0xFFCFD8DC));
        }
        _dot(c, 74, 84, 7, _blue);
      case LessonArt.house:
        _r(c, 42, 90, 116, 88, 6, const Color(0xFFFFE0B2));
        c.drawPath(Path()..moveTo(26, 94)..lineTo(100, 28)..lineTo(174, 94)..close(), _p(_red));
        _r(c, 88, 126, 28, 52, 4, _wood);
        _r(c, 54, 110, 24, 24, 3, _blue);
        _r(c, 126, 110, 24, 24, 3, _blue);
        _smile(c, 100, 104, 0.5);
      case LessonArt.ember:
        _o(c, 100, 162, 150, 34, const Color(0xFF6D6D6D));
        _flame(c, 100, 104, 1.4, _orange);
        _flame(c, 100, 118, 0.85, _yellow);
        for (final (x, y) in const [(40.0, 60.0), (160.0, 44.0), (148.0, 92.0), (52.0, 106.0)]) {
          _dot(c, x, y, 5, _orange);
        }
      case LessonArt.match:
        c.save();
        c.translate(100, 110);
        c.rotate(0.45);
        _r(c, -7, -36, 14, 118, 4, const Color(0xFFE9C89B));
        _o(c, 0, -48, 28, 34, _red);
        c.restore();
        _flame(c, 80, 48, 0.72, _orange);
        _flame(c, 80, 54, 0.4, _yellow);
      case LessonArt.grill:
        _flame(c, 76, 56, 0.55, _orange);
        _flame(c, 124, 62, 0.45, _yellow);
        c.drawPath(Path()..moveTo(32, 84)..lineTo(168, 84)..quadraticBezierTo(158, 148, 100, 148)..quadraticBezierTo(42, 148, 32, 84)..close(), _p(_ink));
        for (var i = 0; i < 6; i++) {
          _dot(c, 54 + i * 18.0, 98, 8, i.isOdd ? _orange : const Color(0xFF5A5A5A));
        }
        c.drawLine(const Offset(70, 148), const Offset(54, 188), _line(_ink, 7));
        c.drawLine(const Offset(130, 148), const Offset(146, 188), _line(_ink, 7));
      case LessonArt.wind:
        final w = _line(_blue, 9);
        c.drawPath(Path()..moveTo(18, 74)..lineTo(120, 74)..arcToPoint(const Offset(120, 40), radius: const Radius.circular(17), clockwise: false), w);
        c.drawPath(Path()..moveTo(18, 104)..lineTo(158, 104)..arcToPoint(const Offset(158, 138), radius: const Radius.circular(17)), w);
        c.drawPath(Path()..moveTo(18, 134)..lineTo(92, 134), w);
        _leaf(c, 138, 58, -0.5, 30, _green);
        _leaf(c, 60, 156, 0.4, 30, _lime);
      case LessonArt.calendar:
        _r(c, 28, 40, 144, 136, 14, Colors.white);
        _r(c, 28, 40, 144, 38, 14, _red);
        _r(c, 60, 24, 14, 34, 6, _ink);
        _r(c, 126, 24, 14, 34, 6, _ink);
        for (var y = 0; y < 2; y++) {
          for (var x = 0; x < 3; x++) {
            _r(c, 48 + x * 40.0, 92 + y * 38.0, 24, 24, 5, x == 1 && y == 0 ? _green : const Color(0xFFDDE8D2));
          }
        }
      case LessonArt.rings:
        _dot(c, 100, 100, 82, const Color(0xFF6F4526));
        _dot(c, 100, 100, 74, const Color(0xFFE8C48C));
        for (final (i, r) in const [62.0, 48.0, 36.0, 24.0, 12.0].indexed) {
          c.drawCircle(const Offset(100, 100), r, _line(i.isEven ? const Color(0xFFB98A4E) : const Color(0xFFCCA263), 4));
        }
        _smile(c, 100, 98, 0.62);
      case LessonArt.roots:
        _r(c, 88, 26, 24, 74, 6, _wood);
        _r(c, 10, 96, 180, 88, 16, const Color(0xFFC49A6C));
        _o(c, 100, 26, 96, 54, _green);
        final root = _line(_wood, 7);
        c.drawLine(const Offset(100, 98), const Offset(100, 168), root);
        for (final (x, y) in const [(30.0, 128.0), (170.0, 128.0), (56.0, 164.0), (146.0, 164.0)]) {
          c.drawPath(Path()..moveTo(100, 104)..quadraticBezierTo((100 + x) / 2, y - 16, x, y), root);
        }
      case LessonArt.seed:
        _o(c, 100, 124, 92, 104, const Color(0xFFB87A40));
        c.drawPath(Path()..moveTo(52, 92)..quadraticBezierTo(100, 30, 148, 92)..quadraticBezierTo(100, 108, 52, 92), _p(const Color(0xFF7A4E2A)));
        _r(c, 95, 34, 10, 26, 4, const Color(0xFF7A4E2A));
        _smile(c, 100, 128, 1);
      case LessonArt.leaf:
        _leaf(c, 24, 160, -0.78, 200, _green);
        _leaf(c, 54, 142, -0.8, 120, _lime);
        c.drawLine(const Offset(14, 186), const Offset(160, 40), _line(const Color(0xFF2F6B1A), 4));
      case LessonArt.rain:
        _puff(c, 100, 56, 1.4, const Color(0xFFD0DEE7));
        for (final (x, y) in const [(50.0, 104.0), (92.0, 118.0), (136.0, 104.0), (70.0, 150.0), (120.0, 156.0)]) {
          c.drawPath(Path()..moveTo(x, y - 18)..quadraticBezierTo(x + 14, y + 4, x, y + 10)..quadraticBezierTo(x - 14, y + 4, x, y - 18)..close(), _p(_blue));
        }
      case LessonArt.pine:
        _pine(c, 100, 188, 1.15, _green);
      case LessonArt.cone:
        c.drawOval(Rect.fromCenter(center: const Offset(100, 106), width: 108, height: 150), _p(const Color(0xFF8A5A33)));
        for (var y = 0; y < 5; y++) {
          for (var x = 0; x < 3; x++) {
            _o(c, 68 + x * 32.0, 54 + y * 26.0, 30, 22, const Color(0xFFB87A40));
          }
        }
        _r(c, 92, 12, 16, 26, 5, _wood);
        _smile(c, 100, 104, 0.8);
      case LessonArt.squirrel:
        c.drawPath(Path()..moveTo(120, 160)..quadraticBezierTo(196, 150, 170, 76)..quadraticBezierTo(150, 50, 134, 86)..quadraticBezierTo(160, 118, 120, 134)..close(), _p(const Color(0xFFC96A2B)));
        _o(c, 88, 132, 86, 92, const Color(0xFFD97A36));
        _o(c, 78, 70, 74, 66, const Color(0xFFD97A36));
        c.drawPath(Path()..moveTo(54, 44)..lineTo(58, 18)..lineTo(74, 38)..close(), _p(const Color(0xFFC96A2B)));
        c.drawPath(Path()..moveTo(90, 38)..lineTo(102, 18)..lineTo(104, 46)..close(), _p(const Color(0xFFC96A2B)));
        _smile(c, 78, 68, 0.92);
        _o(c, 88, 142, 42, 50, const Color(0xFFF2D5B4));
      case LessonArt.bird:
        _o(c, 96, 112, 118, 92, _blue);
        c.drawPath(Path()..moveTo(32, 112)..quadraticBezierTo(6, 150, 18, 166)..quadraticBezierTo(46, 158, 58, 136)..close(), _p(const Color(0xFF3D8CC4)));
        c.drawPath(Path()..moveTo(150, 92)..lineTo(190, 104)..lineTo(150, 116)..close(), _p(_yellow));
        _o(c, 92, 118, 56, 38, const Color(0xFFCDEBFF));
        _smile(c, 112, 92, 0.9);
      case LessonArt.bee:
        _o(c, 58, 74, 64, 80, const Color(0xCCCDEBFF));
        _o(c, 132, 66, 64, 86, const Color(0xCCCDEBFF));
        _o(c, 100, 122, 124, 90, _yellow);
        for (final x in [84.0, 116.0]) {
          _r(c, x - 7, 78, 14, 88, 4, _ink);
        }
        _smile(c, 62, 118, 0.74);
      case LessonArt.bat:
        c.drawPath(Path()..moveTo(100, 84)..quadraticBezierTo(62, 56, 12, 62)..quadraticBezierTo(40, 88, 28, 124)..quadraticBezierTo(58, 106, 72, 132)..quadraticBezierTo(90, 118, 100, 136)..close(), _p(const Color(0xFF5A4B6B)));
        c.drawPath(Path()..moveTo(100, 84)..quadraticBezierTo(138, 56, 188, 62)..quadraticBezierTo(160, 88, 172, 124)..quadraticBezierTo(142, 106, 128, 132)..quadraticBezierTo(110, 118, 100, 136)..close(), _p(const Color(0xFF5A4B6B)));
        _o(c, 100, 100, 58, 64, const Color(0xFF443755));
        c.drawPath(Path()..moveTo(78, 76)..lineTo(82, 44)..lineTo(96, 68)..close(), _p(const Color(0xFF443755)));
        c.drawPath(Path()..moveTo(122, 76)..lineTo(118, 44)..lineTo(104, 68)..close(), _p(const Color(0xFF443755)));
        _dot(c, 88, 96, 6, Colors.white);
        _dot(c, 112, 96, 6, Colors.white);
      case LessonArt.worm:
        _r(c, 10, 96, 180, 92, 16, const Color(0xFFC49A6C));
        _o(c, 100, 92, 190, 20, _lime);
        c.drawPath(Path()..moveTo(50, 158)..quadraticBezierTo(84, 108, 112, 142)..quadraticBezierTo(138, 170, 158, 122), _line(const Color(0xFFF2A0A0), 20));
        _dot(c, 158, 118, 14, const Color(0xFFF2A0A0));
        _smile(c, 158, 116, 0.58);
      case LessonArt.bear:
        _dot(c, 58, 58, 22, const Color(0xFF8A5A33));
        _dot(c, 142, 58, 22, const Color(0xFF8A5A33));
        _dot(c, 100, 104, 66, const Color(0xFFA06A3D));
        _o(c, 100, 122, 50, 40, const Color(0xFFE7C39A));
        _dot(c, 100, 112, 7, _ink);
        _smile(c, 100, 96, 1);
      case LessonArt.hedgehog:
        c.drawPath(Path()..moveTo(30, 150)..lineTo(38, 110)..lineTo(50, 120)..lineTo(58, 82)..lineTo(72, 100)..lineTo(86, 66)..lineTo(100, 92)..lineTo(120, 68)..lineTo(128, 98)..lineTo(150, 88)..lineTo(150, 150)..close(), _p(const Color(0xFF6D4C33)));
        _o(c, 138, 136, 86, 66, const Color(0xFFE7C39A));
        _dot(c, 178, 136, 7, _ink);
        _smile(c, 144, 128, 0.72);
      case LessonArt.sprout:
        _o(c, 100, 168, 160, 36, const Color(0xFF8D6E55));
        _sproutAt(c, 100, 168, 2.2);
        _smile(c, 100, 150, 0.6);
      case LessonArt.burned:
        _o(c, 100, 172, 164, 30, const Color(0xFF5A5A5A));
        _r(c, 82, 66, 36, 110, 6, const Color(0xFF3C3633));
        c.drawLine(const Offset(100, 100), const Offset(56, 68), _line(const Color(0xFF3C3633), 10));
        c.drawLine(const Offset(100, 84), const Offset(146, 56), _line(const Color(0xFF3C3633), 10));
        _sproutAt(c, 144, 172, 1.1);
      case LessonArt.bag:
        _r(c, 42, 66, 116, 118, 22, _red);
        c.drawArc(const Rect.fromLTWH(70, 26, 60, 72), math.pi, math.pi, false, _line(const Color(0xFFB3261E), 12));
        _r(c, 62, 110, 76, 56, 10, const Color(0xFFFFC7C2));
        _r(c, 94, 120, 12, 36, 2, _red);
        _r(c, 82, 132, 36, 12, 2, _red);
      case LessonArt.family:
        for (final (x, y, r, col) in const [(62.0, 92.0, 28.0, Color(0xFF4AA8E8)), (138.0, 92.0, 28.0, Color(0xFFFF8A9F)), (100.0, 128.0, 22.0, Color(0xFF58B22E))]) {
          _r(c, x - r, y + r - 6, r * 2, 80, r, col);
          _dot(c, x, y, r, const Color(0xFFFFD8B5));
          _smile(c, x, y - 2, r / 30);
        }
      case LessonArt.exit:
        _r(c, 40, 20, 100, 164, 8, _wood);
        _r(c, 52, 32, 76, 152, 4, const Color(0xFFBEE3F8));
        _dot(c, 118, 106, 6, _yellow);
        c.drawLine(const Offset(106, 106), const Offset(186, 106), _line(_green, 14));
        c.drawPath(Path()..moveTo(160, 80)..lineTo(190, 106)..lineTo(160, 132), _line(_green, 14));
      case LessonArt.quake:
        c.save();
        c.translate(100, 100);
        c.rotate(-0.1);
        c.translate(-100, -100);
        _r(c, 54, 92, 92, 76, 6, const Color(0xFFFFE0B2));
        c.drawPath(Path()..moveTo(38, 96)..lineTo(100, 40)..lineTo(162, 96)..close(), _p(_red));
        _smile(c, 100, 124, 0.7);
        c.restore();
        c.drawPath(Path()..moveTo(18, 178)..lineTo(52, 160)..lineTo(86, 182)..lineTo(120, 160)..lineTo(154, 182)..lineTo(186, 164), _line(const Color(0xFF6D4C33), 7));
      case LessonArt.flood:
        _r(c, 58, 40, 84, 80, 6, const Color(0xFFFFE0B2));
        c.drawPath(Path()..moveTo(42, 44)..lineTo(100, 8)..lineTo(158, 44)..close(), _p(_red));
        for (var i = 0; i < 3; i++) {
          final y = 118.0 + i * 24;
          final p = Path()..moveTo(8, y);
          for (var x = 8.0; x < 190; x += 36) {
            p.quadraticBezierTo(x + 18, y - 18, x + 36, y);
          }
          c.drawPath(p, _line(i == 0 ? const Color(0xFF7CC8FF) : _blue, 12));
        }
      case LessonArt.mask:
        _dot(c, 100, 96, 72, const Color(0xFFFFD8B5));
        c.drawPath(Path()..moveTo(30, 88)..lineTo(170, 88)..lineTo(156, 150)..quadraticBezierTo(100, 174, 44, 150)..close(), _p(Colors.white));
        for (final (x, y) in const [(56.0, 106.0), (144.0, 106.0)]) {
          c.drawLine(Offset(x, y), Offset(x > 100 ? 178 : 22, y - 18), _line(const Color(0xFFB0BEC5), 4));
        }
        _dot(c, 80, 72, 6, _ink);
        _dot(c, 120, 72, 6, _ink);
    }
    c.restore();
  }

  @override
  bool shouldRepaint(LessonArtPainter o) => o.art != art;
}
