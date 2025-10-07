import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class _ImageSourceConfig {
  static const double borderRadius = 20.0;
  static const double handleWidth = 40.0;
  static const double handleHeight = 4.0;
  static const double handleMarginTop = 8.0;
  static const double titleFontSize = 18.0;
  static const FontWeight titleFontWeight = FontWeight.w600;
  static const double verticalSpacing = 16.0;
  static const double contentPadding = 16.0;
}

class _ImageSourceTexts {
  static const String defaultTitle = 'เลือกรูปภาพ';
  static const String cameraOption = 'ถ่ายรูปใหม่';
  static const String galleryOption = 'เลือกจากคลังภาพ';
  static const String cancelOption = 'ยกเลิก';
}

class ImageSourceSheet extends StatelessWidget {
  final String? title;
  final String? cameraText;
  final String? galleryText;
  final bool showCancel;
  final String? cancelText;

  const ImageSourceSheet({
    super.key,
    this.title,
    this.cameraText,
    this.galleryText,
    this.showCancel = false,
    this.cancelText,
  });

  static Future<ImageSource?> show(
    BuildContext context, {
    String? title,
    String? cameraText,
    String? galleryText,
    bool showCancel = false,
    String? cancelText,
  }) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => ImageSourceSheet(
        title: title,
        cameraText: cameraText,
        galleryText: galleryText,
        showCancel: showCancel,
        cancelText: cancelText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(_ImageSourceConfig.borderRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(
                top: _ImageSourceConfig.handleMarginTop,
              ),
              width: _ImageSourceConfig.handleWidth,
              height: _ImageSourceConfig.handleHeight,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                borderRadius: BorderRadius.circular(
                  _ImageSourceConfig.handleHeight / 2,
                ),
              ),
            ),

            const SizedBox(height: _ImageSourceConfig.verticalSpacing),

            // Title
            Text(
              title ?? _ImageSourceTexts.defaultTitle,
              style: TextStyle(
                fontSize: _ImageSourceConfig.titleFontSize,
                fontWeight: _ImageSourceConfig.titleFontWeight,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: _ImageSourceConfig.verticalSpacing),

            // Camera option
            _ImageSourceOption(
              icon: Icons.photo_camera_outlined,
              title: cameraText ?? _ImageSourceTexts.cameraOption,
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),

            // Gallery option
            _ImageSourceOption(
              icon: Icons.photo_outlined,
              title: galleryText ?? _ImageSourceTexts.galleryOption,
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),

            // Cancel option (optional)
            if (showCancel) ...[
              const Divider(height: 1),
              _ImageSourceOption(
                icon: Icons.close,
                title: cancelText ?? _ImageSourceTexts.cancelOption,
                onTap: () => Navigator.pop(context),
                isDestructive: true,
              ),
            ],

            const SizedBox(height: _ImageSourceConfig.verticalSpacing),
          ],
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ImageSourceOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
    final textColor = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: _ImageSourceConfig.contentPadding,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
