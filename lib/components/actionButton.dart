import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final Color? textColor;
  final bool isDark;
  final bool vertical;
  final bool roundedIcon;
  final bool showChevron;
  final VoidCallback onPressed;

  const ActionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onPressed,
    this.subtitle,
    this.textColor,
    this.isDark = false,
    this.vertical = false,
    this.roundedIcon = false,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final tc =
        textColor ??
        Theme.of(context).textTheme.bodyMedium?.color ??
        Colors.black;

    return Material(
      borderRadius: BorderRadius.circular(16),
      color: color.withOpacity(isDark ? 0.2 : 0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: vertical
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: roundedIcon
                            ? BoxShape.circle
                            : BoxShape.rectangle,
                        borderRadius: roundedIcon
                            ? null
                            : BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: tc,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: tc,
                                ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: tc.withOpacity(0.6)),
                            ),
                        ],
                      ),
                    ),
                    if (showChevron)
                      Icon(Icons.chevron_right, color: tc.withOpacity(0.3)),
                  ],
                ),
        ),
      ),
    );
  }
}
