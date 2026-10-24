part of '../app/app.dart';

class _ProfilePage extends StatelessWidget {
  const _ProfilePage({
    required this.darkMode,
    required this.currency,
    required this.themeColor,
    required this.onDarkModeChanged,
    required this.onThemeColorChanged,
    required this.onCurrencyChanged,
  });

  final bool darkMode;
  final String currency;
  final Color themeColor;
  final ValueChanged<bool> onDarkModeChanged;
  final ValueChanged<Color> onThemeColorChanged;
  final ValueChanged<String> onCurrencyChanged;

  @override
  Widget build(BuildContext context) {
    return _PageScroll(
      children: [
        const _PageTitle('Profile'),
        const SizedBox(height: 18),
        _ProfileGroup(
          label: 'MY PROFILE',
          children: [
            _ProfileTile(
              icon: Icons.person_outline_rounded,
              title: 'Personal information',
              subtitle: 'Manage your personal details',
              onTap: () => _showToast(context, 'Personal information'),
            ),
            _ProfileTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              subtitle: 'Manage alerts and preferences',
              onTap: () => _showToast(context, 'Notification preferences'),
            ),
            _ProfileTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Currency',
              subtitle: 'Choose your preferred currency',
              trailing: Text(currency, style: TextStyle(color: _muted)),
              onTap: () async {
                final value = await showModalBottomSheet<String>(
                  context: context,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  builder: (context) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final option in ['USD', 'EUR', 'GBP'])
                          ListTile(
                            title: Text(option),
                            trailing: option == currency
                                ? const Icon(Icons.check_rounded, color: _cyan)
                                : null,
                            onTap: () => Navigator.pop(context, option),
                          ),
                      ],
                    ),
                  ),
                );
                if (value != null) onCurrencyChanged(value);
              },
            ),
            _ProfileTile(
              icon: Icons.lock_outline_rounded,
              title: 'Security',
              subtitle: 'Review your account security',
              onTap: () => _showToast(context, 'Security settings'),
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
                value: darkMode,
                activeThumbColor: _cyan,
                onChanged: onDarkModeChanged,
              ),
              onTap: () => onDarkModeChanged(!darkMode),
            ),
            _ProfileTile(
              icon: Icons.palette_outlined,
              title: 'Theme color',
              subtitle: 'Choose your app accent color',
              trailing: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: themeColor,
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
                            trailing: option.$2 == themeColor
                                ? Icon(Icons.check_rounded, color: option.$2)
                                : null,
                            onTap: () => Navigator.pop(context, option.$2),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                );
                if (selected != null) onThemeColorChanged(selected);
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
              subtitle: 'Get help with the app',
              onTap: () => _showToast(context, 'How can we help?'),
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
          onTap: () => _showToast(context, 'You have been logged out.'),
        ),
      ],
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
