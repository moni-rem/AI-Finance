part of '../app/app.dart';

class _ProfilePage extends StatefulWidget {
  const _ProfilePage({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.pin,
    required this.onPersonalInformationChanged,
    required this.onPinChanged,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.isAuthenticated,
    required this.darkMode,
    required this.themeColor,
    required this.onDarkModeChanged,
    required this.onThemeColorChanged,
  });

  final String name;
  final String email;
  final String phone;
  final String location;
  final String pin;
  final ValueChanged<
    ({String name, String email, String phone, String location})
  >
  onPersonalInformationChanged;
  final ValueChanged<String> onPinChanged;
  final Future<void> Function() onLogout;
  final Future<void> Function() onDeleteAccount;
  final bool isAuthenticated;
  final bool darkMode;
  final Color themeColor;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<Color> onThemeColorChanged;

  @override
  State<_ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<_ProfilePage> {
  Future<void> _editPersonalInformation() async {
    final result = await Navigator.of(context)
        .push<({String name, String email, String phone, String location})>(
          MaterialPageRoute(
            builder: (_) => _PersonalInformationPage(
              name: widget.name,
              email: widget.email,
              phone: widget.phone,
              location: widget.location,
            ),
          ),
        );
    if (result == null) return;
    widget.onPersonalInformationChanged(result);
  }

  Future<void> _editPin() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        fullscreenDialog: true,
        builder: (_) => _PinSetupPage(currentPin: widget.pin),
      ),
    );
    if (result == null) return;
    widget.onPinChanged(result);
  }

  Future<void> _showHelpSupport() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Help & Support',
                      style: TextStyle(
                        color: _white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close help',
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded, color: _muted),
                  ),
                ],
              ),
              Text(
                'Quick answers for using your finance tracker.',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: const [
                    _HelpAnswer(
                      question: 'How do I save my data?',
                      answer:
                          'Create an account or sign in with email and password. Guest mode is for exploring; it does not keep changes after you leave.',
                    ),
                    _HelpAnswer(
                      question: 'How do I add a transaction?',
                      answer:
                          'Open Transactions, tap the plus button, choose income or expense, enter the amount and details, then save. Saved transactions update your totals.',
                    ),
                    _HelpAnswer(
                      question: 'How do budgets work?',
                      answer:
                          'Open Budget and add a category with its spending limit. Expenses in a matching category count toward that budget.',
                    ),
                    _HelpAnswer(
                      question: 'What does the security PIN do?',
                      answer:
                          'Create a six-digit PIN in Profile > Security. It is stored securely on this device and is required when you reopen the app. It is not your account password or a recovery code.',
                    ),
                    _HelpAnswer(
                      question: 'I cannot sign in or save data',
                      answer:
                          'Check your internet connection and make sure you use the same email you registered with. If an error continues, note the exact message and contact the person who manages this app.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _confirmDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account, transactions, budgets, and goals. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed == true) await widget.onDeleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      children: [
        const _PageTitle('Profile'),
        const SizedBox(height: 18),
        _ProfileIdentityCard(
          name: widget.name,
          email: widget.email,
          location: widget.location,
          darkMode: widget.darkMode,
          onTap: _editPersonalInformation,
        ),
        const SizedBox(height: 20),
        _ProfileGroup(
          label: 'MY PROFILE',
          children: [
            _ProfileTile(
              icon: Icons.person_outline_rounded,
              title: 'Personal information',
              subtitle: 'Manage your personal details',
              onTap: _editPersonalInformation,
            ),
            _ProfileTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Currency',
              subtitle: 'All amounts are shown in US dollars',
              trailing: Text('USD', style: TextStyle(color: _muted)),
              showChevron: false,
              onTap: () =>
                  _showToast(context, 'USD is the only supported currency.'),
            ),
            _ProfileTile(
              icon: Icons.lock_outline_rounded,
              title: 'Security',
              subtitle: widget.pin.isEmpty
                  ? 'Set a six-digit PIN'
                  : 'PIN protects this device',
              onTap: _editPin,
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ProfileGroup(
          label: 'APP PREFERENCES',
          children: [
            _ProfileTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark mode',
              subtitle: 'Adjust the app appearance',
              showChevron: false,
              trailing: Switch(
                value: widget.darkMode,
                activeThumbColor: _cyan,
                onChanged: widget.onDarkModeChanged,
              ),
              onTap: () => widget.onDarkModeChanged(!widget.darkMode),
            ),
            _ProfileTile(
              icon: Icons.palette_outlined,
              title: 'Theme color',
              subtitle: 'Choose your app accent color',
              trailing: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.themeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white24
                        : Colors.black12,
                  ),
                ),
              ),
              onTap: () async {
                final selected = await showModalBottomSheet<Color>(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Choose theme color',
                              style: TextStyle(
                                color: _white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        for (final option in _themeColors)
                          ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: option.$2,
                                shape: BoxShape.circle,
                              ),
                            ),
                            title: Text(option.$1),
                            trailing: option.$2 == widget.themeColor
                                ? Icon(Icons.check_rounded, color: option.$2)
                                : null,
                            onTap: () => Navigator.pop(context, option.$2),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
                if (selected != null) widget.onThemeColorChanged(selected);
              },
            ),
            _ProfileTile(
              icon: Icons.language_rounded,
              title: 'Language',
              subtitle: 'Choose your display language',
              trailing: Text('English', style: TextStyle(color: _muted)),
              onTap: () => _showToast(context, 'English selected'),
            ),
            _ProfileTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & support',
              subtitle: 'FAQs and app guidance',
              onTap: _showHelpSupport,
            ),
            _ProfileTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'Read the terms for using Finora',
              onTap: () => showLegalDocument(
                context,
                title: 'Terms of Service',
                content: termsOfServiceText,
              ),
            ),
            _ProfileTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How Finora handles your data',
              onTap: () => showLegalDocument(
                context,
                title: 'Privacy Policy',
                content: privacyPolicyText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _ProfileTile(
          icon: Icons.logout_rounded,
          title: 'Log out',
          subtitle: 'Sign out of your account',
          iconColor: _red,
          textColor: _red,
          onTap: widget.onLogout,
        ),
        const SizedBox(height: 12),
        _ProfileTile(
          icon: Icons.delete_forever_outlined,
          title: 'Delete account',
          subtitle: widget.isAuthenticated
              ? 'Permanently delete your account and saved data'
              : 'Sign in to delete an account',
          iconColor: _red,
          textColor: _red,
          onTap: widget.isAuthenticated
              ? _confirmDeleteAccount
              : () => _showToast(context, 'Sign in to delete your account.'),
        ),
      ],
    );
  }
}

