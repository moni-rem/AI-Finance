part of '../app/app.dart';

class _AuthPage extends StatefulWidget {
  const _AuthPage({
    required this.isSignUp,
    required this.isAccountGate,
    required this.onGuest,
    required this.onContinueWithoutSaving,
    required this.onBack,
    required this.onSwitch,
    required this.onComplete,
  });

  final bool isSignUp;
  final bool isAccountGate;
  final VoidCallback onGuest;
  final VoidCallback onContinueWithoutSaving;
  final VoidCallback onBack;
  final VoidCallback onSwitch;
  final Future<void> Function() onComplete;

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
  bool _isSubmitting = false;
  String? _authError;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (widget.isSignUp && !_agreeToTerms) {
      _showToast(
        context,
        'Please agree to the Terms of Service and Privacy Policy.',
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
      _authError = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      if (widget.isSignUp) {
        final credential = await auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        await credential.user?.updateDisplayName(_nameController.text.trim());
      } else {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      await widget.onComplete();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(
        () => _authError = switch (error.code) {
          'email-already-in-use' => 'An account already uses this email.',
          'invalid-email' => 'Enter a valid email address.',
          'user-not-found' ||
          'wrong-password' ||
          'invalid-credential' => 'Email or password is incorrect.',
          'weak-password' => 'Choose a stronger password.',
          'network-request-failed' =>
            'Check your internet connection and retry.',
          _ => error.message ?? 'Could not authenticate. Please try again.',
        },
      );
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(
        () => _authError = error.code == 'no-app'
            ? 'Firebase is not configured for this app yet.'
            : error.message ?? 'Firebase could not complete this request.',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _authError = 'Could not sign in: $error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _authError = null;
    });
    try {
      if (Firebase.apps.isEmpty) {
        throw StateError(
          'Firebase initialization failed: '
          '${firebaseInitializationError ?? 'no default Firebase app was created'}',
        );
      }
      final auth = FirebaseAuth.instance;
      if (foundation.kIsWeb) {
        await auth.signInWithPopup(GoogleAuthProvider());
      } else {
        _googleSignInInitialization ??= GoogleSignIn.instance.initialize();
        await _googleSignInInitialization;
        final googleUser = await GoogleSignIn.instance.authenticate();
        final googleAuth = googleUser.authentication;
        if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
          throw StateError(
            'Google did not return an ID token. Check the Web OAuth client in google-services.json and the Android SHA-1 in Firebase.',
          );
        }
        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );
        await auth.signInWithCredential(credential);
      }
      await widget.onComplete();
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(
        () => _authError = switch (error.code) {
          'no-app' => 'Firebase is not configured for this app yet.',
          'operation-not-allowed' =>
            'Enable Google as a sign-in provider in Firebase Authentication.',
          'app-not-authorized' =>
            'Add this Android app’s signing SHA-1 fingerprint in Firebase Project Settings.',
          _ => error.message ?? 'Google sign-in could not be completed.',
        },
      );
    } catch (error) {
      if (!mounted) return;
      final details = error.toString();
      if (details.toLowerCase().contains('cancel')) return;
      setState(
        () => _authError =
            'Google sign-in failed. Enable Google in Firebase Authentication and add this Android app’s SHA-1 fingerprint. Details: $details',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
        if (widget.isAccountGate) ...[
          Text(
            isSignUp ? 'Create an account to save' : 'Sign in to save',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _white,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Your change is ready. Sign in or register to save it.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13),
          ),
          const SizedBox(height: 22),
        ] else if (!isSignUp) ...[
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
        if (_authError != null) ...[
          const SizedBox(height: 10),
          Text(
            _authError!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _red, fontSize: 12),
          ),
        ],
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
                      onTap: () => showLegalDocument(
                        context,
                        title: 'Terms of Service',
                        content: termsOfServiceText,
                      ),
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
                      onTap: () => showLegalDocument(
                        context,
                        title: 'Privacy Policy',
                        content: privacyPolicyText,
                      ),
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
            onPressed: _isSubmitting ? null : _submit,
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
                if (_isSubmitting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
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
        Center(
          child: _AuthSocialButton(
            label: 'Google',
            icon: Icons.g_mobiledata_rounded,
            isLoading: _isSubmitting,
            onPressed: _isSubmitting ? null : _signInWithGoogle,
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          key: const Key('continueAsGuestButton'),
          onPressed: widget.isAccountGate
              ? widget.onContinueWithoutSaving
              : widget.onGuest,
          icon: const Icon(Icons.person_outline_rounded),
          label: Text(
            widget.isAccountGate
                ? 'Continue without saving'
                : 'Continue as Guest',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: _white,
            minimumSize: const Size(double.infinity, 52),
            side: BorderSide(color: _purple.withValues(alpha: 0.28)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.isAccountGate
              ? 'You can keep using the app as a guest. This change will not be saved.'
              : 'You can explore the app first. An account is required to save changes.',
          textAlign: TextAlign.center,
          style: TextStyle(color: _muted, fontSize: 11),
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
          'Sign in to save budgets to your account.',
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
  const _AuthSocialButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isLoading,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Continue with $label',
    child: OutlinedButton(
      onPressed: onPressed,
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
      child: isLoading
          ? SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: _purple),
            )
          : Icon(icon, size: 25),
    ),
  );
}
