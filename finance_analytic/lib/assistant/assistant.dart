part of '../app/app.dart';

const _aiBackendUrl = String.fromEnvironment('AI_BACKEND_URL');

class _AssistantPage extends StatefulWidget {
  const _AssistantPage({
    required this.balance,
    required this.entries,
    required this.budgets,
    required this.initialPrompt,
  });

  final double balance;
  final List<_MoneyEntry> entries;
  final List<_BudgetItem> budgets;
  final String initialPrompt;

  @override
  State<_AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<_AssistantPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<(bool, String)> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _messages.add((false, _analyze('overview')));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.initialPrompt.isNotEmpty) {
        _send(widget.initialPrompt);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double get _income => widget.entries
      .where((entry) => entry.amount > 0)
      .fold<double>(0, (sum, entry) => sum + entry.amount);

  double get _expenses => widget.entries
      .where((entry) => entry.amount < 0)
      .fold<double>(0, (sum, entry) => sum + entry.amount.abs());

  Map<String, double> get _categorySpending {
    final totals = <String, double>{};
    for (final entry in widget.entries.where((entry) => entry.amount < 0)) {
      totals.update(
        entry.category,
        (amount) => amount + entry.amount.abs(),
        ifAbsent: () => entry.amount.abs(),
      );
    }
    return totals;
  }

  String _analyze(String prompt) {
    final question = prompt.toLowerCase();
    final categories = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = categories.isEmpty ? null : categories.first;
    final savings = _income - _expenses;
    final savingsRate = _income == 0 ? 0 : savings / _income * 100;

    if (question.contains('budget') || question.contains('save')) {
      final exceeded = widget.budgets
          .where((budget) => budget.spent > budget.limit)
          .toList();
      final budgetNote = exceeded.isEmpty
          ? 'None of your tracked budgets are over their limits.'
          : 'These budgets are over their limits: ${exceeded.map((item) => item.title).join(', ')}.';
      final categoryNote = topCategory == null
          ? ''
          : ' Your largest recorded expense category is ${topCategory.key} at ${_money(topCategory.value)}.';
      return 'You have ${_money(savings)} left after the recorded income and expenses (a ${savingsRate.toStringAsFixed(0)}% savings rate). $budgetNote$categoryNote Consider setting a small weekly limit for that category.';
    }

    if (question.contains('most') ||
        question.contains('category') ||
        question.contains('spend')) {
      if (topCategory == null) {
        return 'There are no expense transactions to compare yet. Add a transaction and I can identify your largest spending category.';
      }
      final share = _expenses == 0 ? 0 : topCategory.value / _expenses * 100;
      return 'Your largest recorded expense category is ${topCategory.key}: ${_money(topCategory.value)}, about ${share.toStringAsFixed(0)}% of your recorded expenses. Total recorded expenses are ${_money(_expenses)}.';
    }

    if (question.contains('income') || question.contains('earn')) {
      return 'Your recorded income totals ${_money(_income)} across ${widget.entries.where((entry) => entry.amount > 0).length} income transactions. Recorded expenses are ${_money(_expenses)}, leaving ${_money(savings)}.';
    }

    if (question.contains('transaction') || question.contains('recent')) {
      final recent = widget.entries.take(4).toList();
      if (recent.isEmpty) return 'There are no transactions recorded yet.';
      final lines = recent
          .map((entry) => '• ${entry.name}: ${_money(entry.amount)}')
          .join('\n');
      return 'Here are your latest recorded transactions:\n$lines';
    }

    final topLine = topCategory == null
        ? 'There are no expense categories to compare yet.'
        : 'Your largest expense category is ${topCategory.key} (${_money(topCategory.value)}).';
    return 'Here is your money snapshot: your balance is ${_money(widget.balance)}, recorded income is ${_money(_income)}, and recorded expenses are ${_money(_expenses)}. $topLine Ask me about spending, income, budgets, or recent transactions.';
  }

  Map<String, Object?> get _financialContext => {
    'currency': _activeCurrency,
    'balance': widget.balance,
    'total_income': _income,
    'total_expenses': _expenses,
    'expenses_by_category': _categorySpending,
    'budgets': [
      for (final budget in widget.budgets)
        {
          'category': budget.title,
          'spent': budget.spent,
          'limit': budget.limit,
        },
    ],
    'recent_transactions': [
      for (final entry in widget.entries.take(8))
        {
          'category': entry.category,
          'amount': entry.amount,
          'date': entry.date,
          'type': entry.amount >= 0 ? 'income' : 'expense',
        },
    ],
  };

  Future<String> _requestAI(String prompt) async {
    final baseUrl = _aiBackendUrl.replaceFirst(RegExp(r'/+$'), '');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('Sign in to use the online AI assistant.');
    }
    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw StateError('Your sign-in expired. Please sign in again.');
    }
    final response = await http
        .post(
          Uri.parse('$baseUrl/chat'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: jsonEncode({
            'message': prompt,
            'history': [
              for (final (isUser, content) in _messages)
                {'role': isUser ? 'user' : 'assistant', 'content': content},
            ],
            'financial_context': _financialContext,
          }),
        )
        .timeout(const Duration(seconds: 45));

    final payload = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = payload is Map<String, dynamic>
          ? payload['error']?.toString()
          : null;
      throw Exception(message ?? 'The AI service returned an error.');
    }
    if (payload is! Map<String, dynamic> || payload['answer'] is! String) {
      throw const FormatException('Invalid response from the AI service.');
    }
    return (payload['answer'] as String).trim();
  }

  Future<void> _send([String? suggestedPrompt]) async {
    final text = (suggestedPrompt ?? _controller.text).trim();
    if (text.isEmpty || _isSending) return;
    setState(() {
      _isSending = true;
      _messages.add((true, text));
      _controller.clear();
    });
    try {
      final answer = _aiBackendUrl.isEmpty
          ? _analyze(text)
          : await _requestAI(text);
      if (!mounted) return;
      setState(() => _messages.add((false, answer)));
    } catch (error) {
      if (!mounted) return;
      setState(() {
        final message = error is StateError
            ? error.message
            : 'I could not reach Gemini. Check the backend URL, server logs, and Gemini API key, then try again.';
        _messages.add((false, message.toString()));
      });
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: _purple, size: 20),
            const SizedBox(width: 9),
            const Text('AI Money Coach'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                _Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            color: _purple,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Your money snapshot',
                            style: TextStyle(
                              color: _white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          _AssistantMetric(
                            label: 'Income',
                            value: _money(_income),
                          ),
                          _AssistantMetric(
                            label: 'Expenses',
                            value: _money(_expenses),
                          ),
                          _AssistantMetric(
                            label: 'Balance',
                            value: _money(widget.balance),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Try asking',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 7,
                  runSpacing: 2,
                  children: [
                    _AssistantPrompt(
                      label: 'Where do I spend most?',
                      onTap: () => _send('Where do I spend most?'),
                    ),
                    _AssistantPrompt(
                      label: 'How can I save?',
                      onTap: () => _send('How can I save?'),
                    ),
                    _AssistantPrompt(
                      label: 'Show recent transactions',
                      onTap: () => _send('Show recent transactions'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final (isUser, text) in _messages)
                  Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 330),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: isUser ? _purple : surface,
                        borderRadius: BorderRadius.circular(17),
                        border: isUser
                            ? null
                            : Border.all(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? _line
                                    : const Color(0xFFE7E3E0),
                              ),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          color: isUser ? Colors.white : _white,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                if (_isSending)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask about your finances...',
                      filled: true,
                      fillColor: surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _isSending ? null : _send,
                  icon: _isSending
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AssistantMetric extends StatelessWidget {
  const _AssistantMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: _muted, fontSize: 10)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: _white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AssistantPrompt extends StatelessWidget {
  const _AssistantPrompt({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ActionChip(
    label: Text(label, style: const TextStyle(fontSize: 10)),
    onPressed: onTap,
    visualDensity: VisualDensity.compact,
    backgroundColor: Theme.of(context).colorScheme.surface,
    side: BorderSide(
      color: Theme.of(context).brightness == Brightness.dark
          ? _line
          : const Color(0xFFE7E3E0),
    ),
  );
}
