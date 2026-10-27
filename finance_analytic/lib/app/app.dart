import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/services.dart';
import 'package:finance_analytic/legal_documents.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
String? firebaseInitializationError;
void setFirebaseInitializationError(String error) {
  firebaseInitializationError = error;
}
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
const String _activeCurrency = 'USD';
Future<void>? _googleSignInInitialization;

class FinanceDashboard extends StatefulWidget {
  const FinanceDashboard({super.key});

  @override
  State<FinanceDashboard> createState() => _FinanceDashboardState();
}

class _FinanceDashboardState extends State<FinanceDashboard>
    with WidgetsBindingObserver {
  int _stage = 0;
  int _onboardingPage = 0;
  int _selectedTab = 0;
  final PageController _tabController = PageController(keepPage: false);
  bool _isSignUp = false;
  bool _isGuest = false;
  bool _isAccountGate = false;
  bool _darkMode = false;
  String _profileName = '';
  String _profileEmail = '';
  String _profilePhone = '';
  String _profileLocation = '';
  String _profilePin = '';
  final FlutterSecureStorage _pinStorage = const FlutterSecureStorage();
  bool _lockOnResume = false;
  bool _unlockToApp = false;
  bool _pinVerifiedForCurrentLaunch = false;
  double _incomeTotal = 0;
  double _expensesTotal = 0;
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
  final List<_BudgetItem> _budgets = _defaultBudgets();
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recalculateTotals();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused &&
        _stage == 3 &&
        _profilePin.isNotEmpty) {
      _lockOnResume = true;
      return;
    }
    if (state == AppLifecycleState.resumed &&
        _lockOnResume &&
        _stage == 3 &&
        _profilePin.isNotEmpty) {
      _lockOnResume = false;
      _unlockToApp = true;
      setState(() => _stage = 4);
    }
  }

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
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    try {
      final savedPin = await _pinStorage.read(key: 'finance_security_pin');
      if (!mounted) return;
      if (savedPin != null && savedPin.isNotEmpty) {
        setState(() {
          _profilePin = savedPin;
          _unlockToApp = false;
          _stage = 4;
        });
        return;
      }
    } catch (error) {
      debugPrint('Could not read the saved security PIN: $error');
      if (mounted) {
        _showToast(context, 'Could not access secure PIN storage. Try again.');
      }
      return;
    }
    if (Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null) {
      unawaited(_finishAuthentication());
      return;
    }
    setState(() => _stage = 2);
  }

  Future<bool> _verifyPin(String enteredPin) async {
    try {
      final savedPin = await _pinStorage.read(key: 'finance_security_pin');
      final matches = savedPin != null && savedPin == enteredPin;
      if (matches) _pinVerifiedForCurrentLaunch = true;
      return matches;
    } catch (error) {
      debugPrint('Could not verify the security PIN: $error');
      return false;
    }
  }

  void _unlockApp() {
    if (Firebase.apps.isNotEmpty && FirebaseAuth.instance.currentUser != null) {
      unawaited(_finishAuthentication());
      return;
    }
    setState(() {
      _isGuest = _unlockToApp;
      _stage = _unlockToApp ? 3 : 2;
      _unlockToApp = false;
    });
  }

  Future<void> _logOut() async {
    try {
      if (Firebase.apps.isNotEmpty) await FirebaseAuth.instance.signOut();
    } catch (error) {
      if (mounted) _showToast(context, 'Could not sign out: $error');
      return;
    }
    if (!mounted) return;
    setState(() {
      _pinVerifiedForCurrentLaunch = false;
      _profileName = '';
      _profileEmail = '';
      _profilePhone = '';
      _profileLocation = '';
      _pendingSaveAction = null;
      _isGuest = true;
      _isAccountGate = false;
      _isSignUp = false;
      _budgets
        ..clear()
        ..addAll(_defaultBudgets());
      _stage = 2;
    });
  }

  Future<String?> _askForAccountPassword() => showDialog<String>(
    context: context,
    builder: (context) {
      final controller = TextEditingController();
      return AlertDialog(
        title: const Text('Confirm your password'),
        content: TextField(
          controller: controller,
          autofocus: true,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'Password'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );

  Future<bool> _reauthenticateBeforeAccountDeletion(User user) async {
    final providers = user.providerData.map((provider) => provider.providerId);
    if (providers.contains(EmailAuthProvider.PROVIDER_ID)) {
      final email = user.email;
      if (email == null || email.isEmpty) {
        throw StateError('This account has no email address for verification.');
      }
      final password = await _askForAccountPassword();
      if (password == null) return false;
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    }
    if (providers.contains(GoogleAuthProvider.PROVIDER_ID)) {
      _googleSignInInitialization ??= GoogleSignIn.instance.initialize();
      await _googleSignInInitialization;
      final googleUser = await GoogleSignIn.instance.authenticate();
      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );
      await user.reauthenticateWithCredential(credential);
      return true;
    }
    throw StateError(
      'Please sign in again with your account provider, then retry account deletion.',
    );
  }

  Future<void> _deleteAccountData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showToast(context, 'Sign in to delete your account.');
      return;
    }
    try {
      if (!await _reauthenticateBeforeAccountDeletion(user)) return;

      final database = FirebaseFirestore.instance;
      final userDocument = database.collection('users').doc(user.uid);
      for (final collectionName in ['transactions', 'budgets', 'goals']) {
        final collection = userDocument.collection(collectionName);
        while (true) {
          final snapshot = await collection.limit(400).get();
          if (snapshot.docs.isEmpty) break;
          final batch = database.batch();
          for (final document in snapshot.docs) {
            batch.delete(document.reference);
          }
          await batch.commit();
        }
      }
      await userDocument.delete();
      await user.delete();
      try {
        await _pinStorage.delete(key: 'finance_security_pin');
      } catch (error) {
        debugPrint('Could not clear the local PIN after account deletion: $error');
      }
      if (!mounted) return;
      _continueAsGuest();
      _showToast(context, 'Your account and saved data were deleted.');
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = error.code == 'wrong-password'
          ? 'The password is incorrect. Your account was not deleted.'
          : error.code == 'requires-recent-login'
          ? 'Please sign in again, then retry deleting your account.'
          : 'Could not delete the account: ${error.message ?? error.code}';
      _showToast(context, message);
    } on FirebaseException catch (error) {
      if (mounted) {
        _showToast(
          context,
          'Could not delete account data: ${error.message ?? error.code}',
        );
      }
    } catch (error) {
      if (mounted) {
        final message = error is StateError
            ? error.message.toString()
            : 'Could not delete the account. Please try again.';
        _showToast(context, message);
      }
    }
  }

  FutureOr<void> Function()? _pendingSaveAction;

  Future<void> _showAddTransaction() async {
    final entry = await showDialog<_MoneyEntry>(
      context: context,
      builder: (_) => const _AddTransactionDialog(),
    );
    if (!mounted || entry == null) return;
    await _runWhenAuthenticated(() async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw StateError('Sign in to save transactions.');
        final document = _transactionCollection(user.uid).doc();
        final batch = FirebaseFirestore.instance.batch();
        batch.set(document, {
          'name': entry.name,
          'category': entry.category,
          'date': entry.date,
          'amount': entry.amount,
          'iconCode': entry.icon.codePoint,
          'colorValue': entry.color.toARGB32(),
          'note': entry.note,
          'createdAt': FieldValue.serverTimestamp(),
        });
        _BudgetItem? matchingBudget;
        if (entry.amount < 0) {
          final matches = _budgets.where(
            (item) => item.title == entry.category,
          );
          if (matches.isNotEmpty) matchingBudget = matches.first;
        }
        if (matchingBudget != null) {
          batch.set(
            _budgetCollection(
              user.uid,
            ).doc(_budgetDocumentId(matchingBudget.title)),
            {
              'title': matchingBudget.title,
              'spent': matchingBudget.spent + entry.amount.abs(),
              'limit': matchingBudget.limit,
              'iconCode': matchingBudget.icon.codePoint,
              'colorValue': matchingBudget.color.toARGB32(),
            },
          );
        }
        await batch.commit();
        final savedEntry = _MoneyEntry(
          id: document.id,
          name: entry.name,
          category: entry.category,
          date: entry.date,
          amount: entry.amount,
          icon: entry.icon,
          color: entry.color,
          note: entry.note,
        );
        if (!mounted) return;
        setState(() {
          _entries.insert(0, savedEntry);
          _recalculateTotals();
          if (matchingBudget != null) {
            matchingBudget.spent += entry.amount.abs();
          }
        });
      } catch (error) {
        if (mounted) _showToast(context, 'Could not save transaction: $error');
      }
    });
  }

  CollectionReference<Map<String, dynamic>> _transactionCollection(
    String uid,
  ) => FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('transactions');

  void _recalculateTotals() {
    _incomeTotal = _entries
        .where((entry) => entry.amount > 0)
        .fold(0, (sum, entry) => sum + entry.amount);
    _expensesTotal = _entries
        .where((entry) => entry.amount < 0)
        .fold(0, (sum, entry) => sum + entry.amount.abs());
  }

  Future<void> _loadTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await _transactionCollection(
      user.uid,
    ).orderBy('createdAt', descending: true).get();
    final loaded = snapshot.docs.map((document) {
      final data = document.data();
      return _MoneyEntry(
        id: document.id,
        name: data['name'] as String,
        category: data['category'] as String,
        date: data['date'] as String,
        amount: (data['amount'] as num).toDouble(),
        icon: IconData(
          (data['iconCode'] as num).toInt(),
          fontFamily: 'MaterialIcons',
        ),
        color: Color((data['colorValue'] as num).toInt()),
        note: data['note'] as String? ?? '',
      );
    }).toList();
    if (!mounted) return;
    setState(() {
      _entries
        ..clear()
        ..addAll(loaded);
      _recalculateTotals();
    });
  }

  Future<void> _showAddBudget() async {
    final budget = await showDialog<_BudgetItem>(
      context: context,
      builder: (_) => const _AddBudgetDialog(),
    );
    if (!mounted || budget == null) return;
    await _runWhenAuthenticated(() async {
      try {
        final previousBudgets = _budgets
            .where((item) => item.title == budget.title)
            .toList();
        final previous = previousBudgets.isEmpty ? null : previousBudgets.first;
        final savedBudget = _BudgetItem(
          title: budget.title,
          spent: previous?.spent ?? budget.spent,
          limit: budget.limit,
          color: budget.color,
          icon: budget.icon,
        );
        await _writeBudget(savedBudget);
        if (!mounted) return;
        setState(() {
          _budgets.removeWhere((item) => item.title == savedBudget.title);
          _budgets.add(savedBudget);
        });
      } catch (error) {
        if (mounted) _showToast(context, 'Could not save budget: $error');
      }
    });
  }

  Future<void> _deleteBudget(_BudgetItem budget) =>
      _runWhenAuthenticated(() async {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) throw StateError('Sign in to delete budgets.');
          await _budgetCollection(
            user.uid,
          ).doc(_budgetDocumentId(budget.title)).delete();
          if (mounted) setState(() => _budgets.remove(budget));
        } catch (error) {
          if (mounted) _showToast(context, 'Could not delete budget: $error');
        }
      });

  CollectionReference<Map<String, dynamic>> _budgetCollection(String uid) =>
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('budgets');

  String _budgetDocumentId(String category) => category
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  Future<void> _writeBudget(_BudgetItem budget) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sign in to save budgets.');
    await _budgetCollection(user.uid).doc(_budgetDocumentId(budget.title)).set({
      'title': budget.title,
      'spent': budget.spent,
      'limit': budget.limit,
      'iconCode': budget.icon.codePoint,
      'colorValue': budget.color.toARGB32(),
    });
  }

  Future<void> _loadBudgets({required bool seedDefaults}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final collection = _budgetCollection(user.uid);
    final snapshot = await collection.get();
    if (snapshot.docs.isEmpty) {
      final initialBudgets = seedDefaults ? _defaultBudgets() : <_BudgetItem>[];
      if (initialBudgets.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final budget in initialBudgets) {
          batch.set(collection.doc(_budgetDocumentId(budget.title)), {
            'title': budget.title,
            'spent': budget.spent,
            'limit': budget.limit,
            'iconCode': budget.icon.codePoint,
            'colorValue': budget.color.toARGB32(),
          });
        }
        await batch.commit();
      }
      if (mounted)
        setState(() {
          _budgets
            ..clear()
            ..addAll(initialBudgets);
        });
      return;
    }
    final loaded = snapshot.docs.map((document) {
      final data = document.data();
      final title = data['title'] as String;
      return _BudgetItem(
        title: title,
        spent: (data['spent'] as num).toDouble(),
        limit: (data['limit'] as num).toDouble(),
        icon: IconData(
          (data['iconCode'] as num).toInt(),
          fontFamily: 'MaterialIcons',
        ),
        color: Color((data['colorValue'] as num).toInt()),
      );
    }).toList();
    if (mounted)
      setState(() {
        _budgets
          ..clear()
          ..addAll(loaded);
      });
  }

  Future<void> _showAddGoal() async {
    final goal = await showDialog<_SavingsGoal>(
      context: context,
      builder: (_) => const _AddGoalDialog(),
    );
    if (!mounted || goal == null) return;
    unawaited(_runWhenAuthenticated(() => setState(() => _goals.add(goal))));
  }

  Future<void> _runWhenAuthenticated(FutureOr<void> Function() action) async {
    if (!_isGuest) {
      await action();
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() {
      _pendingSaveAction = action;
      _isAccountGate = true;
      _isSignUp = true;
      _stage = 2;
    });
  }

  void _savePersonalInformation(
    ({String name, String email, String phone, String location}) information,
  ) {
    unawaited(
      _runWhenAuthenticated(() {
        setState(() {
          _profileName = information.name;
          _profileEmail = information.email;
          _profilePhone = information.phone;
          _profileLocation = information.location;
        });
      }),
    );
  }

  void _saveProfilePin(String pin) {
    unawaited(_persistProfilePin(pin));
  }

  Future<void> _persistProfilePin(String pin) async {
    try {
      if (pin.isEmpty) {
        await _pinStorage.delete(key: 'finance_security_pin');
      } else {
        await _pinStorage.write(key: 'finance_security_pin', value: pin);
      }
      if (mounted) {
        setState(() {
          _profilePin = pin;
          _pinVerifiedForCurrentLaunch = pin.isNotEmpty;
        });
      }
    } catch (error) {
      if (mounted) {
        _showToast(context, 'Could not save the PIN securely: $error');
      }
    }
  }

  Future<void> _finishAuthentication() async {
    if (_profilePin.isNotEmpty && !_pinVerifiedForCurrentLaunch) {
      if (mounted) setState(() => _stage = 4);
      return;
    }
    _pinVerifiedForCurrentLaunch = false;
    final pendingAction = _pendingSaveAction;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Authentication did not complete.');
    final userDocument = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);
    var displayName = user.displayName ?? _profileName;
    var email = user.email ?? _profileEmail;
    try {
      final existingProfile = await userDocument.get();
      final existingData = existingProfile.data();
      displayName =
          user.displayName ?? existingData?['displayName'] as String? ?? '';
      email = user.email ?? existingData?['email'] as String? ?? '';
      if (mounted) {
        setState(() {
          _profileName = displayName;
          _profileEmail = email;
        });
      }
      await userDocument.set({
        'displayName': displayName,
        'email': email,
        'createdAt': existingData?['createdAt'] ?? FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await _loadBudgets(seedDefaults: !existingProfile.exists);
      await _loadTransactions();
    } catch (error) {
      debugPrint('Signed in, but Firebase data could not be synchronized: $error');
      if (mounted) {
        setState(() {
          _profileName = displayName;
          _profileEmail = email;
          _entries.clear();
          _budgets.clear();
          _goals.clear();
          _recalculateTotals();
        });
        _showToast(
          context,
          'Signed in, but cloud data could not load. Check the Firestore database and rules.',
        );
      }
    }
    await pendingAction?.call();
    if (!mounted) return;
    setState(() {
      _isGuest = false;
      _isAccountGate = false;
      _pendingSaveAction = null;
      _stage = 3;
    });
  }

  void _continueAsGuest() => setState(() {
    _isGuest = true;
    _profileName = '';
    _profileEmail = '';
    _profilePhone = '';
    _profileLocation = '';
    _profilePin = '';
    _pinVerifiedForCurrentLaunch = false;
    _entries.clear();
    _budgets.clear();
    _goals.clear();
    _recalculateTotals();
    _selectedTab = 0;
    _stage = 3;
  });

  void _cancelAuthentication() {
    if (_isAccountGate) {
      setState(() {
        _pendingSaveAction = null;
        _isAccountGate = false;
        _stage = 3;
      });
      return;
    }
    setState(() {
      _stage = 1;
      _onboardingPage = 2;
    });
  }

  void _openAssistant(String initialPrompt) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AssistantPage(
          balance: _balance,
          entries: _entries,
          budgets: _budgets,
          initialPrompt: initialPrompt,
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
            unawaited(
              _runWhenAuthenticated(() {
                setState(() {
                  goal.saved = math.min(goal.saved + amount, goal.target);
                });
              }),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _activeDarkMode = _darkMode;
    final background = _stage == 0
        ? Colors.white
        : _darkMode
        ? _bg
        : _ivory;
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
        isAccountGate: _isAccountGate,
        onGuest: _continueAsGuest,
        onContinueWithoutSaving: _cancelAuthentication,
        onBack: _cancelAuthentication,
        onSwitch: () => setState(() => _isSignUp = !_isSignUp),
        onComplete: _finishAuthentication,
      ),
      4 => _PinUnlockPage(onVerify: _verifyPin, onUnlocked: _unlockApp),
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
              if (_stage != 0)
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
        budgets: _budgets,
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
        onDeleteBudget: _deleteBudget,
        onOpenGoals: _openGoals,
      ),
      _ProfilePage(
        name: _profileName,
        email: _profileEmail,
        phone: _profilePhone,
        location: _profileLocation,
        pin: _profilePin,
        onPersonalInformationChanged: _savePersonalInformation,
        onPinChanged: _saveProfilePin,
        onLogout: _logOut,
        onDeleteAccount: _deleteAccountData,
        isAuthenticated:
            !_isGuest && FirebaseAuth.instance.currentUser != null,
        darkMode: _darkMode,
        themeColor: _purple,
        onDarkModeChanged: (value) => setState(() {
          _darkMode = value;
          _activeDarkMode = value;
        }),
        onThemeColorChanged: (value) => setState(() {
          _activeThemeColor = value;
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

List<_BudgetItem> _defaultBudgets() => [
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

class _MoneyEntry {
  const _MoneyEntry({
    this.id,
    required this.name,
    required this.category,
    required this.date,
    required this.amount,
    required this.icon,
    required this.color,
    this.note = '',
  });

  final String? id;
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

String _money(double amount) {
  const prefix = '\$';
  final parts = amount.abs().toStringAsFixed(2).split('.');
  final whole = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return '${amount < 0 ? '-' : ''}$prefix$whole.${parts.last}';
}
