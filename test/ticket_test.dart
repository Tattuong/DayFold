import 'package:dayfold/models/ticket.dart';
import 'package:flutter_test/flutter_test.dart';

DayTicket _ticket(String id, DateTime date, {int serial = 1}) => DayTicket(
      id: id,
      date: date,
      mood: Mood.yen,
      line: id,
      style: TicketStyle.receipt,
      serial: serial,
    );

void main() {
  test('a month keeps only its own tickets, newest first', () {
    final items = ticketsInMonth([
      _ticket('early', DateTime(2026, 10, 3), serial: 1),
      _ticket('other', DateTime(2026, 9, 30), serial: 2),
      _ticket('late', DateTime(2026, 10, 6), serial: 3),
    ], DateTime(2026, 10));
    expect(items.map((ticket) => ticket.id), ['late', 'early']);
  });

  test('serial and mood labels match the ticket face', () {
    final ticket = _ticket('one', DateTime(2026, 10, 6), serial: 4)..mood = Mood.yen;
    expect(ticket.serialLabel, '004');
    expect(ticket.moodLabel, 'CALM');
    expect(ticket.dateDot, '06.10');
    expect(monthTitle(DateTime(2026, 10)), 'October 2026');
  });
}
