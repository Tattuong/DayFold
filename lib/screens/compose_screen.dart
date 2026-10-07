import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../models/ticket.dart';
import '../providers/ticket_provider.dart';
import '../widgets/app_toast.dart';
import '../widgets/app_ui.dart';
import '../widgets/ticket_face.dart';
import 'ticket_screen.dart';

class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key, this.style, this.existing});

  final TicketStyle? style;
  final DayTicket? existing;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  late final TextEditingController _line;
  late final TextEditingController _place;
  late final TextEditingController _number;
  late Mood _mood;
  late TicketStyle _style;
  late TimeOfDay _time;
  double _pull = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _line = TextEditingController(text: existing?.line ?? '');
    _place = TextEditingController(text: existing?.place ?? '');
    _number = TextEditingController(text: existing?.specialNumber ?? '');
    _mood = existing?.mood ?? Mood.yen;
    _style = existing?.style ?? widget.style ?? TicketStyle.receipt;
    _time = _parseTime(existing?.timeLabel) ?? const TimeOfDay(hour: 17, minute: 40);
  }

  TimeOfDay? _parseTime(String? label) {
    if (label == null || !label.contains(':')) return null;
    final parts = label.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  @override
  void dispose() {
    _line.dispose();
    _place.dispose();
    _number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final time = '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
    final paper = _paper(_style);
    return Scaffold(
      backgroundColor: Color.alphaBlend(paper.withValues(alpha: 0.55), AppColors.canvasOf(context)),
      appBar: AppBar(
        centerTitle: true,
        title: Text(_styleTitle(_style)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}', style: AppTypography.labelBold(context: context))),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        children: [
          _StylePreview(style: _style, paper: paper, title: _styleTitle(_style), hint: _styleHint(_style)),
          const SizedBox(height: 16),
          Text('Today, you feel...', style: AppTypography.labelBold(context: context)),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final mood in Mood.values) ...[
                Expanded(child: _MoodButton(mood: mood, selected: _mood == mood, onTap: () => setState(() => _mood = mood))),
                if (mood != Mood.bietOn) const SizedBox(width: 8),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Text('One thing to keep', style: AppTypography.labelBold(context: context)),
          const SizedBox(height: 8),
          TextField(
            controller: _line,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'This afternoon, I walked home...', filled: true),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _place,
                  decoration: const InputDecoration(labelText: 'Where?', prefixIcon: Icon(Icons.place_outlined), filled: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'When?', prefixIcon: Icon(Icons.schedule), filled: true),
                    child: Text(time, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _number,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'A special number', filled: true),
          ),
          const SizedBox(height: 18),
          Text('Choose a ticket', style: AppTypography.labelBold(context: context)),
          const SizedBox(height: 8),
          SizedBox(
            height: 118,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final style in TicketStyle.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => setState(() => _style = style),
                      child: Container(
                        width: 84,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceOf(context),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _style == style ? AppColors.primaryOf(context) : Colors.transparent, width: 2),
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Icon(Icons.check_circle, size: 16, color: _style == style ? AppColors.primaryOf(context) : Colors.transparent),
                            ),
                            TicketSketch(style: style, size: 36),
                            const Spacer(),
                            Text(_short(style), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
            ),
          ),
          Listener(
            onPointerMove: (event) {
              if (event.delta.dy <= 0) return;
              setState(() => _pull = (_pull + event.delta.dy).clamp(0, 90));
              if (_pull > 36 && _pull < 44) HapticFeedback.selectionClick();
            },
            onPointerUp: (_) {
              final shouldPrint = _pull > 56;
              setState(() => _pull = 0);
              if (shouldPrint) _print();
            },
            child: MiniPrinter(pull: _pull),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: SizedBox(
              height: 54,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _busy ? null : _print,
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print ticket', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _styleTitle(TicketStyle style) => switch (style) {
        TicketStyle.receipt => 'Receipt',
        TicketStyle.train => 'Train ticket',
        TicketStyle.boarding => 'Boarding pass',
        TicketStyle.postcard => 'Postcard',
      };

  String _styleHint(TicketStyle style) => switch (style) {
        TicketStyle.receipt => 'Thermal paper, one short line.',
        TicketStyle.train => 'One afternoon\'s journey.',
        TicketStyle.boarding => 'One gate, one number.',
        TicketStyle.postcard => 'A note back to yourself.',
      };

  Color _paper(TicketStyle style) => switch (style) {
        TicketStyle.receipt => const Color(0xFFE7F0DC),
        TicketStyle.train => const Color(0xFFF6EBD4),
        TicketStyle.boarding => const Color(0xFFF3EFE6),
        TicketStyle.postcard => const Color(0xFFF8E4DC),
      };

  String _short(TicketStyle style) => switch (style) {
        TicketStyle.receipt => 'Receipt',
        TicketStyle.train => 'Train',
        TicketStyle.boarding => 'Boarding',
        TicketStyle.postcard => 'Postcard',
      };

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    setState(() => _time = picked);
  }

  Future<void> _print() async {
    if (_busy) return;
    final line = _line.text.trim();
    if (line.isEmpty) {
      AppToast.show(context, title: 'Write one thing worth keeping');
      return;
    }
    setState(() => _busy = true);
    HapticFeedback.lightImpact();
    final board = context.read<TicketProvider>();
    final time = '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
    final existing = widget.existing;
    DayTicket? ticket;
    if (existing == null) {
      ticket = await board.printNew(
        date: DateTime.now(),
        mood: _mood,
        line: line,
        place: _place.text,
        timeLabel: time,
        specialNumber: _number.text,
        style: _style,
      );
    } else {
      existing.mood = _mood;
      existing.line = line;
      existing.place = _place.text.trim();
      existing.timeLabel = time;
      existing.specialNumber = _number.text.trim();
      existing.style = _style;
      await board.update(existing);
      ticket = existing;
    }
    if (!mounted) return;
    setState(() => _busy = false);
    if (ticket == null) {
      AppToast.show(context, title: 'Unlock DayFold Pro to keep more tickets');
      return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TicketScreen(ticketId: ticket!.id)));
  }
}

class _StylePreview extends StatelessWidget {
  const _StylePreview({required this.style, required this.paper, required this.title, required this.hint});

  final TicketStyle style;
  final Color paper;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1C1917).withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          TicketSketch(style: style, size: 78),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.title(size: 18, context: context)),
                const SizedBox(height: 4),
                Text(hint, style: AppTypography.body(size: 13, context: context)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodButton extends StatelessWidget {
  const _MoodButton({required this.mood, required this.selected, required this.onTap});

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (mood) {
      Mood.vui => Icons.sentiment_satisfied_alt_outlined,
      Mood.yen => Icons.spa_outlined,
      Mood.met => Icons.bedtime_outlined,
      Mood.bietOn => Icons.favorite_border,
    };
    final name = switch (mood) {
      Mood.vui => 'Glad',
      Mood.yen => 'Calm',
      Mood.met => 'Tired',
      Mood.bietOn => 'Grateful',
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE7F0DC) : AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFF6E8B4E) : Colors.transparent),
        ),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: selected ? const Color(0xFF3E6B16) : AppColors.inkOf(context)),
                if (selected)
                  const Positioned(
                    right: -6,
                    top: -4,
                    child: Icon(Icons.check_circle, size: 14, color: Color(0xFF3E6B16)),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: selected ? const Color(0xFF3E6B16) : AppColors.inkOf(context))),
          ],
        ),
      ),
    );
  }
}
