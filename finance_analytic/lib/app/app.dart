import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

part '../onboarding/onboarding.dart';
part '../authentication/authentication.dart';
part '../dashboard/dashboard.dart';
part '../transactions/transactions.dart';
part '../analytics/analytics.dart';
part '../budget/budget.dart';
part '../goals/goals.dart';
part '../assistant/assistant.dart';
part '../profile/profile.dart';
part '../shared/widgets.dart';

// Palette sampled from the user's sunset reference: mauve, coral, orange,
// mauve, coral, orange, butter yellow, near-white gray, and sky turquoise.
const _bg = Color(0xFF17131B);
const _panel = Color(0xFF241B27);
const _panel2 = Color(0xFF30232E);
const _line = Color(0xFF493441);
bool _activeDarkMode = false;
Color get _muted =>
    _activeDarkMode ? const Color(0xFFE5D9DE) : const Color(0xFF66545D);
Color get _white =>
    _activeDarkMode ? const Color(0xFFFFFFFF) : const Color(0xFF30232E);
const _defaultThemeColor = Color(0xFFA45D7F);
Color _activeThemeColor = _defaultThemeColor;
Color get _purple => _activeThemeColor;
const _themeColors = <(String, Color)>[
  ('Mauve', Color(0xFFA45D7F)),
  ('Coral', Color(0xFFAD4E5A)),
  ('Amber', Color(0xFF99530F)),
  ('Golden', Color(0xFF796310)),
  ('Sage', Color(0xFF39765D)),
  ('Ocean', Color(0xFF287783)),
];
const _cyan = Color(0xFF82D7DF);
const _red = Color(0xFFE57773);
const _orange = Color(0xFFFF9B4F);
const _yellow = Color(0xFFEED96D);
const _ivory = Color(0xFFFAF7EF);
String _activeCurrency = 'USD';

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard> {
  int _stage = 0;
  int _onboardingPage = 0;
  int _selectedTab = 0;
  final PageController _tabController = PageController();
  bool _isSignUp = false;
  bool _darkMode = false;
  String _currency = 'USD';
  double _incomeTotal = 2000;
  double _expensesTotal = 750;
  final List<_MoneyEntry> _entries = [
    _MoneyEntry(
      name: 'Food',
      category: 'Food',
      date: 'Today, 10:30 AM',
      amount: -12.50,
      icon: Icons.fastfood_rounded,
      color: _red,
    ),
    _MoneyEntry(
      name: 'Salary',
      category: 'Income',
      date: 'Oct 10, 2026',
      amount: 1500,
      icon: Icons.account_balance_wallet_rounded,
      color: _cyan,
    ),
    _MoneyEntry(
      name: 'Transport',
      category: 'Transport',
      date: 'Oct 9, 2026',
      amount: -5,
      icon: Icons.directions_bus_rounded,
      color: _orange,
    ),
    _MoneyEntry(
      name: 'Shopping',
      category: 'Shopping',
      date: 'Oct 8, 2026',
      amount: -50,
      icon: Icons.shopping_bag_rounded,
      color: _purple,
    ),
    _MoneyEntry(
      name: 'Freelance',
      category: 'Income',
      date: 'Oct 7, 2026',
      amount: 300,
      icon: Icons.work_rounded,
      color: _cyan,
    ),
    _MoneyEntry(
      name: 'Bills',
      category: 'Bills',
      date: 'Oct 6, 2026',
      amount: -60,
      icon: Icons.receipt_long_rounded,
      color: _red,
    ),
  ];
  final List<_BudgetItem> _budgets = [
    _BudgetItem(
      title: 'Food',
      spent: 120,
      limit: 300,
      color: _cyan,
      icon: Icons.restaurant_rounded,
    ),
    _BudgetItem(
      title: 'Transport',
      spent: 100,
      limit: 200,
      color: _yellow,
      icon: Icons.directions_car_rounded,
    ),
    _BudgetItem(
      title: 'Shopping',
      spent: 180,
      limit: 300,
      color: _orange,
      icon: Icons.shopping_bag_rounded,
    ),
    _BudgetItem(
      title: 'Bills',
      spent: 200,
      limit: 300,
      color: _red,
      icon: Icons.receipt_long_rounded,
    ),
    _BudgetItem(
      title: 'Entertainment',
      spent: 80,
      limit: 200,
      color: _purple,
      icon: Icons.movie_rounded,
    ),
    _BudgetItem(
      title: 'Other',
      spent: 70,
      limit: 100,
      color: _muted,
      icon: Icons.more_horiz_rounded,
    ),
  ];
  final List<_SavingsGoal> _goals = [
    _SavingsGoal(
      title: 'New Laptop',
      saved: 600,
      target: 1000,
      icon: Icons.laptop_mac_rounded,
      color: _yellow,
    ),
    _SavingsGoal(
      title: 'Travel Trip',
      saved: 300,
      target: 800,
      icon: Icons.flight_takeoff_rounded,
      color: _purple,
    ),
    _SavingsGoal(
      title: 'Emergency Fund',
      saved: 500,
      target: 2000,
      icon: Icons.shield_rounded,
      color: _cyan,
    ),
  ];

  double get _income => _incomeTotal;
  double get _expenses => _expensesTotal;
  double get _balance => _income - _expenses;

  void _selectTab(int index) {
    if (index == _selectedTab) return;
    setState(() => _selectedTab = index);
    if (_tabController.hasClients) {
      _tabController.animateToPage(
        index,
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _finishOnboarding() => setState(() => _stage = 2);

  Future<void> _showAddTransaction() async {
    final entry = await showDialog<_MoneyEntry>(
      context: context,
      builder: (_) => const _AddTransactionDialog(),
    );
    if (!mounted || entry == null) return;
    setState(() {
      _entries.insert(0, entry);
      if (entry.amount < 0) {
        _expensesTotal += entry.amount.abs();
        final budget = _budgets.where((item) => item.title == entry.category);
        if (budget.isNotEmpty) {
          budget.first.spent += entry.amount.abs();
        }
      } else {
        _incomeTotal += entry.amount;
      }
    });
  }

  Future<void> _showAddBudget() async {
    final budget = await showDialog<_BudgetItem>(
      context: context,
      builder: (_) => const _AddBudgetDialog(),
    );
    if (!mounted || budget == null) return;
    setState(() => _budgets.add(budget));
  }

  Future<void> _showAddGoal() async {
    final goal = await showDialog<_SavingsGoal>(
      context: context,
      builder: (_) => const _AddGoalDialog(),
    );
    if (!mounted || goal == null) return;
    setState(() => _goals.add(goal));
  }

  void _openAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AssistantPage(
          balance: _balance,
          entries: _entries,
          budgets: _budgets,
        ),
      ),
    );
  }

  void _openGoals() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _GoalsPage(
          goals: _goals,
          onAddGoal: _showAddGoal,
          onContribute: (goal, amount) {
            setState(() {
              goal.saved = math.min(goal.saved + amount, goal.target);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _activeDarkMode = _darkMode;
    final background = _darkMode ? _bg : _ivory;
    final baseTheme = ThemeData(
      brightness: _darkMode ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _purple,
        brightness: _darkMode ? Brightness.dark : Brightness.light,
        surface: _darkMode ? _panel : Colors.white,
      ),
      useMaterial3: true,
      fontFamily: 'Google Sans',
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
    final stageContent = switch (_stage) {
      0 => _SplashPage(onContinue: () => setState(() => _stage = 1)),
      1 => _OnboardingPage(
        page: _onboardingPage,
        onPageChanged: (page) => setState(() => _onboardingPage = page),
        onFinish: _finishOnboarding,
      ),
      2 => _AuthPage(
        isSignUp: _isSignUp,
        onBack: () => setState(() {
          _stage = 1;
          _onboardingPage = 2;
        }),
        onSwitch: () => setState(() => _isSignUp = !_isSignUp),
        onComplete: () => setState(() => _stage = 3),
      ),
      _ => _buildAppShell(),
    };
    final stageKey = _stage == 2 ? 'auth-$_isSignUp' : 'stage-$_stage';
    final systemOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: background,
      statusBarIconBrightness: _darkMode ? Brightness.light : Brightness.dark,
      statusBarBrightness: _darkMode ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: background,
      systemNavigationBarIconBrightness: _darkMode
          ? Brightness.light
          : Brightness.dark,
      systemNavigationBarDividerColor: background,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemOverlayStyle,
      child: Theme(
        data: baseTheme.copyWith(
          textTheme: GoogleFonts.googleSansTextTheme(baseTheme.textTheme),
          primaryTextTheme: GoogleFonts.googleSansTextTheme(
            baseTheme.primaryTextTheme,
          ),
        ),
        child: Scaffold(
          backgroundColor: background,
          body: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _NotebookGridPainter(
                      color: _darkMode
                          ? _line.withValues(alpha: 0.34)
                          : const Color(0xFFBDD3D8).withValues(alpha: 0.72),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      reverseDuration: const Duration(milliseconds: 260),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, animation) {
                        final slide = Tween<Offset>(
                          begin: const Offset(0, 0.025),
                          end: Offset.zero,
                        ).animate(animation);
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(position: slide, child: child),
                        );
                      },
                      child: KeyedSubtree(
                        key: ValueKey(stageKey),
                        child: stageContent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppShell() {
    final pages = [
      _HomePage(
        entries: _entries,
        onAdd: _showAddTransaction,
        onOpenTransactions: () => _selectTab(1),
        onOpenGoals: _openGoals,
        onOpenAssistant: _openAssistant,
      ),
      _TransactionsPage(entries: _entries, onAdd: _showAddTransaction),
      _AnalyticsPage(income: _income, expenses: _expenses),
      _BudgetPage(
        budgets: _budgets,
        onAddBudget: _showAddBudget,
        onOpenGoals: _openGoals,
      ),
      _ProfilePage(
        darkMode: _darkMode,
        currency: _currency,
        themeColor: _purple,
        onDarkModeChanged: (value) => setState(() {
          _darkMode = value;
          _activeDarkMode = value;
        }),
        onThemeColorChanged: (value) => setState(() {
          _activeThemeColor = value;
        }),
        onCurrencyChanged: (value) => setState(() {
          _currency = value;
          _activeCurrency = value;
        }),
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var index = 0; index < pages.length; index++)
            _KeepAlivePage(key: ValueKey(index), child: pages[index]),
        ],
      ),
      bottomNavigationBar: _BottomNavBar(
        selectedIndex: _selectedTab,
        onSelected: _selectTab,
        darkMode: _darkMode,
      ),
    );
  }
}

class _MoneyEntry {
  const _MoneyEntry({
    required this.name,
    required this.category,
    required this.date,
    required this.amount,
    required this.icon,
    required this.color,
    this.note = '',
  });

  final String name;
  final String category;
  final String date;
  final double amount;
  final IconData icon;
  final Color color;
  final String note;
}

class _BudgetItem {
  _BudgetItem({
    required this.title,
    required this.spent,
    required this.limit,
    required this.color,
    required this.icon,
  });

  final String title;
  double spent;
  final double limit;
  final Color color;
  final IconData icon;
}

class _SavingsGoal {
  _SavingsGoal({
    required this.title,
    required this.saved,
    required this.target,
    required this.icon,
    required this.color,
  });

  final String title;
  double saved;
  final double target;
  final IconData icon;
  final Color color;
}

String _money(double amount, {String currency = 'USD'}) {
  final code = currency == 'USD' ? _activeCurrency : currency;
  final prefix = code == 'USD' ? '\$' : '$code ';
  final parts = amount.abs().toStringAsFixed(2).split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '${amount < 0 ? '-' : ''}$prefix$whole.${parts.last}';
}
