import 'package:finance_analytic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _signInToDashboard(WidgetTester tester) async {
  await tester.pumpWidget(const FinanceApp());
  await tester.tap(find.byKey(const Key('splashGetStartedButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('onboardingNextButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('onboardingNextButton')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('onboardingFinishButton')));
  await tester.pumpAndSettle();

  await tester.enterText(
    find.byKey(const Key('authEmailField')),
    'demo@test.com',
  );
  await tester.enterText(
    find.byKey(const Key('authPasswordField')),
    'password123',
  );
  await tester.ensureVisible(find.byKey(const Key('authSubmitButton')));
  await tester.tap(find.byKey(const Key('authSubmitButton')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('onboarding and sign-in open the finance dashboard', (
    tester,
  ) async {
    await _signInToDashboard(tester);

    expect(find.text('Hi, User 👋'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('\$1,250.00'), findsOneWidget);
    expect(find.text('Spending overview'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Recent transactions'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recent transactions'), findsOneWidget);
  });

  testWidgets('adding an expense updates balance and transaction list', (
    tester,
  ) async {
    await _signInToDashboard(tester);
    await tester.tap(find.byKey(const Key('addTransactionButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('transactionAmountField')),
      '12.50',
    );
    await tester.enterText(
      find.byKey(const Key('transactionNameField')),
      'Test purchase',
    );
    await tester.tap(find.byKey(const Key('saveTransactionButton')));
    await tester.pumpAndSettle();

    expect(find.text('\$1,237.50'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Test purchase'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Test purchase'), findsOneWidget);
  });

  testWidgets('bottom navigation opens all finance tabs', (tester) async {
    await _signInToDashboard(tester);

    await tester.tap(find.byTooltip('Transactions'));
    await tester.pumpAndSettle();
    expect(find.text('Transactions'), findsNWidgets(2));
    await tester.tap(find.byKey(const Key('filterIncome')));
    await tester.pumpAndSettle();
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Food'), findsNothing);

    await tester.tap(find.byTooltip('Analytics'));
    await tester.pumpAndSettle();
    expect(find.text('Cash flow'), findsOneWidget);
    expect(find.text('Expense by category'), findsOneWidget);

    await tester.tap(find.byTooltip('Budget'));
    await tester.pumpAndSettle();
    expect(find.text('October 2026'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Savings goals'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Savings goals'), findsOneWidget);

    await tester.tap(find.byTooltip('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Personal information'), findsOneWidget);
    expect(find.text('Dark Mode'), findsOneWidget);
  });

  testWidgets('user can add a budget and savings goal', (tester) async {
    await _signInToDashboard(tester);

    await tester.tap(find.byTooltip('Budget'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addBudgetButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).last, '400');
    await tester.tap(find.byKey(const Key('saveBudgetButton')));
    await tester.pumpAndSettle();
    expect(find.text('Food'), findsWidgets);

    await tester.ensureVisible(find.byTooltip('Savings goals'));
    await tester.tap(find.byTooltip('Savings goals'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('addGoalButton')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'New Camera');
    await tester.enterText(find.byType(TextFormField).at(1), '1200');
    await tester.tap(find.byKey(const Key('saveGoalButton')));
    await tester.pumpAndSettle();
    expect(find.text('New Camera'), findsOneWidget);
  });
}
