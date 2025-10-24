import 'dart:io';
import 'package:app/models/user_summary.dart';
import 'package:app/pages/home/user/shipment/summary.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/image_source_sheet.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class _ShipmentImageConfig {
  static const double contentPadding = 24.0;
  static const double verticalSpacing = 16.0;
  static const double titleFontSize = 24.0;
  static const double subtitleFontSize = 16.0;
  static const FontWeight titleFontWeight = FontWeight.bold;

  static const double imageHeight = 300.0;
  static const double borderRadius = 12.0;
  static const double uploadIconSize = 80.0;
  static const double removeIconSize = 20.0;
  static const double removeIconPadding = 6.0;
  static const double removeIconPosition = 12.0;

  static const double buttonHeight = 56.0;
  static const int imageQuality = 80;
}

/// Text constants for shipment image upload page
class _ShipmentImageTexts {
  static const String pageTitle = 'เพิ่มรูปภาพ';
  static const String sectionTitle = 'เพิ่มรูปภาพ';
  static const String sectionSubtitle =
      'ถ่ายหรือเลือกไฟล์รูปภาพเพื่อให้ไรเดอร์ทราบยานพาหนะของสินค้าที่ได้รับอย่างถูกต้อง';
  static const String uploadPlaceholder = 'แตะเพื่อเปิดกล้องถ่ายรูป';
  static const String orText = 'หรือ';
  static const String openCameraButton = 'เปิดกล้อง';
  static const String nextButton = 'ถัดไป';

  // Messages
  static const String imageRequiredMessage = 'กรุณาเลือกรูปภาพก่อน';
  static const String imagePickErrorPrefix = 'ไม่สามารถเลือกรูปภาพได้: ';

  // Accessibility
  static const String removeImageTooltip = 'ลบรูปภาพ';
  static const String imageSourceSheetTitle = 'เลือกรูปภาพสินค้า';
}

class UploadImagePage extends StatefulWidget {
  final UserInformation recipient;
  final Address deliveryAddress;

  const UploadImagePage({
    super.key,
    required this.recipient,
    required this.deliveryAddress,
  });

  @override
  State<UploadImagePage> createState() => _UploadImagePageState();
}

class _UploadImagePageState extends State<UploadImagePage> {
  XFile? _selectedImage;

  Future<void> _pickImage() async {
    final source = await ImageSourceSheet.show(
      context,
      title: _ShipmentImageTexts.imageSourceSheetTitle,
    );

    if (source == null) return;

    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: _ShipmentImageConfig.imageQuality,
      );

      if (picked != null) {
        setState(() => _selectedImage = picked);
      }
    } catch (e) {
      _showErrorSnackBar('${_ShipmentImageTexts.imagePickErrorPrefix}$e');
    }
  }

  void _removeImage() {
    setState(() => _selectedImage = null);
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _continueToNext() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_ShipmentImageTexts.imageRequiredMessage),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeliveryDetailsPage(
          recipient: widget.recipient,
          deliveryAddress: widget.deliveryAddress,
          packageImage: File(_selectedImage!.path),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _ShipmentImageTexts.sectionTitle,
          style: TextStyle(
            fontSize: _ShipmentImageConfig.titleFontSize,
            fontWeight: _ShipmentImageConfig.titleFontWeight,
            color: Colors.black,
          ),
        ),
        SizedBox(height: _ShipmentImageConfig.verticalSpacing / 2),
        Text(
          _ShipmentImageTexts.sectionSubtitle,
          style: TextStyle(fontSize: _ShipmentImageConfig.subtitleFontSize),
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        SizedBox(height: _ShipmentImageConfig.verticalSpacing * 2),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: _ShipmentImageConfig.imageHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(
                _ShipmentImageConfig.borderRadius,
              ),
            ),
            child: _selectedImage == null
                ? _buildUploadPlaceholder()
                : _buildImageDisplay(),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      padding: EdgeInsets.all(_ShipmentImageConfig.contentPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: _ShipmentImageConfig.uploadIconSize,
            height: _ShipmentImageConfig.uploadIconSize,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 40,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: _ShipmentImageConfig.verticalSpacing + 8),
          Text(
            _ShipmentImageTexts.uploadPlaceholder,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _ShipmentImageTexts.orText,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              _ShipmentImageTexts.openCameraButton,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageDisplay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(
            _ShipmentImageConfig.borderRadius - 2,
          ),
          child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
        ),
        Positioned(
          top: _ShipmentImageConfig.removeIconPosition,
          right: _ShipmentImageConfig.removeIconPosition,
          child: Tooltip(
            message: _ShipmentImageTexts.removeImageTooltip,
            child: InkWell(
              onTap: _removeImage,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(_ShipmentImageConfig.removeIconPadding),
                child: Icon(
                  Icons.close,
                  size: _ShipmentImageConfig.removeIconSize,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _ShipmentImageConfig.contentPadding,
        8,
        _ShipmentImageConfig.contentPadding,
        16 + bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: _ShipmentImageConfig.buttonHeight,
        child: PrimaryButton(
          text: _ShipmentImageTexts.nextButton,
          onPressed: _continueToNext,
          disabled: _selectedImage == null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(_ShipmentImageTexts.pageTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  _ShipmentImageConfig.contentPadding,
                  _ShipmentImageConfig.verticalSpacing,
                  _ShipmentImageConfig.contentPadding,
                  120,
                ),
                children: [_buildTitle(), _buildImageSection()],
              ),
            ),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
}
