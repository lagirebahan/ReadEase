import 'package:flutter/material.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();

    return Scaffold(
      backgroundColor: theme.baseBg,
      appBar: AppBar(
        backgroundColor: theme.surfaceBg,
        elevation: 0,
        title: Text(
          'Settings',
          style: theme.baseTextStyle(theme.primaryTextColor).copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'Georgia',
              ),
        ),
        iconTheme: IconThemeData(color: theme.primaryTextColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: theme.borderColor),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          _SectionHeader(label: 'Reading Experience', theme: theme),
          const SizedBox(height: 12),

          _SettingCard(
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Font Size',
                        style: theme
                            .baseTextStyle(theme.primaryTextColor)
                            .copyWith(fontWeight: FontWeight.w600)),
                    Text('${theme.fontSize.toStringAsFixed(1)}pt',
                        style: theme.baseTextStyle(
                            theme.primaryTextColor.withOpacity(0.5))),
                  ],
                ),
                Slider(
                  value: theme.fontSize,
                  min: 10,
                  max: 28,
                  divisions: 18,
                  activeColor: theme.accentColor,
                  onChanged: (v) =>
                      context.read<AppTheme>().setFontSize(v),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.baseBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.borderColor),
                  ),
                  child: Text(
                    'The quick brown fox jumps over the lazy dog.',
                    style: theme.baseTextStyle(
                      theme.useAccentForText ? theme.accentColor : theme.primaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _SettingCard(
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Letter Spacing',
                          style: theme
                              .baseTextStyle(theme.primaryTextColor)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${theme.letterSpacing.toStringAsFixed(1)}px',
                          style: theme.baseTextStyle(
                            theme.primaryTextColor.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Slider(
                  value: theme.letterSpacing,
                  min: -1.0,
                  max: 5.0,
                  divisions: 60,
                  activeColor: theme.accentColor,
                  onChanged: (v) =>
                      context.read<AppTheme>().setLetterSpacing(v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _SettingCard(
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Font',
                    style: theme
                        .baseTextStyle(theme.primaryTextColor)
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Default',
                    'Georgia',
                    'Monospace',
                    'Lexend',
                    'OpenDyslexic'
                  ].map((font) {
                    final selected = theme.fontFamily == font;
                    return ChoiceChip(
                      label: Text(
                        font,
                        style: TextStyle(
                          fontFamily: font == 'Default' ? null : font,
                          color: selected
                              ? Colors.white
                              : theme.primaryTextColor,
                        ),
                      ),
                      selected: selected,
                      selectedColor: theme.accentColor,
                      backgroundColor: theme.baseBg,
                      side: BorderSide(color: theme.borderColor),
                      onSelected: (_) =>
                          context.read<AppTheme>().setFontFamily(font),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _SettingCard(
            theme: theme,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Use Accent Color for Note Text',
                          style: theme
                              .baseTextStyle(theme.primaryTextColor)
                              .copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Apply your accent color to note body text',
                          style: theme.baseTextStyle(
                              theme.primaryTextColor.withOpacity(0.5)).copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                Switch(
                  value: theme.useAccentForText,
                  activeColor: theme.accentColor,
                  onChanged: (v) =>
                      context.read<AppTheme>().setUseAccentForText(v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _SectionHeader(label: 'Appearance', theme: theme),
          const SizedBox(height: 12),

          _SettingCard(
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Background',
                    style: theme
                        .baseTextStyle(theme.primaryTextColor)
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _BgModeOption(
                      theme: theme,
                      mode: BgMode.light,
                      label: 'Light',
                      icon: Icons.light_mode_outlined,
                    ),
                    const SizedBox(width: 10),
                    _BgModeOption(
                      theme: theme,
                      mode: BgMode.dark,
                      label: 'Dark',
                      icon: Icons.dark_mode_outlined,
                    ),
                    const SizedBox(width: 10),
                    _BgModeOption(
                      theme: theme,
                      mode: BgMode.amoled,
                      label: 'AMOLED',
                      icon: Icons.brightness_1_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          _SettingCard(
            theme: theme,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Accent Color',
                    style: theme
                        .baseTextStyle(theme.primaryTextColor)
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Colors.white,
                    Colors.black,
                    Colors.deepPurple,
                    Colors.indigo,
                    Colors.blue,
                    Colors.teal,
                    Colors.green,
                    Colors.orange,
                    Colors.pink,
                    Colors.red,
                  ].map((color) {
                    final selected =
                        theme.accentColor.value == color.value;
                    return GestureDetector(
                      onTap: () =>
                          context.read<AppTheme>().setAccentColor(color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selected
                              ? Border.all(
                                  color: theme.primaryTextColor, width: 3)
                              : Border.all(
                                  color: theme.borderColor, width: 1.5),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 8)
                                ]
                              : null,
                        ),
                        child: selected
                            ? Icon(Icons.check,
                                color: (color == Colors.white) ? Colors.black : Colors.white,
                                size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _SectionHeader(label: 'Account', theme: theme),
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text('Log Out',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Log Out'),
                    content: const Text(
                        'Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Log Out',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await AuthService.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  }
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.red.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.refresh_rounded, color: Colors.red),
              label: const Text('Reset to Defaults',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Reset Settings'),
                    content: const Text(
                        'This will restore all appearance and reading settings to their defaults.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reset',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  context.read<AppTheme>().reset();
                }
              },
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final AppTheme theme;
  const _SectionHeader({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: theme
          .baseTextStyle(theme.primaryTextColor.withOpacity(0.45))
          .copyWith(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final AppTheme theme;
  final Widget child;
  const _SettingCard({required this.theme, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.borderColor),
      ),
      child: child,
    );
  }
}

class _BgModeOption extends StatelessWidget {
  final AppTheme theme;
  final BgMode mode;
  final String label;
  final IconData icon;
  const _BgModeOption(
      {required this.theme,
      required this.mode,
      required this.label,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    final selected = theme.bgMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<AppTheme>().setBgMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? theme.accentColor.withOpacity(0.12)
                : theme.baseBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? theme.accentColor : theme.borderColor,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: selected
                      ? theme.accentColor
                      : theme.primaryTextColor.withOpacity(0.5),
                  size: 22),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: selected
                          ? theme.accentColor
                          : theme.primaryTextColor.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.normal)),
            ],
          ),
        ),
      ),
    );
  }
}