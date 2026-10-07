import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../core/services/storage_service.dart';
import '../models/ticket.dart';
import 'shop_provider.dart';

class TicketProvider extends ChangeNotifier {
  static const _key = 'df_tickets';

  final ShopProvider shop;
  final List<DayTicket> tickets = [];

  TicketProvider(this.shop);

  int get count => tickets.length;

  Future<void> init() async {
    tickets.clear();
    final raw = await StorageService.instance.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List;
      tickets.addAll(list.map((item) => DayTicket.fromJson(Map<String, dynamic>.from(item as Map))));
    }
    notifyListeners();
  }

  List<DayTicket> inMonth(DateTime month) => ticketsInMonth(tickets, month);

  DayTicket? newestOn(DateTime day) {
    DayTicket? found;
    for (final ticket in tickets) {
      if (!_sameDay(ticket.date, day)) continue;
      if (found == null || ticket.serial > found.serial) found = ticket;
    }
    return found;
  }

  Future<DayTicket?> printNew({
    required DateTime date,
    required Mood mood,
    required String line,
    required String place,
    required String timeLabel,
    required String specialNumber,
    required TicketStyle style,
  }) async {
    if (count >= shop.maxArchive) return null;
    final serial = tickets.fold<int>(0, (max, ticket) => ticket.serial > max ? ticket.serial : max) + 1;
    final ticket = DayTicket(
      id: const Uuid().v4(),
      date: date,
      mood: mood,
      line: line.trim(),
      place: place.trim(),
      timeLabel: timeLabel.trim(),
      specialNumber: specialNumber.trim(),
      style: style,
      serial: serial,
    );
    tickets.insert(0, ticket);
    await _reward(ticket);
    await _save();
    notifyListeners();
    return ticket;
  }

  Future<void> update(DayTicket ticket) async {
    await _save();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    tickets.removeWhere((ticket) => ticket.id == id);
    await _save();
    notifyListeners();
  }

  DayTicket? find(String id) {
    for (final ticket in tickets) {
      if (ticket.id == id) return ticket;
    }
    return null;
  }

  Future<void> _reward(DayTicket ticket) async {
    if (ticket.rewarded) return;
    ticket.rewarded = true;
    await shop.rewardForTicket();
  }

  Future<void> _save() async {
    await StorageService.instance.saveString(_key, jsonEncode([for (final ticket in tickets) ticket.toJson()]));
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
