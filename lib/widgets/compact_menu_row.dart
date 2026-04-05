import 'package:flutter/material.dart';

/// Riga menu contestuale compatta: icone allineate in uno slot fisso (le glyph Material hanno larghezze diverse).
class CompactMenuRow extends StatelessWidget {
  const CompactMenuRow({
    super.key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.textStyle,
    this.trailing,
  });

  static const double iconSlotWidth = 24;
  static const double trailingSlotWidth = 22;
  static const double iconSize = 16;
  static const double gapAfterIcon = 8;
  static const double fontSize = 12;
  static const double rowHeight = 32;

  final IconData icon;
  final String label;
  final Color? iconColor;
  final TextStyle? textStyle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = TextStyle(
      fontSize: fontSize,
      color: textStyle?.color ?? theme.colorScheme.onSurface,
    );
    final merged = baseStyle.merge(textStyle);

    return SizedBox(
      width: double.infinity,
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: iconSlotWidth,
            child: Center(
              child: Icon(
                icon,
                size: iconSize,
                color: iconColor,
              ),
            ),
          ),
          const SizedBox(width: gapAfterIcon),
          Expanded(
            child: Text(
              label,
              style: merged,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          SizedBox(
            width: trailingSlotWidth,
            child: trailing != null
                ? Align(
                    alignment: Alignment.centerRight,
                    child: trailing!,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
