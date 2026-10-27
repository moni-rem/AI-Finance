part of '../app/app.dart';

class _AnalyticsPage extends StatefulWidget {
  const _AnalyticsPage({required this.income, required this.expenses});

  final double income;
  final double expenses;

  @override
  State<_AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<_AnalyticsPage> {
  String _period = 'Monthly';

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analytics',
                    style: TextStyle(
                      color: _white,
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Track your financial performance',
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            _DropdownPill(
              label: _period,
              onSelected: (period) => setState(() => _period = period),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _SummaryCard(
                label: 'Total Income',
                value: _money(widget.income),
                trend: '↑ 12% from last month',
                color: _cyan,
                icon: Icons.south_west_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                label: 'Total Expenses',
                value: _money(widget.expenses),
                trend: '↓ 8% from last month',
                color: _red,
                icon: Icons.north_east_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const _MonthlyBars(),
        const SizedBox(height: 18),
        _ExpenseBreakdown(expenses: widget.expenses),
      ],
    );
  }
}

class _MonthlyBars extends StatelessWidget {
  const _MonthlyBars();

  @override
  Widget build(BuildContext context) {
    const incomes = [0.55, 0.72, 0.88, 0.7, 0.79, 0.62];
    const expenses = [0.3, 0.42, 0.55, 0.46, 0.5, 0.35];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
    return _Panel(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              _IconTile(icon: Icons.bar_chart_rounded, color: _cyan, size: 43),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash flow',
                      style: TextStyle(
                        color: _white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Income vs Expenses',
                      style: TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const _LegendDot(color: _cyan, label: 'Income'),
              const SizedBox(width: 9),
              _LegendDot(color: _purple, label: 'Expense'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: Row(
              children: [
                SizedBox(
                  width: 31,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (final label in ['2.0K', '1.5K', '1.0K', '500', '0'])
                        Text(
                          label,
                          style: TextStyle(color: _muted, fontSize: 9),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(painter: _ChartGridPainter()),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(
                                months.length,
                                (index) => Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        _AnalyticsBar(
                                          height: incomes[index] * 142,
                                          color: _cyan,
                                        ),
                                        const SizedBox(width: 3),
                                        _AnalyticsBar(
                                          height: expenses[index] * 142,
                                          color: _purple,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          for (final month in months)
                            Text(
                              month,
                              style: TextStyle(color: _muted, fontSize: 10),
                            ),
                        ],
                      ),
                    ],
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

class _ChartGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = _muted.withValues(alpha: 0.13)
      ..strokeWidth = 1;
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _AnalyticsBar extends StatelessWidget {
  const _AnalyticsBar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 11,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
    ),
  );
}

class _ExpenseBreakdown extends StatelessWidget {
  const _ExpenseBreakdown({required this.expenses});

  final double expenses;

  static List<(String, int, Color, IconData)> get _items => [
    ('Food', 28, _cyan, Icons.restaurant_rounded),
    ('Shopping', 22, _purple, Icons.shopping_bag_rounded),
    ('Bills', 18, _red, Icons.receipt_long_rounded),
    ('Transport', 12, _orange, Icons.directions_car_rounded),
    ('Entertainment', 10, _yellow, Icons.movie_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return _Panel(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              _IconTile(icon: Icons.pie_chart_rounded, color: _red, size: 42),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expense by category',
                      style: TextStyle(
                        color: _white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Percentage of total expenses',
                      style: TextStyle(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert_rounded, color: _muted),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 142,
                height: 142,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(142, 142),
                      painter: _DonutPainter(accentColor: _purple),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Expenses',
                          style: TextStyle(color: _muted, fontSize: 10),
                        ),
                        Text(
                          _money(expenses),
                          style: TextStyle(
                            color: _white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    for (final item in _items)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: item.$3,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(item.$4, color: item.$3, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.$1,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              '${item.$2}%',
                              style: TextStyle(
                                color: _white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.accentColor});

  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [_cyan, accentColor, _red, _orange, _yellow];
    const values = [0.28, 0.22, 0.18, 0.12, 0.20];
    final rect = Rect.fromLTWH(4, 4, size.width - 8, size.height - 8);
    final brush = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 17;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      brush.color = colors[i];
      final sweep = math.pi * 2 * values[i] - 0.045;
      canvas.drawArc(rect, start, sweep, false, brush);
      start += math.pi * 2 * values[i];
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}

class _DropdownPill extends StatelessWidget {
  const _DropdownPill({required this.label, required this.onSelected});

  final String label;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => PopupMenuButton<String>(
    initialValue: label,
    tooltip: 'Choose reporting period',
    onSelected: onSelected,
    itemBuilder: (context) => [
      for (final period in ['Weekly', 'Monthly', 'Yearly'])
        PopupMenuItem(value: period, child: Text(period)),
    ],
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? _line
              : const Color(0xFFE1E5EF),
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? _white
                  : const Color(0xFF35272D),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Theme.of(context).brightness == Brightness.dark
                ? _white
                : const Color(0xFF57464D),
            size: 17,
          ),
        ],
      ),
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final String trend;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      constraints: const BoxConstraints(minHeight: 136),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark
            ? _panel
            : Color.alphaBlend(color.withValues(alpha: 0.09), const Color(0xFFFFFEFC)),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: dark ? 0.34 : 0.22)),
        boxShadow: [
          if (!dark)
            BoxShadow(
              color: color.withValues(alpha: 0.085),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 17),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: _white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
            ),
          ),
          Text(
            trend,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(
          color: const Color(0xFF57464D),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
