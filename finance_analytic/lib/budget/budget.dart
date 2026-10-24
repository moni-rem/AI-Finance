part of '../app/app.dart';

class _BudgetPage extends StatelessWidget {
  const _BudgetPage({
    required this.budgets,
    required this.onAddBudget,
    required this.onOpenGoals,
  });

  final List<_BudgetItem> budgets;
  final VoidCallback onAddBudget;
  final VoidCallback onOpenGoals;

  @override
  Widget build(BuildContext context) {
    final spent = budgets.fold<double>(0, (sum, item) => sum + item.spent);
    final total = budgets.fold<double>(0, (sum, item) => sum + item.limit);
    final progress = total <= 0
        ? 0.0
        : (spent / total).clamp(0.0, 1.0).toDouble();
    final percent = total <= 0 ? 0 : (spent / total * 100).round();
    final dark = Theme.of(context).brightness == Brightness.dark;
    return _PageScroll(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budget',
                    style: TextStyle(
                      color: _white,
                      fontSize: 29,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Manage your monthly spending',
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Savings goals',
              onPressed: onOpenGoals,
              style: IconButton.styleFrom(
                backgroundColor: _red.withValues(alpha: 0.10),
                foregroundColor: _red,
                fixedSize: const Size(48, 48),
              ),
              icon: const Icon(Icons.flag_outlined),
            ),
            const SizedBox(width: 5),
            Material(
              color: _red,
              shape: const CircleBorder(),
              elevation: 5,
              shadowColor: _red.withValues(alpha: 0.35),
              child: IconButton(
                key: const Key('addBudgetButton'),
                tooltip: 'Add budget',
                onPressed: onAddBudget,
                color: Colors.white,
                icon: const Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: dark ? _panel : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: _red.withValues(alpha: 0.14)),
            boxShadow: [
              BoxShadow(
                color: _red.withValues(alpha: 0.07),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconTile(
                    icon: Icons.calendar_month_rounded,
                    color: _red,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'October 2026',
                      style: TextStyle(
                        color: _white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _PercentPill(percent: percent, color: _red),
                ],
              ),
              const SizedBox(height: 19),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: _white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(text: _money(spent)),
                      TextSpan(
                        text: ' of ${_money(total)}',
                        style: TextStyle(
                          color: _muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 13),
              _ProgressBar(value: progress, color: _red),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on_rounded,
                    color: Color(0xFFFFAD32),
                    size: 20,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    '${_money(total - spent)} remaining',
                    style: TextStyle(
                      color: _muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: Text(
                'Categories',
                style: TextStyle(
                  color: _white,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAddBudget,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Budget'),
              style: TextButton.styleFrom(
                foregroundColor: _red,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        for (final item in budgets) ...[
          _BudgetRow(item: item),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _AddBudgetDialog extends StatefulWidget {
  const _AddBudgetDialog();

  @override
  State<_AddBudgetDialog> createState() => _AddBudgetDialogState();
}

class _AddBudgetDialogState extends State<_AddBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  String _category = 'Food';

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text('Add Budget'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _category,
              items: const [
                DropdownMenuItem(value: 'Food', child: Text('Food')),
                DropdownMenuItem(value: 'Transport', child: Text('Transport')),
                DropdownMenuItem(value: 'Shopping', child: Text('Shopping')),
                DropdownMenuItem(value: 'Bills', child: Text('Bills')),
                DropdownMenuItem(
                  value: 'Entertainment',
                  child: Text('Entertainment'),
                ),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Monthly limit',
                prefixText: '\$ ',
              ),
              validator: (value) {
                final parsed = double.tryParse(value?.trim() ?? '');
                return parsed == null || parsed <= 0
                    ? 'Enter a valid limit'
                    : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('saveBudgetButton'),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _BudgetItem(
                title: _category,
                spent: 0,
                limit: double.parse(_amount.text.trim()),
                color: _categoryColor(_category),
                icon: _categoryIcon(_category),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _BudgetRow extends StatelessWidget {
  const _BudgetRow({required this.item});

  final _BudgetItem item;

  @override
  Widget build(BuildContext context) {
    final progress = (item.spent / item.limit).clamp(0.0, 1.0).toDouble();
    final remaining = item.limit - item.spent;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark
            ? _panel
            : Color.alphaBlend(
                item.color.withValues(alpha: 0.065),
                Colors.white,
              ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? _line : item.color.withValues(alpha: 0.13),
        ),
        boxShadow: [
          if (!dark)
            BoxShadow(
              color: item.color.withValues(alpha: 0.045),
              blurRadius: 13,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _IconTile(icon: item.icon, color: item.color, size: 48),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_money(item.spent)} of ${_money(item.limit)}',
                      style: TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _PercentPill(
                percent: (progress * 100).round(),
                color: item.color,
              ),
              const SizedBox(width: 5),
              Icon(Icons.chevron_right_rounded, color: _muted, size: 22),
            ],
          ),
          const SizedBox(height: 11),
          Padding(
            padding: const EdgeInsets.only(left: 61),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressBar(value: progress, color: item.color),
                const SizedBox(height: 7),
                Text(
                  '${_money(remaining)} remaining',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
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

class _PercentPill extends StatelessWidget {
  const _PercentPill({required this.percent, required this.color});

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(25),
    ),
    child: Text(
      '$percent%',
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value, required this.color});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(10),
    child: LinearProgressIndicator(
      value: value.clamp(0.0, 1.0).toDouble(),
      minHeight: 9,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? _panel2
          : const Color(0xFFE1E6EB),
      valueColor: AlwaysStoppedAnimation(color),
    ),
  );
}
