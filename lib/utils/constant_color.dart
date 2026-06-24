import 'package:flutter/material.dart';

abstract class AppColors {
  AppColors._();

  // ─── Primary Accents ───────────────────────────────────────────────────────

  /// Muted Magenta — Primary Accent / Headlines
  static const Color mutedMagenta = Color(0xFF9C4675);

  /// Neon Petal — Soft Focus Containers
  static const Color neonPetal = Color(0xFFFF99CC);

  // ─── High Visibility ───────────────────────────────────────────────────────

  /// Cyber Lime — High Visibility Callouts
  static const Color cyberLime = Color(0xFFCAFD00);

  // ─── Blues ─────────────────────────────────────────────────────────────────

  /// Dusty Blue — Primary informational tint
  static const Color dustyBlue = Color(0xFF376890);

  /// Dusty Blue Light — Secondary tint / muted tone
  static const Color dustyBlueLight = Color(0xFF99C9F5);

  // ─── Neutrals / Backgrounds ────────────────────────────────────────────────

  /// Manila Stock — Main Background Layer
  static const Color manilaStock = Color(0xFFFDFFDA);

  /// Aged Paper — warm off-white background used on cards
  static const Color agedPaper = Color(0xFFEBE8DF);

  /// Olive Shadow — dark muted green accent
  static const Color oliveShadow = Color(0xFF556D00);

  /// Ink Black — Deep Contrast / Body Text
  static const Color inkBlack = Color(0xFF0E0E0B);

  // ─── Semantic Aliases ──────────────────────────────────────────────────────

  static const Color primaryAccent = mutedMagenta;
  static const Color highVisibility = cyberLime;
  static const Color bodyText = inkBlack;
  static const Color backgroundMain = manilaStock;
  static const Color backgroundCard = Color(0xFFFFFFFF);
  static const Color backgroundPaper = agedPaper;

  // ─── Full Palette List (for Color Lab / swatches UI) ──────────────────────

  static const List<_ColorEntry> palette = [
    _ColorEntry('Muted Magenta',  mutedMagenta,   '#9C4675', 'Primary Accent / Headlines'),
    _ColorEntry('Neon Petal',     neonPetal,       '#FF99CC', 'Soft Focus Containers'),
    _ColorEntry('Cyber Lime',     cyberLime,       '#CAFD00', 'High Visibility Callouts'),
    _ColorEntry('Dusty Blue',     dustyBlue,       '#376890', 'Informational / Links'),
    _ColorEntry('Dusty Blue Lt',  dustyBlueLight,  '#99C9F5', 'Secondary Tint'),
    _ColorEntry('Manila Stock',   manilaStock,     '#FDFFDA', 'Main Background Layer'),
    _ColorEntry('Aged Paper',     agedPaper,       '#EBE8DF', 'Card / Paper Background'),
    _ColorEntry('Olive Shadow',   oliveShadow,     '#556D00', 'Dark Accent / Foliage'),
    _ColorEntry('Ink Black',      inkBlack,        '#0E0E0B', 'Deep Contrast / Body Text'),
  ];
}

/// Immutable record that pairs a [Color] with its display metadata.
class _ColorEntry {
  const _ColorEntry(this.name, this.color, this.hex, this.usage);

  final String name;
  final Color color;
  final String hex;
  final String usage;
}