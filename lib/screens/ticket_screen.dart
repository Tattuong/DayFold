import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/ticket_provider.dart';
import '../widgets/app_ui.dart';
import '../widgets/ticket_face.dart';
import 'compose_screen.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<TicketScreen> {
  final _boundary = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final ticket = context.watch<TicketProvider>().find(widget.ticketId);
    if (ticket == null) {
      return Scaffold(appBar: AppBar(title: const Text('Today\'s ticket')), body: const Center(child: Text('This ticket is gone.')));
    }
    return Scaffold(
      backgroundColor: const Color(0xFFE7E0D6),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Today\'s ticket'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            onSelected: (value) async {
              if (value == 'edit') {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ComposeScreen(existing: ticket)));
              }
              if (value == 'delete') {
                await context.read<TicketProvider>().delete(ticket.id);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete ticket')),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          RepaintBoundary(
            key: _boundary,
            child: TicketFace(ticket: ticket),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF3E6B16), size: 18),
              const SizedBox(width: 6),
              Text('Saved on this device', style: AppTypography.body(size: 14, context: context)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.ios_share),
              label: const Text('Share ticket', style: TextStyle(fontWeight: FontWeight.w800)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1C1917),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ComposeScreen(existing: ticket)));
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Future<void> _share() async {
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = _boundary.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null || !mounted) return;
      await Share.shareXFiles([XFile.fromData(data.buffer.asUint8List(), mimeType: 'image/png', name: 'dayfold.png')]);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Couldn\'t export the image. Try again.')));
    }
  }
}
