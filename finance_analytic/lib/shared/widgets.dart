part of '../app/app.dart';

class _PageScroll extends StatelessWidget {
  const _PageScroll({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(17, 13, 17, 20),
        children: children,
      ),
    );
  }
}

class _NotebookGridPainter extends CustomPainter {
  const _NotebookGridPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 22.0;
    final grid = Paint()
      ..color = color
      ..strokeWidth = 0.8;
    for (var x = 0.0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
  }

  @override
  bool shouldRepaint(covariant _NotebookGridPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _KeepAlivePage extends StatefulWidget {
  const _KeepAlivePage({super.key, required this.child});

  final Widget child;

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

class _BottomNavBar extends StatefulWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.darkMode,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool darkMode;

  static const _items = [
    ('Home', Icons.home_outlined, Icons.home_rounded),
    ('Transactions', Icons.receipt_long_outlined, Icons.receipt_long_rounded),
    ('Analytics', Icons.analytics_outlined, Icons.analytics_rounded),
    ('Budget', Icons.pie_chart_outline_rounded, Icons.pie_chart_rounded),
    ('Profile', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  State<_BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<_BottomNavBar> {
  final _scrollController = ScrollController();
  final _itemKeys = List.generate(_BottomNavBar._items.length, (_) => GlobalKey());

  @override
  void didUpdateWidget(covariant _BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final itemContext = _itemKeys[widget.selectedIndex].currentContext;
        if (itemContext != null && _scrollController.hasClients) {
          Scrollable.ensureVisible(
            itemContext,
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutCubic,
            alignment: 0.5,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barColor = widget.darkMode
        ? const Color(0xFF30232E).withValues(alpha: 0.76)
        : Colors.white.withValues(alpha: 0.8);
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: widget.darkMode ? 0.2 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: widget.darkMode
                    ? Colors.white.withValues(alpha: 0.18)
                    : const Color(0xFFD4E4E8).withValues(alpha: 0.58),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 8, 5, 5),
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    for (var index = 0; index < _BottomNavBar._items.length; index++)
                      _NavItem(
                        key: _itemKeys[index],
                        item: _BottomNavBar._items[index],
                        selected: widget.selectedIndex == index,
                        darkMode: widget.darkMode,
                        onTap: () => widget.onSelected(index),
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
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.item,
    required this.selected,
    required this.darkMode,
    required this.onTap,
  });

  final (String, IconData, IconData) item;
  final bool selected;
  final bool darkMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: item.$1,
      child: Semantics(
        button: true,
        selected: selected,
        label: item.$1,
        child: InkWell(
          key: Key('nav${item.$1}'),
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            width: selected ? 150 : 64,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 5),
            decoration: BoxDecoration(
              color: selected ? _purple : Colors.transparent,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected ? item.$3 : item.$2,
                  size: 23,
                  color: selected
                      ? Colors.white
                      : (darkMode
                            ? const Color(0xFFB9AFB5)
                            : const Color(0xFF27232A)),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: selected
                      ? Row(
                          children: [
                            const SizedBox(width: 9),
                            Text(
                              item.$1,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.clip,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveMark extends StatelessWidget {
  const _WaveMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      width: double.infinity,
      child: CustomPaint(painter: _WavePainter()),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height * 0.45)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.18,
        size.width * 0.29,
        size.height * 0.9,
        size.width * 0.52,
        size.height * 0.55,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.25,
        size.width * 0.82,
        size.height * 0.76,
        size.width,
        size.height * 0.28,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = _purple.withValues(alpha: 0.42)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MiniBar extends StatelessWidget {
  const _MiniBar({required this.height, required this.color});

  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 13,
    height: height,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: Text(label, style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.prefix,
  });

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(color: _white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        prefix: prefix,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? _line
                : const Color(0xFFE1E5EF),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? _line
                : const Color(0xFFE1E5EF),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _purple),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Text(
      label,
      style: TextStyle(
        color: _white,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(14)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? _panel : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: dark ? _line : const Color(0xFFDCE9EB)),
        boxShadow: [
          if (!dark)
            BoxShadow(
              color: const Color(0xFF6F8790).withValues(alpha: 0.045),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: child,
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.color, this.size = 42});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(size * 0.28),
    ),
    child: Icon(icon, color: color, size: size * 0.5),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(
          title,
          style: TextStyle(
            color: _white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      if (actionLabel != null)
        TextButton(
          onPressed: onAction,
          style: TextButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 5),
          ),
          child: Text(
            actionLabel!,
            style: TextStyle(color: _cyan, fontSize: 10),
          ),
        ),
    ],
  );
}

class _PageTitle extends StatelessWidget {
  const _PageTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(
      color: _white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 38),
    child: Column(
      children: [
        Icon(icon, color: _muted, size: 36),
        const SizedBox(height: 10),
        Text(
          title,
          style: TextStyle(color: _white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 5),
        Text(subtitle, style: TextStyle(color: _muted, fontSize: 11)),
      ],
    ),
  );
}

IconData _categoryIcon(String category) => switch (category) {
  'Food' => Icons.restaurant_rounded,
  'Transport' => Icons.directions_car_rounded,
  'Shopping' => Icons.shopping_bag_rounded,
  'Bills' => Icons.receipt_long_rounded,
  'Entertainment' => Icons.movie_rounded,
  _ => Icons.more_horiz_rounded,
};

Color _categoryColor(String category) => switch (category) {
  'Food' => _cyan,
  'Transport' => _yellow,
  'Shopping' => _orange,
  'Bills' => _red,
  'Entertainment' => _purple,
  _ => _muted,
};

void _showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
  );
}