class _ProfileIdentityCard extends StatelessWidget {
  const _ProfileIdentityCard({
    required this.name,
    required this.email,
    required this.location,
    required this.darkMode,
    required this.onTap,
  });

  final String name;
  final String email;
  final String location;
  final bool darkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nameFill = darkMode
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.82);
    final borderColor = darkMode
        ? Colors.white.withValues(alpha: 0.09)
        : const Color(0xFFE8DCEB);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: darkMode
                  ? const [Color(0xFF302432), Color(0xFF241B27)]
                  : const [Color(0xFFF1E8F4), Color(0xFFFFFCFF)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: (darkMode ? Colors.black : _purple).withValues(
                  alpha: darkMode ? 0.18 : 0.09,
                ),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _purple.withValues(alpha: 0.55),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withValues(alpha: 0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      backgroundColor: _purple.withValues(alpha: 0.15),
                      child: Icon(
                        Icons.person_rounded,
                        color: _purple,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      children: [
                        _ProfileCardField(
                          icon: Icons.person_outline_rounded,
                          value: name.isEmpty ? 'Your name' : name,
                          placeholder: name.isEmpty,
                          fill: nameFill,
                          border: borderColor,
                          darkMode: darkMode,
                        ),
                        const SizedBox(height: 7),
                        _ProfileCardField(
                          icon: Icons.mail_outline_rounded,
                          value: email.isEmpty ? 'Email address' : email,
                          placeholder: email.isEmpty,
                          fill: nameFill,
                          border: borderColor,
                          darkMode: darkMode,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 16, color: _purple),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      location.isEmpty ? 'Add your location' : location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: location.isEmpty ? _muted : _white,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Text(
                    'EDIT PROFILE',
                    style: TextStyle(
                      color: _purple,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.arrow_forward_rounded, color: _purple, size: 15),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileCardField extends StatelessWidget {
  const _ProfileCardField({
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.fill,
    required this.border,
    required this.darkMode,
  });

  final IconData icon;
  final String value;
  final bool placeholder;
  final Color fill;
  final Color border;
  final bool darkMode;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: border),
    ),
    child: Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: darkMode ? const Color(0xFFCFBBD3) : const Color(0xFF92719A),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: placeholder ? _muted : _white,
              fontSize: 11,
              fontWeight: placeholder ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PersonalInformationPage extends StatefulWidget {
  const _PersonalInformationPage({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
  });

  final String name;
  final String email;
  final String phone;
  final String location;

  @override
  State<_PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<_PersonalInformationPage> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.name);
  late final _email = TextEditingController(text: widget.email);
  late final _phone = TextEditingController(text: widget.phone);
  late final _location = TextEditingController(text: widget.location);

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _location.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, (
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      location: _location.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF101010);
    final inputStyle = Theme.of(
      context,
    ).textTheme.bodyLarge?.copyWith(color: Colors.white, fontSize: 16);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: background,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: background,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 62,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: Colors.white,
                    ),
                    const Expanded(
                      child: Text(
                        'Profile',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _save,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF292929),
                        shape: const StadiumBorder(),
                      ),
                      child: const Text('Save'),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      Container(
                        color: Colors.black,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 38,
                              backgroundColor: _purple.withValues(alpha: 0.24),
                              child: Icon(
                                Icons.person_rounded,
                                color: _purple,
                                size: 38,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _name,
                                    style: inputStyle,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: _profileInputDecoration(
                                      'Full name',
                                    ),
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                        ? 'Enter your name'
                                        : null,
                                  ),
                                  const Divider(
                                    height: 1,
                                    color: Color(0xFF383838),
                                  ),
                                  TextFormField(
                                    controller: _email,
                                    style: inputStyle,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: _profileInputDecoration(
                                      'Email address',
                                    ),
                                    validator: (value) {
                                      final email = value?.trim() ?? '';
                                      return RegExp(
                                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                          ).hasMatch(email)
                                          ? null
                                          : 'Enter a valid email address';
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _profileSectionHeader('PERSONAL INFORMATION'),
                      _profileEditRow(
                        label: 'Phone number',
                        controller: _phone,
                        style: inputStyle,
                        hint: 'Add phone number',
                        keyboardType: TextInputType.phone,
                      ),
                      _profileEditRow(
                        label: 'Location',
                        controller: _location,
                        style: inputStyle,
                        hint: 'City or region',
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(22, 4, 22, 22),
                        child: Text(
                          'Your profile details help personalize your finance experience.',
                          style: TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

InputDecoration _profileInputDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(color: Color(0xFF8C8C8C), fontSize: 15),
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
  contentPadding: const EdgeInsets.symmetric(vertical: 14),
);

Widget _profileSectionHeader(String title) => Container(
  width: double.infinity,
  color: Colors.black,
  padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
  child: Text(
    title,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  ),
);

Widget _profileEditRow({
  required String label,
  required TextEditingController controller,
  required TextStyle? style,
  required String hint,
  TextInputType? keyboardType,
}) => Container(
  color: const Color(0xFF121212),
  padding: const EdgeInsets.fromLTRB(22, 12, 22, 12),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
      ),
      TextFormField(
        controller: controller,
        style: style,
        keyboardType: keyboardType,
        decoration: _profileInputDecoration(hint),
      ),
      const Divider(height: 1, color: Color(0xFF292929)),
    ],
  ),
);

class _PinSetupPage extends StatefulWidget {
  const _PinSetupPage({required this.currentPin});

  final String currentPin;

  @override
  State<_PinSetupPage> createState() => _PinSetupPageState();
}

class _PinUnlockPage extends StatefulWidget {
  const _PinUnlockPage({required this.onVerify, required this.onUnlocked});

  final Future<bool> Function(String pin) onVerify;
  final VoidCallback onUnlocked;

  @override
  State<_PinUnlockPage> createState() => _PinUnlockPageState();
}

class _PinUnlockPageState extends State<_PinUnlockPage> {
  final _controller = TextEditingController();
  bool _checking = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_controller.text.length != 6 || _checking) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    final valid = await widget.onVerify(_controller.text);
    if (!mounted) return;
    if (valid) {
      widget.onUnlocked();
      return;
    }
    setState(() {
      _checking = false;
      _error = 'Incorrect PIN. Try again.';
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: _purple.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      color: _purple,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      color: Color(0xFF17202A),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your six-digit PIN to unlock your finances.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF777D88), fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => setState(() => _error = null),
                    onSubmitted: (_) => _unlock(),
                    decoration: InputDecoration(
                      hintText: '••••••',
                      counterText: '',
                      errorText: _error,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFFD8DCE3)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _controller.text.length == 6 && !_checking
                          ? _unlock
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: _purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _checking
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Unlock'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _PinSetupPageState extends State<_PinSetupPage> {
  final _codeController = TextEditingController();
  late int _step = widget.currentPin.isEmpty ? 1 : 0;
  String _chosenPin = '';
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _clearCode() {
    _codeController.clear();
  }

  void _continue() {
    final code = _codeController.text;
    if (code.length != 6) return;
    setState(() {
      _error = null;
      if (_step == 0) {
        if (code != widget.currentPin) {
          _error = 'That PIN does not match your current code.';
          _clearCode();
          return;
        }
        _step = 1;
        _clearCode();
        return;
      }
      if (_step == 1) {
        _chosenPin = code;
        _step = 2;
        _clearCode();
        return;
      }
      if (code != _chosenPin) {
        _error = 'The codes do not match. Please try again.';
        _clearCode();
        return;
      }
      _step = 3;
    });
  }

  void _removePin() {
    if (_codeController.text != widget.currentPin) {
      setState(() {
        _error = 'Enter your current PIN to remove it.';
        _clearCode();
      });
      return;
    }
    Navigator.pop(context, '');
  }

  String get _title => switch (_step) {
    0 => 'Confirm current PIN',
    1 => 'Create your PIN',
    2 => 'Confirm security code',
    _ => 'Welcome home!',
  };

  String get _subtitle => switch (_step) {
    0 => 'Enter your current code to continue.',
    1 => 'Choose a six-digit code. You will confirm it next.',
    2 => 'Enter your code again to confirm it.',
    _ => 'Your new security code is ready.',
  };

  Widget _buildCodeInput() => Semantics(
    label: 'Six-digit security code',
    child: SizedBox(
      height: 54,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TextField(
            controller: _codeController,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            obscureText: true,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.transparent, fontSize: 24),
            cursorColor: Colors.transparent,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: (_) => setState(() => _error = null),
          ),
          IgnorePointer(
            child: Row(
              children: [
                for (var index = 0; index < 6; index++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 30,
                            child: Center(
                              child: index < _codeController.text.length
                                  ? const Icon(
                                      Icons.circle,
                                      color: Color(0xFF17202A),
                                      size: 8,
                                    )
                                  : null,
                            ),
                          ),
                          Container(
                            height: 2,
                            decoration: BoxDecoration(
                              color: index == _codeController.text.length
                                  ? _purple
                                  : const Color(0xFFD8DCE3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSuccess() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 112,
        height: 112,
        decoration: BoxDecoration(
          color: _purple.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.home_rounded, size: 54, color: _purple),
      ),
      const SizedBox(height: 26),
      const Text(
        'Welcome home!',
        style: TextStyle(
          color: Color(0xFF17202A),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 9),
      const Text(
        'Your new security code is ready.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF777D88), fontSize: 14),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton(
          onPressed: () => Navigator.pop(context, _chosenPin),
          style: FilledButton.styleFrom(
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text('Finish'),
        ),
      ),
    ],
  );

  Widget _buildSetup() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        _title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF17202A),
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        _subtitle,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF777D88),
          fontSize: 14,
          height: 1.45,
        ),
      ),
      const SizedBox(height: 34),
      _buildCodeInput(),
      SizedBox(
        height: 34,
        child: _error == null
            ? null
            : Align(
                alignment: Alignment.center,
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _red, fontSize: 12),
                ),
              ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        height: 54,
        child: FilledButton(
          onPressed: _codeController.text.length == 6 ? _continue : null,
          style: FilledButton.styleFrom(
            backgroundColor: _purple,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _purple.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Text(_step == 2 ? 'Confirm PIN' : 'Continue'),
        ),
      ),
      if (_step == 0) ...[
        const SizedBox(height: 10),
        TextButton(onPressed: _removePin, child: const Text('Remove PIN')),
      ],
    ],
  );

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8F9FC);
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Create PIN', style: TextStyle(fontSize: 17)),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: _step == 3 ? _buildSuccess() : _buildSetup(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileGroup extends StatelessWidget {
  const _ProfileGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: _muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: dark ? _panel : Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: dark ? _line : const Color(0xFFE7E3E0)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 52),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: dark ? _line : const Color(0xFFEAE7E5),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.showChevron = true,
    this.iconColor,
    this.textColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showChevron;
  final Color? iconColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? _purple, size: 22),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor ?? _white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: _muted, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            ?trailing,
            if (showChevron)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: _muted,
                  size: 19,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HelpAnswer extends StatelessWidget {
  const _HelpAnswer({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: const EdgeInsets.symmetric(horizontal: 4),
    childrenPadding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
    iconColor: _purple,
    collapsedIconColor: _muted,
    title: Text(
      question,
      style: TextStyle(
        color: _white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Text(
          answer,
          style: TextStyle(color: _muted, fontSize: 13, height: 1.45),
        ),
      ),
    ],
  );
}
