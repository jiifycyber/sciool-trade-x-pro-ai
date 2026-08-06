import 'package:flutter/material.dart';
import '../theme.dart';

class EgyptPanel extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  final EdgeInsets padding;

  const EgyptPanel({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TitanEgyptColors.panel,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TitanEgyptColors.bronze),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: TitanEgyptColors.bronze),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 17,
                  color: TitanEgyptColors.gold,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: TitanEgyptColors.gold,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class EgyptMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;

  const EgyptMetric({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 150),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TitanEgyptColors.panel,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TitanEgyptColors.bronze),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: TitanEgyptColors.gold),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: TitanEgyptColors.muted,
                    letterSpacing: .8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: valueColor ?? Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SignalPill extends StatelessWidget {
  final String text;
  final Color color;

  const SignalPill({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class EgyptianBanner extends StatelessWidget {
  const EgyptianBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF15110A),
            Color(0xFF0A0A0A),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TitanEgyptColors.gold),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 22,
            child: Icon(
              Icons.account_balance,
              size: 64,
              color: TitanEgyptColors.gold.withOpacity(.55),
            ),
          ),
          Positioned(
            right: 22,
            child: Icon(
              Icons.remove_red_eye,
              size: 72,
              color: TitanEgyptColors.cyan.withOpacity(.75),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'SCIOOL FX',
                style: TextStyle(
                  color: TitanEgyptColors.brightGold,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                ),
              ),
              Text(
                'TradeX AI',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 38,
                      letterSpacing: 3,
                    ),
              ),
              const Text(
                'ANCIENT EGYPT GRAND INTELLIGENCE EDITION',
                style: TextStyle(
                  color: TitanEgyptColors.gold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
