import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_strings.dart';
import '../core/navigation/app_navigator.dart';
import '../models/ticket.dart';
import '../providers/shop_provider.dart';
import '../providers/ticket_provider.dart';
import '../widgets/ad_banner_slot.dart';
import '../widgets/app_toast.dart';
import '../widgets/app_ui.dart';
import '../widgets/coin_balance_chip.dart';
import '../widgets/ticket_face.dart';
import 'compose_screen.dart';
import 'month_screen.dart';
import 'ticket_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(child: _tab == 0 ? _Collection(month: _month, onMonth: (month) => setState(() => _month = month), onPrint: _openCompose) : _Styles(onPick: _openCompose)),
            if (_tab == 0)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => _openCompose(),
                    icon: const Icon(Icons.print_outlined),
                    label: const Text('Print today', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  ),
                ),
              ),
            const AdBannerSlot(),
            _Nav(index: _tab, onSelect: (index) => setState(() => _tab = index)),
          ],
        ),
      ),
    );
  }

  Future<void> _openCompose({TicketStyle? style, DayTicket? ticket}) async {
    final shop = context.read<ShopProvider>();
    final board = context.read<TicketProvider>();
    if (ticket == null && board.count >= shop.maxArchive) {
      AppToast.show(context, title: AppStrings.t(context, 'needProFlows', {'n': '${shop.maxArchive}'}), actionLabel: 'Shop', onAction: AppTabs.goShop);
      return;
    }
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ComposeScreen(style: style, existing: ticket)));
  }
}

class _Collection extends StatelessWidget {
  const _Collection({required this.month, required this.onMonth, required this.onPrint});

  final DateTime month;
  final ValueChanged<DateTime> onMonth;
  final void Function({TicketStyle? style, DayTicket? ticket}) onPrint;

  @override
  Widget build(BuildContext context) {
    final board = context.watch<TicketProvider>();
    final items = board.inMonth(month);
    final now = DateTime.now();
    final showingNow = month.year == now.year && month.month == now.month;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.primaryOf(context), borderRadius: BorderRadius.circular(6)),
              child: Icon(Icons.confirmation_number_outlined, size: 16, color: AppColors.onPrimaryOf(context)),
            ),
            const SizedBox(width: 8),
            Text('DayFold', style: AppTypography.title(size: 22, context: context)),
            const Spacer(),
            const CoinBalanceChip(variant: CoinChipVariant.header),
            const SizedBox(width: 2),
            const IconButton(visualDensity: VisualDensity.compact, onPressed: AppTabs.goSettings, icon: Icon(Icons.settings_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Text('Fold a day.\nKeep one thing.', style: AppTypography.display(size: 30, context: context)),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () => onMonth(DateTime(month.year, month.month - 1)), icon: const Icon(Icons.chevron_left)),
            Text(monthTitle(month), style: AppTypography.labelBold(size: 16, context: context)),
            IconButton(onPressed: () => onMonth(DateTime(month.year, month.month + 1)), icon: const Icon(Icons.chevron_right)),
          ],
        ),
        if (showingNow) ...[
          const SizedBox(height: 8),
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.primaryOf(context), width: 1.4),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onPrint(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TODAY', style: AppTypography.labelBold(size: 11, context: context, color: AppColors.primaryOf(context))),
                        Text('${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}', style: AppTypography.title(size: 22, context: context)),
                      ],
                    ),
                    Container(width: 1, height: 42, margin: const EdgeInsets.symmetric(horizontal: 12), color: AppColors.primaryOf(context).withValues(alpha: 0.35)),
                    Expanded(child: Text('What do you want\nto keep?', style: AppTypography.body(size: 15, context: context, color: AppColors.inkOf(context)))),
                    CircleAvatar(radius: 16, backgroundColor: AppColors.primaryOf(context), child: Icon(Icons.add, size: 18, color: AppColors.onPrimaryOf(context))),
                  ],
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Row(
          children: [
            Text('Days you kept', style: AppTypography.labelBold(size: 16, context: context)),
            const Spacer(),
            Text('${items.length} ${items.length == 1 ? 'ticket' : 'tickets'}', style: AppTypography.body(size: 13, context: context)),
          ],
        ),
        if (items.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => MonthScreen(month: month))),
              child: const Text('Month summary'),
            ),
          ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('No tickets this month yet.', style: AppTypography.body(size: 15, context: context)),
          ),
        for (final ticket in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TicketScreen(ticketId: ticket.id))),
              child: TicketFace(ticket: ticket, compact: true),
            ),
          ),
      ],
    );
  }
}

class _Styles extends StatelessWidget {
  const _Styles({required this.onPick});

  final void Function({TicketStyle? style, DayTicket? ticket}) onPick;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      children: [
        Text('Ticket styles', style: AppTypography.display(size: 30, context: context)),
        const SizedBox(height: 8),
        Text('Pick a paper, then fold today into it.', style: AppTypography.body(size: 15, context: context)),
        const SizedBox(height: 16),
        for (final style in TicketStyle.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              tileColor: AppColors.surfaceOf(context),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              leading: TicketSketch(style: style, size: 48),
              title: Text(_styleTitle(style), style: AppTypography.labelBold(context: context)),
              subtitle: Text(_styleHint(style)),
              onTap: () => onPick(style: style),
            ),
          ),
      ],
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
}

class _Nav extends StatelessWidget {
  const _Nav({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    const labels = ['Collection', 'Styles'];
    const icons = [Icons.inventory_2_outlined, Icons.style_outlined];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 4),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: InkWell(
                  onTap: () => onSelect(i),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icons[i], color: index == i ? AppColors.primaryOf(context) : AppColors.mutedInk(context)),
                      const SizedBox(height: 2),
                      Text(labels[i], style: TextStyle(fontWeight: index == i ? FontWeight.w800 : FontWeight.w600, fontSize: 12, color: index == i ? AppColors.inkOf(context) : AppColors.mutedInk(context))),
                      const SizedBox(height: 4),
                      Container(height: 3, width: 28, decoration: BoxDecoration(color: index == i ? AppColors.primaryOf(context) : Colors.transparent, borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
