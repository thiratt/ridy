import 'package:flutter/material.dart';

class PrimaryTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final double borderRadius;
  final IconData? prefixIconData;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool showPasswordToggle;
  final String? Function(String?)? validator;
  final bool enabled;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;

  const PrimaryTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.borderRadius = 12.0,
    this.prefixIconData,
    this.prefixIcon,
    this.suffixIcon,
    this.showPasswordToggle = true,
    this.validator,
    this.enabled = true,
    this.hintText,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
  }) : assert(
         !isPassword || showPasswordToggle || suffixIcon == null,
         'Cannot show both suffixIcon and password toggle for password fields',
       );

  @override
  State<PrimaryTextField> createState() => _PrimaryTextFieldState();
}

class _PrimaryTextFieldState extends State<PrimaryTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  Widget? _buildPrefixIcon(ColorScheme colorScheme) {
    if (widget.prefixIcon != null) {
      return widget.prefixIcon;
    }

    if (widget.prefixIconData != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 4, 0),
        child: Icon(
          widget.prefixIconData,
          size: 20,
          color: colorScheme.onSurface,
        ),
      );
    }

    return null;
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword && widget.showPasswordToggle) {
      return IconButton(
        onPressed: _togglePasswordVisibility,
        icon: Icon(
          _isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
          size: 20,
          semanticLabel: _isObscured ? 'Show password' : 'Hide password',
        ),
        tooltip: _isObscured ? 'Show password' : 'Hide password',
      );
    }

    return widget.suffixIcon;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ? _isObscured : false,
      enabled: widget.enabled,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onSubmitted,
      textAlignVertical: TextAlignVertical.center,

      enableSuggestions: !widget.isPassword,
      autocorrect: !widget.isPassword,

      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 14,
        ),

        prefixIcon: _buildPrefixIcon(colorScheme),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),

        suffixIcon: _buildSuffixIcon(),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.outline, width: 1.0),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 1.0),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2.0),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.38),
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
