import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ── Stat Card ──────────────────────────────────────────────────────────────
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String? change;
  final bool changeUp;
  final Color accentColor;
  final Color accentBg;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.change,
    this.changeUp = true,
    required this.accentColor,
    required this.accentBg,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentColor, accentColor.withOpacity(0.6)]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: accentBg, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Icon(icon, size: 16, color: accentColor)),
                  ),
                  const SizedBox(height: 6),
                  Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.5)),
                  const SizedBox(height: 1),
                  Text(label, style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (change != null) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: changeUp ? AppColors.greenBg : const Color(0x1AE53E3E),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        change!,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                          color: changeUp ? AppColors.green : const Color(0xFFE53E3E)),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pill Badge ─────────────────────────────────────────────────────────────
class PillBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bgColor;

  const PillBadge({super.key, required this.text, required this.color, required this.bgColor});

  factory PillBadge.green(String text) => PillBadge(text: text, color: AppColors.green, bgColor: AppColors.greenBg);
  factory PillBadge.coral(String text) => PillBadge(text: text, color: AppColors.coral, bgColor: AppColors.coralBg);
  factory PillBadge.teal(String text) => PillBadge(text: text, color: AppColors.teal, bgColor: AppColors.tealBg);
  factory PillBadge.yellow(String text) => PillBadge(text: text, color: AppColors.yellow, bgColor: AppColors.yellowBg);
  factory PillBadge.blue(String text) => PillBadge(text: text, color: AppColors.blue, bgColor: AppColors.blueBg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(100)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }
}

// ── Page Header ────────────────────────────────────────────────────────────
class PageHeader extends StatelessWidget {
  final String title;
  final String italic;
  final String subtitle;

  const PageHeader({super.key, required this.title, required this.italic, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textColor, letterSpacing: -0.3),
            children: [
              TextSpan(text: title.isEmpty ? '' : title),
              TextSpan(text: italic, style: const TextStyle(fontStyle: FontStyle.italic, color: AppColors.coral)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 13, color: muted)),
      ],
    );
  }
}

// ── User Avatar ────────────────────────────────────────────────────────────
class UserAvatar extends StatelessWidget {
  final String initials;
  final List<Color> gradientColors;
  final double size;
  final double fontSize;

  const UserAvatar({
    super.key,
    required this.initials,
    this.gradientColors = const [AppColors.coral, AppColors.coral2],
    this.size = 36,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: gradientColors),
      ),
      child: Center(
        child: Text(initials, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────────────
class SearchBar2 extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const SearchBar2({super.key, this.hint = 'Cari...', this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.cardDark : AppColors.cardLight;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;
    final text = isDark ? AppColors.textDark : AppColors.textLight;

    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, size: 18, color: AppColors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: text),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: muted, fontSize: 13, fontWeight: FontWeight.w400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }
}

// ── Section Label ──────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).brightness == Brightness.dark ? AppColors.mutedDark : AppColors.mutedLight;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.0, color: muted.withOpacity(0.6)),
      ),
    );
  }
}

// ── Kost Tag ───────────────────────────────────────────────────────────────
class KostTag extends StatelessWidget {
  final String text;
  const KostTag(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.bg2Dark : AppColors.bg2Light;
    final text2 = isDark ? AppColors.text2Dark : AppColors.text2Light;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: text2)),
    );
  }
}
