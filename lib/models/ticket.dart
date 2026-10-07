import 'package:flutter/material.dart';

enum Mood { vui, yen, met, bietOn }

enum TicketStyle { receipt, train, boarding, postcard }

class DayTicket {
  final String id;
  DateTime date;
  Mood mood;
  String line;
  String place;
  String timeLabel;
  String specialNumber;
  TicketStyle style;
  int serial;
  bool rewarded;

  DayTicket({
    required this.id,
    required this.date,
    required this.mood,
    required this.line,
    this.place = '',
    this.timeLabel = '',
    this.specialNumber = '',
    required this.style,
    required this.serial,
    this.rewarded = false,
  });

  String get serialLabel => serial.toString().padLeft(3, '0');

  String get moodLabel => switch (mood) {
        Mood.vui => 'GLAD',
        Mood.yen => 'CALM',
        Mood.met => 'TIRED',
        Mood.bietOn => 'GRATEFUL',
      };

  String get moodName => switch (mood) {
        Mood.vui => 'Glad',
        Mood.yen => 'Calm',
        Mood.met => 'Tired',
        Mood.bietOn => 'Grateful',
      };

  String get styleName => switch (style) {
        TicketStyle.receipt => 'Receipt',
        TicketStyle.train => 'Train ticket',
        TicketStyle.boarding => 'Boarding pass',
        TicketStyle.postcard => 'Postcard',
      };

  Color get paper => switch (style) {
        TicketStyle.receipt => const Color(0xFFE7F0DC),
        TicketStyle.train => const Color(0xFFF6EBD4),
        TicketStyle.boarding => const Color(0xFFF3EFE6),
        TicketStyle.postcard => const Color(0xFFF8E4DC),
      };

  String get dateDot => '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';

  String get dateLong => '${date.day.toString().padLeft(2, '0')} / ${date.month.toString().padLeft(2, '0')} / ${date.year}';

  String get footer {
    final bits = <String>[
      if (place.trim().isNotEmpty) place.trim(),
      if (timeLabel.trim().isNotEmpty) timeLabel.trim(),
    ];
    return bits.join(' · ');
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mood': mood.name,
        'line': line,
        'place': place,
        'timeLabel': timeLabel,
        'specialNumber': specialNumber,
        'style': style.name,
        'serial': serial,
        'rewarded': rewarded,
      };

  factory DayTicket.fromJson(Map<String, dynamic> json) => DayTicket(
        id: json['id'] as String? ?? '',
        date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
        mood: Mood.values.byName(json['mood'] as String? ?? 'yen'),
        line: json['line'] as String? ?? '',
        place: json['place'] as String? ?? '',
        timeLabel: json['timeLabel'] as String? ?? '',
        specialNumber: json['specialNumber'] as String? ?? '',
        style: TicketStyle.values.byName(json['style'] as String? ?? 'receipt'),
        serial: json['serial'] as int? ?? 1,
        rewarded: json['rewarded'] as bool? ?? false,
      );
}

String monthTitle(DateTime month) {
  const names = ['', 'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return '${names[month.month]} ${month.year}';
}

List<DayTicket> ticketsInMonth(List<DayTicket> tickets, DateTime month) {
  final copy = tickets.where((ticket) => ticket.date.year == month.year && ticket.date.month == month.month).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  return copy;
}
