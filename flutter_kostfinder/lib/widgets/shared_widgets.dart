import 'package:flutter/material.dart';
import '../Admin/theme/app_theme.dart';

// ─── PageHeader ───────────────────────────────────────────────────────────────

class PageHeader extends StatelessWidget {
  final String title;
  final String? italic;
  final String subtitle;

  const PageHeader({
    super.key,
    required this.title,
    this.italic,
    required this.subtitle,
  });

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
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(text: title),
              if (italic != null)
                TextSpan(
                  text: italic,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: AppColors.coral,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: muted, height: 1.4),
        ),
      ],
    );
  }
}

// ─── StatCard ─────────────────────────────────────────────────────────────────

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accentColor;
  final Color accentBg;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: textColor,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: muted,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── PillBadge ────────────────────────────────────────────────────────────────

class PillBadge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bgColor;

  const PillBadge({
    super.key,
    required this.text,
    required this.color,
    required this.bgColor,
  });

  // FIX: hapus PillBadge.green karena identik dengan PillBadge.teal (duplikat)
  factory PillBadge.teal(String text) => PillBadge(
        text: text,
        color: AppColors.teal,
        bgColor: AppColors.tealBg,
      );

  factory PillBadge.yellow(String text) => PillBadge(
        text: text,
        color: AppColors.yellow,
        bgColor: AppColors.yellowBg,
      );

  factory PillBadge.blue(String text) => PillBadge(
        text: text,
        color: AppColors.blue,
        bgColor: AppColors.blueBg,
      );

  factory PillBadge.coral(String text) => PillBadge(
        text: text,
        color: AppColors.coral,
        bgColor: AppColors.coralBg,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── SearchBar2 ───────────────────────────────────────────────────────────────

class SearchBar2 extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const SearchBar2({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? AppColors.cardDark : Colors.white;
    final border = isDark ? AppColors.borderDark : AppColors.borderLight;
    final muted = isDark ? AppColors.mutedDark : AppColors.mutedLight;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.textDark : AppColors.textLight,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: muted),
          prefixIcon: Icon(Icons.search_rounded, size: 18, color: muted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

// ─── KostTag ──────────────────────────────────────────────────────────────────

class KostTag extends StatelessWidget {
  final String label;

  const KostTag(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.borderDark : const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.mutedDark : AppColors.mutedLight,
        ),
      ),
    );
  }
}