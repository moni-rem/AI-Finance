part of '../app/app.dart';

class _GoalsPage extends StatefulWidget {
  const _GoalsPage({
    required this.goals,
    required this.onAddGoal,
    required this.onContribute,
  });

  final List<_SavingsGoal> goals;
  final Future<void> Function() onAddGoal;
  final void Function(_SavingsGoal goal, double amount) onContribute;

  @override
  State<_GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<_GoalsPage> {
  Future<void> _addGoal() async {
    await widget.onAddGoal();
    if (mounted) setState(() {});
  }

  Future<void> _contribute(BuildContext context, _SavingsGoal goal) async {
    final amount = await showDialog<double>(
      context: context,
      builder: (_) => const _ContributeDialog(),
    );
    if (amount != null) widget.onContribute(goal, amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Savings Goals'),
        actions: [
          IconButton(
            key: const Key('addGoalButton'),
            onPressed: _addGoal,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          for (final goal in widget.goals) ...[
            _Panel(
              child: Column(
                children: [
                  Row(
                    children: [
                      _IconTile(icon: goal.icon, color: goal.color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.title,
                              style: TextStyle(
                                color: _white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${_money(goal.saved)} / ${_money(goal.target)}',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${(goal.saved / goal.target * 100).round()}%',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ProgressBar(
                    value: goal.saved / goal.target,
                    color: goal.color,
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _contribute(context, goal),
                      child: const Text('Add savings'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          OutlinedButton.icon(
            onPressed: _addGoal,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add New Goal'),
          ),
        ],
      ),
    );
  }
}

class _AddGoalDialog extends StatefulWidget {
  const _AddGoalDialog();

  @override
  State<_AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _target = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text('New Savings Goal'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Goal name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a goal name'
                  : null,
            ),
            TextFormField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Target amount',
                prefixText: '\$ ',
              ),
              validator: (value) {
                final target = double.tryParse(value?.trim() ?? '');
                return target == null || target <= 0
                    ? 'Enter a valid target'
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
          key: const Key('saveGoalButton'),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _SavingsGoal(
                title: _name.text.trim(),
                saved: 0,
                target: double.parse(_target.text.trim()),
                icon: Icons.savings_rounded,
                color: _purple,
              ),
            );
          },
          child: const Text('Create Goal'),
        ),
      ],
    );
  }
}

class _ContributeDialog extends StatefulWidget {
  const _ContributeDialog();

  @override
  State<_ContributeDialog> createState() => _ContributeDialogState();
}

class _ContributeDialogState extends State<_ContributeDialog> {
  final _amount = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: const Text('Add to goal'),
      content: TextField(
        controller: _amount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText: 'Amount',
          prefixText: '\$ ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final value = double.tryParse(_amount.text.trim());
            if (value != null && value > 0) Navigator.pop(context, value);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
