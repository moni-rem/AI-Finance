part of '../app/app.dart';

class _SplashPage extends StatelessWidget {
  const _SplashPage({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 34),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _purple.withValues(alpha: 0.30),
                        _purple.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -0.12,
                  child: Container(
                    width: 112,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFB272FF), _purple],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withValues(alpha: 0.45),
                          blurRadius: 34,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 28,
                  bottom: 52,
                  child: Container(
                    width: 50,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF392477),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFB38BFF)),
                    ),
                    child: const Icon(
                      Icons.circle,
                      size: 11,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Finance Tracker',
            style: TextStyle(
              color: _white,
              fontSize: 29,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.7,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Track · Plan · Save · Grow',
            style: TextStyle(color: _muted, fontSize: 14),
          ),
          const Spacer(),
          const _WaveMark(),
          const SizedBox(height: 28),
          _PrimaryButton(
            key: const Key('splashGetStartedButton'),
            label: 'Get Started',
            onPressed: onContinue,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.page,
    required this.onPageChanged,
    required this.onFinish,
  });

  final int page;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onFinish;

  static const _titles = [
    'Take Control\nOf Your Money',
    'Understand\nYour Spending',
    'Reach Your\nFinancial Goals',
  ];
  static const _subtitles = [
    'Track your income and expenses in one place.',
    'See where your money goes with clear charts.',
    'Save for what matters to you.',
  ];
  static const _icons = [
    Icons.phone_iphone_rounded,
    Icons.pie_chart_rounded,
    Icons.flag_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 20, 26, 32),
      child: Column(
        children: [
          const Spacer(),
          SizedBox(
            height: 255,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _purple.withValues(alpha: 0.11),
                  ),
                ),
                Container(
                  width: 164,
                  height: 210,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF4E5B81)),
                    boxShadow: [
                      BoxShadow(
                        color: _purple.withValues(alpha: 0.24),
                        blurRadius: 35,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icons[page], size: 66, color: _purple),
                      const SizedBox(height: 16),
                      Container(
                        width: 112,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _cyan.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _MiniBar(height: 25, color: _purple),
                          const SizedBox(width: 6),
                          const _MiniBar(height: 43, color: _cyan),
                          const SizedBox(width: 6),
                          const _MiniBar(height: 34, color: _orange),
                          const SizedBox(width: 6),
                          _MiniBar(height: 54, color: _purple),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  right: 62,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _orange,
                    ),
                    child: const Icon(
                      Icons.attach_money_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            _titles[page],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _white,
              fontSize: 27,
              fontWeight: FontWeight.w700,
              height: 1.14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _subtitles[page],
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 14),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: page == index ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: page == index ? _purple : const Color(0xFF414B68),
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _PrimaryButton(
            key: Key(
              page == 2 ? 'onboardingFinishButton' : 'onboardingNextButton',
            ),
            label: page == 2 ? 'Get Started' : 'Next',
            onPressed: page == 2 ? onFinish : () => onPageChanged(page + 1),
          ),
          TextButton(
            key: const Key('skipOnboardingButton'),
            onPressed: onFinish,
            child: Text('Skip', style: TextStyle(color: _muted)),
          ),
        ],
      ),
    );
  }
}
