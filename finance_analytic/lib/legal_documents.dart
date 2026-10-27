import 'package:flutter/material.dart';

const termsOfServiceText = '''
Effective date: 27 October 2026

1. About Finora
Finora: Finance Tracker helps you record income and expenses, set budgets and savings goals, review summaries, and use optional AI-generated money insights. The app is a personal tracking and education tool. It is not a bank, financial adviser, accountant, or investment service.

2. Your account and data
You are responsible for keeping your sign-in credentials private and for the accuracy of information you enter. Signed-in account data is stored with Firebase services. Guest sessions are temporary and are not synced to an account; guest data can be lost when you leave or reset the app. You can request deletion from Profile > Delete account. Account deletion removes the app account and its stored profile, transaction, budget, and goal records, subject to completion of the deletion process.

3. AI money coach
When the online AI feature is enabled, your prompt, recent conversation, and selected financial summaries are sent to the Finora AI backend and Google Gemini to generate a response. Do not include passwords, card numbers, bank credentials, or other secrets in prompts. AI responses can be incomplete or inaccurate and are for general information only. Check all figures and make your own decisions.

4. Acceptable use
Use the app lawfully and do not attempt to disrupt, probe, or misuse its services, accounts, or infrastructure.

5. Availability and changes
We may update, suspend, or discontinue app features. We provide the app on an “as available” basis to the extent permitted by law. These terms do not limit rights that cannot legally be excluded.

6. Contact
For support, contact remphearomthunmony@gmail.com.
''';

const privacyPolicyText = '''
Effective date: 27 October 2026

Finora: Finance Tracker (“Finora”, “we”, or “the app”) helps you track personal finances. This policy describes information the current app handles.

Information you provide
When you register or sign in, Firebase Authentication processes your email and sign-in credentials; Google sign-in also provides account identity details. For signed-in users, Finora stores a display name, email, transactions (including names, categories, amounts, dates, and optional notes), budgets, and savings goals in Firebase Cloud Firestore. Optional phone and location profile fields are currently held in app memory and are not synced to Firestore. A security PIN is stored on your device using secure storage.

Guest use
Guest activity is temporary, kept in app memory, and is not synced to your Firebase account. It may be cleared when you leave or reset the app. Online AI requests require signing in.

AI feature and sharing
If the online AI assistant is enabled and you send a prompt, the app sends the prompt, recent chat history, and financial summaries (balance, income and expenses, spending totals by category, budgets, and recent transaction category, amount, and date) to the Finora backend. The backend forwards this request to Google Gemini to generate an answer. Transaction names and notes are not included in the financial summary. Google and Firebase process data under their own terms and privacy practices. The app can also use Firebase Authentication and Firestore to sign in and sync your account data.

Why information is used
Information is used to provide account access, save and display your records, calculate summaries, and answer AI prompts you choose to send. We do not sell your financial records.

Retention and deletion
Signed-in records remain in Firebase until you delete your account or the records. Use Profile > Delete account to delete the Firebase account and its transaction, budget, goal, and profile records. A recent sign-in may be required to confirm deletion. Guest data is temporary. Your device PIN is removed when you delete the account through the app.

Security
We use Firebase services and secure transport to handle account data. No online service or device storage can be guaranteed completely secure; keep your device and account credentials protected.

Children
Finora is intended for a general audience and is not designed specifically for children.

Changes and contact
We may update this policy when the app or its data practices change. For privacy questions, contact remphearomthunmony@gmail.com.
''';

Future<void> showLegalDocument(
  BuildContext context, {
  required String title,
  required String content,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: Theme.of(context).colorScheme.surface,
  builder: (context) => SafeArea(
    child: SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.84,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  content.trim(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
