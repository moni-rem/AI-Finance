part of '../app/app.dart';

class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.entries,
    required this.budgets,
    required this.onAdd,
    required this.onOpenTransactions,
    required this.onOpenGoals,
    required this.onOpenAssistant,
  });

  final List<_MoneyEntry> entries;
  final List<_BudgetItem> budgets;
  final VoidCallback onAdd;
  final VoidCallback onOpenTransactions;
  final VoidCallback onOpenGoals;
  final ValueChanged<String> onOpenAssistant;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final todayLabel =
        '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
    final todayEntries = entries
        .where((entry) => entry.date.toLowerCase().startsWith('today'))
        .toList();
    final todaySpent = todayEntries
        .where((entry) => entry.amount < 0)
        .fold<double>(0, (sum, entry) => sum + entry.amount.abs());
    final todayIncome = todayEntries
        .where((entry) => entry.amount > 0)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final categoryTotals = <String, double>{};
    for (final entry in entries.where((entry) => entry.amount < 0)) {
      categoryTotals.update(
        entry.category,
        (amount) => amount + entry.amount.abs(),
        ifAbsent: () => entry.amount.abs(),
      );
    }
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = sortedCategories.isEmpty ? null : sortedCategories.first;
    final categoryBudgets = topCategory == null
        ? <_BudgetItem>[]
        : budgets.where((item) => item.title == topCategory.key).toList();
    final categoryBudget = categoryBudgets.isEmpty ? null : categoryBudgets.first;
    final coachMessage = topCategory == null
        ? 'Add a few expenses and I’ll help you spot a useful next step.'
        : categoryBudget == null
        ? 'Your largest recorded expense category is ${topCategory.key} at ${_money(topCategory.value)}.'
        : '${topCategory.key}: ${_money(categoryBudget.spent)} of ${_money(categoryBudget.limit)} used.';
    final coachPrompt = topCategory == null
        ? 'Give me a simple money check-in and suggest one useful next step based on my recorded transactions.'
        : 'Give me a simple plan for my ${topCategory.key} spending. I have recorded ${_money(topCategory.value)} in this category${categoryBudget == null ? '' : ' and my budget is ${_money(categoryBudget.limit)} with ${_money(categoryBudget.spent)} spent'}. Suggest one practical next step.';

    return _PageScroll(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good ${now.hour < 12 ? 'morning' : now.hour < 17 ? 'afternoon' : 'evening'}',
                    style: TextStyle(
                      color: _white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    todayLabel,
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Spending calendar',
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (_) => _SpendingCalendarSheet(entries: entries),
              ),
              icon: const Icon(Icons.calendar_month_rounded),
            ),
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => _showToast(context, 'You’re all caught up.'),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            IconButton.filledTonal(
              key: const Key('addTransactionButton'),
              tooltip: 'Add transaction',
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              style: IconButton.styleFrom(
                backgroundColor: _purple.withValues(alpha: 0.2),
                foregroundColor: _white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DailyMetric(
                label: 'Spent today',
                value: _money(todaySpent),
                icon: Icons.south_east_rounded,
                color: _red,
              ),
            ),
            Container(width: 1, height: 42, color: _line),
            Expanded(
              child: _DailyMetric(
                label: 'Received today',
                value: _money(todayIncome),
                icon: Icons.south_west_rounded,
                color: _cyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onOpenAssistant(coachPrompt),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: _purple.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _purple.withValues(alpha: 0.13)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome_rounded, color: _purple, size: 21),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your daily money coach',
                        style: TextStyle(color: _white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        coachMessage,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _muted, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_rounded, color: _purple, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Shortcuts',
                style: TextStyle(
                  color: _white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: onOpenGoals,
              style: TextButton.styleFrom(
                foregroundColor: _purple,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Goals'),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            _QuickAction(
              icon: Icons.add_rounded,
              label: 'Add expense',
              subtitle: 'Quick record',
              color: _purple,
              onTap: onAdd,
            ),
            const SizedBox(width: 9),
            _QuickAction(
              icon: Icons.flag_outlined,
              label: 'Savings goal',
              subtitle: 'Set your target',
              color: _cyan,
              onTap: onOpenGoals,
            ),
            const SizedBox(width: 9),
            _QuickAction(
              icon: Icons.auto_awesome_rounded,
              label: 'AI assistant',
              subtitle: 'Get insights',
              color: _orange,
              onTap: () => onOpenAssistant('Give me a quick overview of my recorded income, expenses, and balance. Suggest one practical next step.'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                  color: _white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            TextButton(
              onPressed: onOpenTransactions,
              style: TextButton.styleFrom(
                foregroundColor: _purple,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 5),
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 9),
        _RecentTransactionsCard(entries: entries.take(3).toList()),
      ],
    );
  }
}

class _SpendingCalendarSheet extends StatefulWidget {
  const _SpendingCalendarSheet({required this.entries});

  final List<_MoneyEntry> entries;

  @override
  State<_SpendingCalendarSheet> createState() =>
      _SpendingCalendarSheetState();
}

class _SpendingCalendarSheetState extends State<_SpendingCalendarSheet> {
  late DateTime _month;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _month = DateTime(today.year, today.month);
    _selectedDay = DateTime(today.year, today.month, today.day);
  }

  DateTime? _dateFor(_MoneyEntry entry) {
    final value = entry.date.trim();
    final current = DateTime.now();
    if (value.toLowerCase().startsWith('today')) {
      return DateTime(current.year, current.month, current.day);
    }
    final parsed = DateTime.tryParse(value);
    if (parsed != null) return DateTime(parsed.year, parsed.month, parsed.day);

    final parts = value.split(RegExp(r'[ ,]+'));
    if (parts.length < 2) return null;
    const monthNames = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
    };
    final month = monthNames[parts[0].toLowerCase()];
    final day = int.tryParse(parts[1]);
    final year = parts.length > 2 ? int.tryParse(parts[2]) : current.year;
    if (month == null || day == null || year == null) return null;
    return DateTime(year, month, day);
  }

  bool _sameDay(DateTime? first, DateTime second) =>
      first != null &&
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  void _changeMonth(int delta) {
    final nextMonth = DateTime(_month.year, _month.month + delta);
    final finalDay = DateTime(nextMonth.year, nextMonth.month + 1, 0).day;
    final day = _selectedDay.day < finalDay ? _selectedDay.day : finalDay;
    setState(() {
      _month = nextMonth;
      _selectedDay = DateTime(
        nextMonth.year,
        nextMonth.month,
        day,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? Colors.white : const Color(0xFF29252D);
    final mutedColor = dark ? Colors.white70 : const Color(0xFF77727C);
    final monthStart = DateTime(_month.year, _month.month, 1);
    final offset = monthStart.weekday % 7;
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final dayEntries = widget.entries
        .where((entry) => _sameDay(_dateFor(entry), _selectedDay))
        .toList();
    final dayExpenses = dayEntries
        .where((entry) => entry.amount < 0)
        .fold<double>(0, (total, entry) => total + entry.amount.abs());
    final dayIncome = dayEntries
        .where((entry) => entry.amount > 0)
        .fold<double>(0, (total, entry) => total + entry.amount);
    final monthLabel =
        '${_monthName(_month.month)} ${_month.year}';

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.88,
      decoration: BoxDecoration(
        color: dark ? _panel : _ivory,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: dark ? Colors.white12 : Colors.white.withValues(alpha: 0.9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: mutedColor.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Spending calendar',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close calendar',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  tooltip: 'Previous month',
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      monthLabel,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Next month',
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                for (final weekday in ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
                  Expanded(
                    child: Center(
                      child: Text(
                        weekday,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 228,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 42,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  final day = index - offset + 1;
                  if (day < 1 || day > daysInMonth) {
                    return const SizedBox.shrink();
                  }
                  final date = DateTime(_month.year, _month.month, day);
                  final entriesOnDay = widget.entries
                      .where((entry) => _sameDay(_dateFor(entry), date))
                      .toList();
                  final selected = _sameDay(date, _selectedDay);
                  final hasSpending = entriesOnDay.any(
                    (entry) => entry.amount < 0,
                  );
                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _selectedDay = date),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected
                            ? _purple
                            : hasSpending
                            ? _purple.withValues(alpha: dark ? 0.24 : 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                        border: _sameDay(date, DateTime.now()) && !selected
                            ? Border.all(color: _purple.withValues(alpha: 0.45))
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              color: selected ? Colors.white : textColor,
                              fontSize: 13,
                              fontWeight: selected || hasSpending
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 3),
                          if (entriesOnDay.isNotEmpty)
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected
                                    ? Colors.white
                                    : hasSpending
                                    ? _red
                                    : _cyan,
                              ),
                            )
                          else
                            const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_weekdayName(_selectedDay.weekday)}, ${_monthName(_selectedDay.month)} ${_selectedDay.day}',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Spent ${_money(dayExpenses)}',
                  style: TextStyle(
                    color: _red,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (dayIncome > 0) ...[
              const SizedBox(height: 3),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Received ${_money(dayIncome)}',
                  style: TextStyle(color: _cyan, fontSize: 11),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: dayEntries.isEmpty
                  ? Center(
                      child: Text(
                        'No transactions on this day.',
                        style: TextStyle(color: mutedColor, fontSize: 12),
                      ),
                    )
                  : ListView.separated(
                      itemCount: dayEntries.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: dark ? Colors.white12 : _line,
                      ),
                      itemBuilder: (context, index) {
                        final entry = dayEntries[index];
                        final income = entry.amount >= 0;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 2,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: entry.color.withValues(alpha: 0.16),
                            child: Icon(entry.icon, color: entry.color, size: 20),
                          ),
                          title: Text(
                            entry.name,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            entry.category,
                            style: TextStyle(color: mutedColor, fontSize: 11),
                          ),
                          trailing: Text(
                            '${income ? '+' : '-'}${_money(entry.amount.abs())}',
                            style: TextStyle(
                              color: income ? _cyan : _red,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) => const [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ][month - 1];

  String _weekdayName(int weekday) => const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ][weekday - 1];
}

class _DailyMetric extends StatelessWidget {
  const _DailyMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({required this.entries});

  final List<_MoneyEntry> entries;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark
              ? Colors.white.withValues(alpha: 0.13)
              : Colors.white.withValues(alpha: 0.88),
        ),
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.16)
                : _purple.withValues(alpha: 0.09),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [
                        _panel2.withValues(alpha: 0.84),
                        _panel.withValues(alpha: 0.78),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.82),
                        Colors.white.withValues(alpha: 0.68),
                        _cyan.withValues(alpha: 0.12),
                      ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 24,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: dark ? 0.08 : 0.42),
                            Colors.white.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      'Your recent transactions will appear here.',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (var index = 0; index < entries.length; index++) ...[
                        _RecentTransactionRow(entry: entries[index]),
                        if (index != entries.length - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            indent: 66,
                            color: dark
                                ? _line
                                : Colors.white.withValues(alpha: 0.85),
                          ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentTransactionRow extends StatelessWidget {
  const _RecentTransactionRow({required this.entry});

  final _MoneyEntry entry;

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.amount >= 0;
    final color = entry.color;
    final date = entry.date.split(',').first.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(
              entry.icon,
              color: color == _cyan || color == _yellow ? _bg : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${_money(entry.amount.abs())}',
                style: TextStyle(
                  color: _white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(date, style: TextStyle(color: _muted, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceMiniStat extends StatelessWidget {
  const _BalanceMiniStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpendingOverview extends StatelessWidget {
  const _SpendingOverview({required this.entries});

  final List<_MoneyEntry> entries;

  @override
  Widget build(BuildContext context) {
    final totals = <String, double>{};
    for (final entry in entries.where((entry) => entry.amount < 0)) {
      totals.update(
        entry.category,
        (value) => value + entry.amount.abs(),
        ifAbsent: () => entry.amount.abs(),
      );
    }
    final categories = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalSpent = totals.values.fold<double>(
      0,
      (sum, value) => sum + value,
    );

    return _Panel(
      child: categories.isEmpty
          ? Text(
              'Add expense transactions to see your category breakdown.',
              style: TextStyle(color: _muted, fontSize: 11),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Recorded expenses',
                        style: TextStyle(color: _muted, fontSize: 11),
                      ),
                    ),
                    Text(
                      _money(totalSpent),
                      style: TextStyle(
                        color: _white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                SizedBox(
                  height: 145,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final category in categories.take(5))
                        Expanded(
                          child: _SpendingBar(
                            category: category.key,
                            amount: category.value,
                            maxAmount: categories.first.value,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SpendingBar extends StatelessWidget {
  const _SpendingBar({
    required this.category,
    required this.amount,
    required this.maxAmount,
  });

  final String category;
  final double amount;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final height = (amount / maxAmount * 86).clamp(10.0, 86.0).toDouble();
    final label = category.length > 6 ? category.substring(0, 6) : category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 24,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                _money(amount),
                style: TextStyle(
                  color: _muted,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Spacer(),
          TweenAnimationBuilder<double>(
            key: ValueKey(category),
            tween: Tween<double>(begin: 0, end: height),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, animatedHeight, child) => Container(
              width: 22,
              height: animatedHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_purple, _red],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _muted, fontSize: 9),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 134,
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.065,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.10)),
        boxShadow: [
          if (Theme.of(context).brightness == Brightness.light)
            BoxShadow(
              color: color.withValues(alpha: 0.045),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 25),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
