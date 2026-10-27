part of '../app/app.dart';

class _TransactionsPage extends StatefulWidget {
  const _TransactionsPage({required this.entries, required this.onAdd});

  final List<_MoneyEntry> entries;
  final VoidCallback onAdd;

  @override
  State<_TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<_TransactionsPage> {
  String _filter = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.entries.where((entry) {
      final matchesFilter =
          _filter == 'All' ||
          (_filter == 'Income' && entry.amount > 0) ||
          (_filter == 'Expense' && entry.amount < 0);
      final matchesQuery =
          entry.name.toLowerCase().contains(_query.toLowerCase()) ||
          entry.category.toLowerCase().contains(_query.toLowerCase());
      return matchesFilter && matchesQuery;
    }).toList();
    final incomeCount = widget.entries.where((entry) => entry.amount > 0).length;
    final expenseCount = widget.entries.where((entry) => entry.amount < 0).length;
    final netTotal = widget.entries.fold<double>(
      0,
      (total, entry) => total + entry.amount,
    );
    return _PageScroll(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PageTitle('All Transactions'),
                  const SizedBox(height: 3),
                  Text(
                    'Track your income and expenses',
                    style: TextStyle(color: _muted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Material(
              color: _red,
              shape: const CircleBorder(),
              elevation: 5,
              shadowColor: _red.withValues(alpha: 0.35),
              child: IconButton(
                key: const Key('addTransactionButton'),
                tooltip: 'Add transaction',
                onPressed: widget.onAdd,
                color: Colors.white,
                icon: const Icon(Icons.add_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  prefixIcon: const Icon(Icons.search_rounded, size: 22),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? _panel
                      : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? _line
                          : const Color(0xFFE7E3E0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? _line
                          : const Color(0xFFE7E3E0),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            PopupMenuButton<String>(
              tooltip: 'Filter transactions',
              initialValue: _filter,
              onSelected: (value) => setState(() => _filter = value),
              itemBuilder: (context) => [
                for (final option in ['All', 'Income', 'Expense'])
                  PopupMenuItem(value: option, child: Text(option)),
              ],
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? _panel
                      : Colors.white,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? _line
                        : const Color(0xFFE7E3E0),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.tune_rounded, color: _red, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (final filter in ['All', 'Income', 'Expense'])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: filter,
                    count: filter == 'All'
                        ? widget.entries.length
                        : filter == 'Income'
                        ? incomeCount
                        : expenseCount,
                    selected: _filter == filter,
                    onTap: () => setState(() => _filter = filter),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'OCTOBER 2026',
                style: TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _cyan.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Total: ${netTotal >= 0 ? '+' : '-'}${_money(netTotal.abs())}',
                    style: const TextStyle(
                      color: Color(0xFF009F88),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (filtered.isEmpty)
          const _EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No transactions found',
            subtitle: 'Try a different search or filter.',
          )
        else
          _TransactionList(entries: filtered),
      ],
    );
  }
}

class _AddTransactionDialog extends StatefulWidget {
  const _AddTransactionDialog();

  @override
  State<_AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<_AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'Expense';
  String _category = 'Food';
  bool _showAllCategories = false;

  static const _featuredCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Housing',
    'Health',
    'Other',
  ];
  static const _categories = [
    ..._featuredCategories,
    'Bills',
    'Entertainment',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.parse(_amountController.text.trim());
    final isIncome = _type == 'Income';
    Navigator.pop(
      context,
      _MoneyEntry(
        name: _nameController.text.trim(),
        category: isIncome ? 'Income' : _category,
        date: 'Today, just now',
        amount: isIncome ? amount : -amount,
        icon: isIncome ? Icons.south_west_rounded : _categoryIcon(_category),
        color: isIncome ? _cyan : _categoryColor(_category),
        note: _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text('Add Transaction', style: TextStyle(color: _white)),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _FilterChip(
                        label: 'Expense',
                        selected: _type == 'Expense',
                        onTap: () => setState(() {
                          _type = 'Expense';
                          _category = 'Food';
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _FilterChip(
                        label: 'Income',
                        selected: _type == 'Income',
                        onTap: () => setState(() => _type = 'Income'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const _FieldLabel('Amount'),
                _DarkTextField(
                  key: const Key('transactionAmountField'),
                  controller: _amountController,
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefix: Padding(
                    padding: EdgeInsets.only(left: 14, right: 4),
                    child: Text('\$', style: TextStyle(color: _muted)),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    return amount == null || amount <= 0
                        ? 'Enter a valid amount'
                        : null;
                  },
                ),
                const SizedBox(height: 13),
                const _FieldLabel('Name'),
                _DarkTextField(
                  key: const Key('transactionNameField'),
                  controller: _nameController,
                  hint: 'e.g. Groceries',
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a name'
                      : null,
                ),
                if (_type == 'Expense') ...[
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      const Expanded(child: _FieldLabel('Category')),
                      TextButton.icon(
                        onPressed: () => setState(
                          () => _showAllCategories = !_showAllCategories,
                        ),
                        icon: Icon(
                          _showAllCategories
                              ? Icons.expand_less_rounded
                              : Icons.chevron_right_rounded,
                          size: 18,
                        ),
                        label: Text(_showAllCategories ? 'Show less' : 'View all'),
                        style: TextButton.styleFrom(
                          foregroundColor: _muted,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.08,
                    children: [
                      for (final category in _showAllCategories
                          ? _categories
                          : _featuredCategories)
                        _TransactionCategoryTile(
                          category: category,
                          selected: category == _category,
                          onTap: () => setState(() => _category = category),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 13),
                const _FieldLabel('Note (Optional)'),
                _DarkTextField(
                  controller: _noteController,
                  hint: 'Add a note...',
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('saveTransactionButton'),
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _TransactionCategoryTile extends StatelessWidget {
  const _TransactionCategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final String category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = _categoryColor(category);
    return Material(
      color: selected
          ? color.withValues(alpha: dark ? 0.22 : 0.1)
          : (dark ? _panel2 : const Color(0xFFF7F7FA)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(
          color: selected
              ? color
              : (dark ? _line : const Color(0xFFE4E5EC)),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: dark ? 0.2 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_categoryIcon(category), color: color, size: 21),
            ),
            const SizedBox(height: 5),
            Text(
              category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _white,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  const _TransactionList({required this.entries});

  final List<_MoneyEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in entries) ...[
          _TransactionTile(entry: entry),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.entry});

  final _MoneyEntry entry;

  @override
  Widget build(BuildContext context) {
    final isIncome = entry.amount >= 0;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final tint = entry.color.withValues(alpha: dark ? 0.18 : 0.075);
    final amountColor = isIncome ? const Color(0xFF00A98F) : _red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: dark ? _panel : Color.alphaBlend(tint, Colors.white),
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: dark ? _line : entry.color.withValues(alpha: 0.16),
        ),
        boxShadow: [
          if (!dark)
            BoxShadow(
              color: entry.color.withValues(alpha: 0.075),
              blurRadius: 17,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: Row(
        children: [
          _IconTile(icon: entry.icon, color: entry.color, size: 52),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: TextStyle(
                    color: _white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  entry.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: entry.color.withValues(alpha: dark ? 0.22 : 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: entry.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Text(
            '${isIncome ? '+' : '-'}${_money(entry.amount.abs())}',
            style: TextStyle(
              color: amountColor,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          Icon(Icons.more_vert_rounded, color: _muted, size: 19),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) => Material(
    color: selected
        ? _red
        : (Theme.of(context).brightness == Brightness.dark
              ? _panel
              : Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
      side: BorderSide(
        color: selected
            ? _red
            : (Theme.of(context).brightness == Brightness.dark
                  ? _line
                  : const Color(0xFFE7E3E0)),
      ),
    ),
    child: InkWell(
      key: Key('filter$label'),
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (count != null && label != 'All') ...[
                Icon(
                  label == 'Income'
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 16,
                  color: selected
                      ? Colors.white
                      : label == 'Income'
                      ? const Color(0xFF00A98F)
                      : _red,
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : (Theme.of(context).brightness == Brightness.dark
                            ? _muted
                            : const Color(0xFF34303A)),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.23)
                        : (label == 'Income'
                              ? const Color(0xFF00A98F).withValues(alpha: 0.12)
                              : _red.withValues(alpha: 0.12)),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : label == 'Income'
                          ? const Color(0xFF00A98F)
                          : _red,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
