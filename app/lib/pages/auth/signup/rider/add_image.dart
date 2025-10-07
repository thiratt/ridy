import 'dart:io';
import 'package:app/models/rider_signup_draft.dart';
import 'package:app/pages/home/rider/page.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/image_source_sheet.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class _VehicleImageConfig {
  static const double contentPadding = 16.0;
  static const double verticalSpacing = 12.0;
  static const double titleFontSize = 15.0;
  static const FontWeight titleFontWeight = FontWeight.w700;

  static const double imageHeight = 220.0;
  static const double borderRadius = 12.0;
  static const double uploadIconSize = 48.0;
  static const double removeIconSize = 20.0;
  static const double removeIconPadding = 4.0;
  static const double removeIconPosition = 8.0;

  static const double buttonHeight = 56.0;
  static const int imageQuality = 85;

  static const String apiBaseUrl = 'http://10.0.2.2:5200';
}

/// Text constants for rider vehicle image page
class _VehicleImageTexts {
  static const String pageTitle = 'ยานพาหนะ';
  static const String sectionTitle = 'รูปภาพยานพาหนะ';
  static const String uploadPlaceholder = 'แตะเพื่ออัปโหลดรูปภาพ';
  static const String openCameraButton = 'เปิดกล้อง';
  static const String createAccountButton = 'สร้างบัญชี';
  static const String processingButton = 'กำลังสมัคร...';

  // Messages
  static const String imageRequiredMessage = 'กรุณาอัปโหลดรูปภาพยานพาหนะ';
  static const String successMessage = 'สมัครสมาชิกสำเร็จ';
  static const String errorMessagePrefix = 'สมัครไม่สำเร็จ: ';

  // Accessibility
  static const String removeImageTooltip = 'ลบรูปภาพ';
}

class RiderAddVehicleImage extends StatefulWidget {
  final RiderSignupDraft draft;
  const RiderAddVehicleImage({super.key, required this.draft});

  @override
  State<RiderAddVehicleImage> createState() => _RiderAddVehicleImageState();
}

class _RiderAddVehicleImageState extends State<RiderAddVehicleImage> {
  XFile? _vehicleImage;
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final source = await ImageSourceSheet.show(
      context,
      title: 'เลือกรูปภาพยานพาหนะ',
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: _VehicleImageConfig.imageQuality,
    );

    if (picked != null) setState(() => _vehicleImage = picked);
  }

  void _removeImage() {
    setState(() => _vehicleImage = null);
  }

  Future<void> _submit() async {
    if (_vehicleImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(_VehicleImageTexts.imageRequiredMessage)),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dio = Dio();

      final formData = FormData.fromMap({
        'PhoneNumber': widget.draft.phone,
        'Password': widget.draft.password,
        'Firstname': widget.draft.firstname,
        'Lastname': widget.draft.lastname ?? '',
        'Role': 'RIDER',
        'AvatarFileData': await MultipartFile.fromFile(
          widget.draft.avatar.path,
          filename: 'avatar.jpg',
        ),
        'VehiclePhotoData': await MultipartFile.fromFile(
          _vehicleImage!.path,
          filename: 'vehicle.jpg',
        ),
        'VehiclePlate': widget.draft.vehiclePlateNumber,
      });

      final res = await dio.post(
        '${_VehicleImageConfig.apiBaseUrl}/account/register',
        data: formData,
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(_VehicleImageTexts.successMessage)),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => RiderHomePage(uid: res.data['data']['id']),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_VehicleImageTexts.errorMessagePrefix}$e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildTitle() {
    return Text(
      _VehicleImageTexts.sectionTitle,
      style: TextStyle(
        fontWeight: _VehicleImageConfig.titleFontWeight,
        fontSize: _VehicleImageConfig.titleFontSize,
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        SizedBox(height: _VehicleImageConfig.verticalSpacing),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: _VehicleImageConfig.imageHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(
                _VehicleImageConfig.borderRadius,
              ),
              color: Colors.grey.shade100,
            ),
            child: _vehicleImage == null
                ? _buildUploadPlaceholder()
                : _buildImageDisplay(),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.cloud_upload_outlined,
          size: _VehicleImageConfig.uploadIconSize,
          color: Colors.black54,
        ),
        const SizedBox(height: 8),
        Text(_VehicleImageTexts.uploadPlaceholder),
        SizedBox(height: _VehicleImageConfig.verticalSpacing),
        ElevatedButton(
          onPressed: _pickImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          child: Text(_VehicleImageTexts.openCameraButton),
        ),
      ],
    );
  }

  Widget _buildImageDisplay() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(_VehicleImageConfig.borderRadius),
          child: Image.file(File(_vehicleImage!.path), fit: BoxFit.cover),
        ),
        Positioned(
          top: _VehicleImageConfig.removeIconPosition,
          right: _VehicleImageConfig.removeIconPosition,
          child: Tooltip(
            message: _VehicleImageTexts.removeImageTooltip,
            child: InkWell(
              onTap: _removeImage,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(_VehicleImageConfig.removeIconPadding),
                child: Icon(
                  Icons.close,
                  size: _VehicleImageConfig.removeIconSize,
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
        _VehicleImageConfig.contentPadding,
        8,
        _VehicleImageConfig.contentPadding,
        16 + bottom,
      ),
      child: SizedBox(
        width: double.infinity,
        height: _VehicleImageConfig.buttonHeight,
        child: PrimaryButton(
          text: _isSubmitting
              ? _VehicleImageTexts.processingButton
              : _VehicleImageTexts.createAccountButton,
          onPressed: () => _submit(),
          disabled: _isSubmitting || _vehicleImage == null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_VehicleImageTexts.pageTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  _VehicleImageConfig.contentPadding,
                  _VehicleImageConfig.verticalSpacing,
                  _VehicleImageConfig.contentPadding,
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
