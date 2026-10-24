part of '../app/app.dart';

class _AuthPage extends StatefulWidget {
  const _AuthPage({
    required this.isSignUp,
    required this.onBack,
    required this.onSwitch,
    required this.onComplete,
  });

  final bool isSignUp;
  final VoidCallback onBack;
  final VoidCallback onSwitch;
  final VoidCallback onComplete;

  @override
  State<_AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<_AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (widget.isSignUp && !_agreeToTerms) {
      _showToast(
        context,
        'Please agree to the Terms of Service and Privacy Policy.',
      );
      return;
    }
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final isSignUp = widget.isSignUp;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: widget.onBack,
            tooltip: 'Back',
            icon: Icon(Icons.arrow_back_rounded, color: _white),
          ),
        ),
        const SizedBox(height: 2),
        if (!isSignUp) ...[
          const _AuthWelcomeCard(),
          const SizedBox(height: 22),
        ] else ...[
          Text(
            'Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _white,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Join today and take control of your finances.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 14),
          ),
          const SizedBox(height: 24),
        ],
        Form(
          key: _formKey,
          child: Column(
            children: [
              if (isSignUp) ...[
                _authField(
                  key: const Key('authNameField'),
                  controller: _nameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your name'
                      : null,
                ),
                const SizedBox(height: 12),
              ],
              _authField(
                key: const Key('authEmailField'),
                controller: _emailController,
                hint: isSignUp ? 'Email Address' : 'Email',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final email = value?.trim() ?? '';
                  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
                      ? null
                      : 'Enter a valid email address';
                },
              ),
              const SizedBox(height: 12),
              _authField(
                key: const Key('authPasswordField'),
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscureText: _hidePassword,
                textInputAction: isSignUp
                    ? TextInputAction.next
                    : TextInputAction.done,
                onFieldSubmitted: isSignUp ? null : (_) => _submit(),
                suffix: IconButton(
                  tooltip: _hidePassword ? 'Show password' : 'Hide password',
                  onPressed: () =>
                      setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(
                    _hidePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: _muted,
                  ),
                ),
                validator: (value) => value == null || value.length < 6
                    ? 'Use at least 6 characters'
                    : null,
              ),
              if (isSignUp) ...[
                const SizedBox(height: 12),
                _authField(
                  key: const Key('authConfirmPasswordField'),
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: _hideConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  suffix: IconButton(
                    tooltip: _hideConfirmPassword
                        ? 'Show password'
                        : 'Hide password',
                    onPressed: () => setState(
                      () => _hideConfirmPassword = !_hideConfirmPassword,
                    ),
                    icon: Icon(
                      _hideConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _muted,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirm your password';
                    }
                    return value == _passwordController.text
                        ? null
                        : 'Passwords do not match';
                  },
                ),
              ],
            ],
          ),
        ),
        if (isSignUp) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 32,
                height: 40,
                child: Checkbox(
                  value: _agreeToTerms,
                  activeColor: _purple,
                  onChanged: (value) =>
                      setState(() => _agreeToTerms = value ?? false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  children: [
                    Text(
                      'I agree to the ',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () => _showToast(context, 'Terms of Service'),
                      child: Text(
                        'Terms of Service',
                        style: TextStyle(
                          color: _purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      ' and ',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                    GestureDetector(
                      onTap: () => _showToast(context, 'Privacy Policy'),
                      child: Text(
                        'Privacy Policy',
                        style: TextStyle(
                          color: _purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  _showToast(context, 'Password reset is not connected yet.'),
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: _purple, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: FilledButton(
            key: const Key('authSubmitButton'),
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: _purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSignUp ? 'Create Account' : 'Sign In',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: Divider(color: _line)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text('OR', style: TextStyle(color: _muted, fontSize: 12)),
            ),
            Expanded(child: Divider(color: _line)),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _AuthSocialButton(
              label: 'Google',
              icon: Icons.g_mobiledata_rounded,
            ),
            SizedBox(width: 12),
            _AuthSocialButton(label: 'Apple', icon: Icons.apple_rounded),
            SizedBox(width: 12),
            _AuthSocialButton(label: 'Facebook', icon: Icons.facebook_rounded),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              isSignUp
                  ? 'Already have an account? '
                  : "Don't have an account? ",
              style: TextStyle(color: _muted, fontSize: 13),
            ),
            TextButton(
              onPressed: widget.onSwitch,
              child: Text(
                isSignUp ? 'Sign In' : 'Sign Up',
                style: TextStyle(color: _purple, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Demo: use any valid email and a 6+ character password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 10),
        ),
      ],
    );
  }

  Widget _authField({
    Key? key,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    bool obscureText = false,
    Widget? suffix,
    void Function(String)? onFieldSubmitted,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: _purple.withValues(alpha: 0.10)),
    );
    return TextFormField(
      key: key,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(color: _white, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _muted.withValues(alpha: 0.88)),
        prefixIcon: Icon(icon, color: _muted, size: 22),
        suffixIcon: suffix,
        filled: true,
        fillColor: _activeDarkMode ? _panel : const Color(0xFFF0F0F3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(color: _purple, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: _red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: _red, width: 1.4),
        ),
      ),
    );
  }
}

class _AuthWelcomeCard extends StatelessWidget {
  const _AuthWelcomeCard();

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.black, Colors.transparent],
          stops: [0, 0.70, 1],
        ).createShader(bounds),
        child: SizedBox(
          width: double.infinity,
          height: 238,
          child: Image.asset(
            'assets/images/login_finance_hero.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
        child: Column(
          children: [
            Text(
              'Welcome Back',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Sign in to continue your financial journey and stay on top of your money.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontSize: 13, height: 1.35),
            ),
          ],
        ),
      ),
    ],
  );
}

class _AuthSocialButton extends StatelessWidget {
  const _AuthSocialButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: '$label sign-in is a demo action',
    child: OutlinedButton(
      onPressed: () => _showToast(context, '$label sign-in is a demo action.'),
      style: OutlinedButton.styleFrom(
        foregroundColor: _white,
        backgroundColor: _activeDarkMode
            ? _panel
            : Colors.white.withValues(alpha: 0.72),
        side: BorderSide(color: _purple.withValues(alpha: 0.13)),
        minimumSize: const Size(62, 58),
        padding: const EdgeInsets.symmetric(horizontal: 17),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
      ),
      child: Icon(icon, size: 25),
    ),
  );
}
