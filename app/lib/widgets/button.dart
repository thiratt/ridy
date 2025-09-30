import 'package:app/themes/app_theme.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool disabled;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: disabled
              ? AppTheme.light.colorScheme.onSurface.withValues(alpha: 0.12)
              : AppTheme.light.colorScheme.primary,
          foregroundColor: AppTheme.light.colorScheme.onPrimary,
          side: BorderSide(color: AppTheme.light.colorScheme.onPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool fullWidth;

  const GhostButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final btn = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.light.colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 16)),
    );

    if (fullWidth) {
      return SizedBox(height: 56, width: double.infinity, child: btn);
    }

    return btn; // ความกว้างเท่าข้อความ
  }
}

class OutlinedAppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const OutlinedAppButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.light.colorScheme.onSurface,
          side: BorderSide(
            color: AppTheme.light.colorScheme.onSurface,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
