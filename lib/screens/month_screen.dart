import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import '../widgets/app_ui.dart';

class MonthScreen extends StatefulWidget {
  const MonthScreen({super.key, required this.month});

  final DateTime month;

  @override
  State<MonthScreen> createState() => _MonthScreenState();
}

class _MonthScreenState extends State<MonthScreen> {
  final _boundary = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final items = context.watch<TicketProvider>().inMonth(widget.month);
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(monthTitle(widget.month))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('Fold this month\'s tickets into one sheet.', style: AppTypography.body(size: 15, context: context)),
          const SizedBox(height: 12),
          RepaintBoundary(
            key: _boundary,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: const Color(0xFFFBF6EE), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('DAYFOLD', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2)),
                  Text(monthTitle(widget.month).toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  if (items.isEmpty) const Text('This month is still empty.', textAlign: TextAlign.center),
                  for (final ticket in items) ...[
                    Text(ticket.dateDot, style: const TextStyle(fontWeight: FontWeight.w800)),
                    Text(ticket.line),
                    Text(ticket.moodLabel, style: const TextStyle(fontSize: 11, letterSpacing: 0.8, fontWeight: FontWeight.w700)),
                    const Divider(),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: items.isEmpty ? null : _share,
              icon: const Icon(Icons.ios_share),
              label: const Text('Share summary'),
              style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26))),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _share() async {
    final boundary = _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    final image = await boundary.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) return;
    await Share.shareXFiles([XFile.fromData(data.buffer.asUint8List(), mimeType: 'image/png', name: 'dayfold-thang.png')]);
  }
}
