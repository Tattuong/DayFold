import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/ticket.dart';

class TicketFace extends StatelessWidget {
  const TicketFace({super.key, required this.ticket, this.compact = false});

  final DayTicket ticket;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return ClipPath(
        clipper: const _StubClipper(),
        child: ColoredBox(
          color: ticket.paper,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 14, 14),
            child: _Compact(ticket: ticket),
          ),
        ),
      );
    }
    return CustomPaint(
      painter: _ZigzagPainter(paper: ticket.paper),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 28, 22, 28),
        child: _Full(ticket: ticket),
      ),
    );
  }
}

class _Compact extends StatelessWidget {
  const _Compact({required this.ticket});

  final DayTicket ticket;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(ticket.dateDot, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticket.line, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, height: 1.25)),
              const SizedBox(height: 4),
              Text(ticket.moodLabel, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 0.6)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TicketSketch(style: ticket.style, size: 54),
      ],
    );
  }
}

class _Full extends StatelessWidget {
  const _Full({required this.ticket});

  final DayTicket ticket;

  @override
  Widget build(BuildContext context) {
    final number = ticket.specialNumber.isEmpty ? ticket.serialLabel : ticket.specialNumber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('DAYFOLD', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2.4, fontSize: 18)),
        const SizedBox(height: 4),
        Text(ticket.styleName.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 12)),
        const SizedBox(height: 14),
        const _Dash(),
        const SizedBox(height: 12),
        Text(ticket.dateLong, textAlign: TextAlign.center, style: const TextStyle(letterSpacing: 1.4, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        const Text('MOOD', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, letterSpacing: 1.6, fontWeight: FontWeight.w700)),
        Text(ticket.moodLabel, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: 1)),
        const SizedBox(height: 12),
        const _Dash(),
        const SizedBox(height: 14),
        Text(ticket.line, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
        Center(child: TicketSketch(style: ticket.style, size: 120)),
        const SizedBox(height: 12),
        if (ticket.footer.isNotEmpty) Text(ticket.footer, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text('NO. $number', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.1)),
        const SizedBox(height: 12),
        const Center(child: _Stamp()),
      ],
    );
  }
}

class _Dash extends StatelessWidget {
  const _Dash();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 8).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (var i = 0; i < count; i++) Container(width: 4, height: 1.2, color: const Color(0xFF1C1917))],
        );
      },
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.08,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFC23B32), width: 2)),
        child: const Text('KEPT', style: TextStyle(color: Color(0xFFC23B32), fontWeight: FontWeight.w900, letterSpacing: 1)),
      ),
    );
  }
}

class TicketSketch extends StatelessWidget {
  const TicketSketch({super.key, required this.style, required this.size, this.sunset = false});

  final TicketStyle style;
  final double size;
  final bool sunset;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size * 0.72), painter: _SketchPainter(style, sunset: sunset));
  }
}

class _SketchPainter extends CustomPainter {
  _SketchPainter(this.style, {this.sunset = false});

  final TicketStyle style;
  final bool sunset;

  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()
      ..color = const Color(0xFF1C1917)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    if (sunset) {
      final sun = Offset(size.width * 0.5, size.height * 0.42);
      canvas.drawCircle(sun, size.width * 0.16, ink);
      canvas.drawLine(Offset(0, size.height * 0.62), Offset(size.width, size.height * 0.62), ink);
      canvas.drawLine(Offset(size.width * 0.08, size.height * 0.74), Offset(size.width * 0.92, size.height * 0.74), ink);
      canvas.drawLine(Offset(size.width * 0.2, size.height * 0.86), Offset(size.width * 0.8, size.height * 0.86), ink);
      return;
    }
    switch (style) {
      case TicketStyle.receipt:
        final stem = Offset(size.width * 0.55, size.height * 0.9);
        canvas.drawLine(stem, Offset(size.width * 0.48, size.height * 0.35), ink);
        canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.38, size.height * 0.42), width: size.width * 0.28, height: size.height * 0.16), ink);
        canvas.drawOval(Rect.fromCenter(center: Offset(size.width * 0.62, size.height * 0.32), width: size.width * 0.22, height: size.height * 0.14), ink);
      case TicketStyle.train:
        final hill = Path()
          ..moveTo(0, size.height * 0.75)
          ..quadraticBezierTo(size.width * 0.3, size.height * 0.2, size.width * 0.55, size.height * 0.55)
          ..quadraticBezierTo(size.width * 0.75, size.height * 0.15, size.width, size.height * 0.6);
        canvas.drawPath(hill, ink);
        canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(size.width * 0.2, size.height * 0.62, size.width * 0.5, size.height * 0.18), const Radius.circular(3)), ink);
      case TicketStyle.boarding:
        for (var i = 0; i < 10; i++) {
          final w = 2.0 + (i % 3);
          canvas.drawRect(Rect.fromLTWH(i * (size.width / 11), size.height * 0.35, w, size.height * 0.4), Paint()..color = const Color(0xFF1C1917));
        }
      case TicketStyle.postcard:
        canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.45), size.width * 0.08, ink);
        canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.38), size.width * 0.1, ink);
        canvas.drawLine(Offset(size.width * 0.35, size.height * 0.55), Offset(size.width * 0.35, size.height * 0.85), ink);
        canvas.drawLine(Offset(size.width * 0.55, size.height * 0.5), Offset(size.width * 0.58, size.height * 0.88), ink);
    }
  }

  @override
  bool shouldRepaint(covariant _SketchPainter oldDelegate) => oldDelegate.style != style || oldDelegate.sunset != sunset;
}

class _StubClipper extends CustomClipper<Path> {
  const _StubClipper();

  @override
  Path getClip(Size size) {
    final body = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(14)));
    final notch = Path()..addOval(Rect.fromCircle(center: Offset(0, size.height / 2), radius: 9));
    return Path.combine(PathOperation.difference, body, notch);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ZigzagPainter extends CustomPainter {
  const _ZigzagPainter({required this.paper});

  final Color paper;

  @override
  void paint(Canvas canvas, Size size) {
    const tooth = 7.0;
    final path = Path()..moveTo(0, tooth);
    for (var x = 0.0; x < size.width; x += tooth * 2) {
      path.lineTo(math.min(x + tooth, size.width), 0);
      path.lineTo(math.min(x + tooth * 2, size.width), tooth);
    }
    path.lineTo(size.width, size.height - tooth);
    for (var x = size.width; x > 0; x -= tooth * 2) {
      path.lineTo(math.max(x - tooth, 0), size.height);
      path.lineTo(math.max(x - tooth * 2, 0), size.height - tooth);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = paper);
  }

  @override
  bool shouldRepaint(covariant _ZigzagPainter oldDelegate) => oldDelegate.paper != paper;
}

class MiniPrinter extends StatelessWidget {
  const MiniPrinter({super.key, required this.pull});

  final double pull;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 78,
            child: Transform.translate(
              offset: Offset(0, math.min(pull, 70)),
              child: Container(
                width: 200,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xFFFBF6EE), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFE4D8CC))),
                child: const Text('Pull down to print', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ),
          Positioned(
            top: 18,
            child: Container(
              width: 230,
              height: 78,
              decoration: BoxDecoration(color: const Color(0xFFE7E2DC), borderRadius: BorderRadius.circular(28)),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(width: 150, height: 8, margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: const Color(0xFFD5CFC8), borderRadius: BorderRadius.circular(4))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
