import 'dart:io';
import 'package:app/models/rider_signup_draft.dart';
import 'package:app/pages/auth/login/page.dart';
import 'package:app/pages/auth/signup/rider/add_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app/widgets/text_field.dart';
import 'package:app/widgets/button.dart';
import 'package:app/widgets/image_source_sheet.dart';

class _RiderSignupConfig {
  static const double contentPadding = 16.0;
  static const double verticalSpacing = 12.0;
  static const double sectionSpacing = 20.0;
  static const double titleFontSize = 22.0;
  static const FontWeight titleFontWeight = FontWeight.w700;

  static const int imageQuality = 85;
  static const double maxImageWidth = 1024.0;

  // Avatar configuration
  static const double avatarRadius = 50;
  static const double avatarIconSize = 30;

  static final RegExp phonePattern = RegExp(r'^[0-9]{10}$');
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  static const int maxNameLength = 50;
}

class _RiderSignupErrorMessages {
  static const String firstNameRequired = 'กรุณากรอกชื่อ';
  static const String firstNameTooLong = 'ชื่อต้องไม่เกิน 50 ตัวอักษร';
  static const String lastNameTooLong = 'นามสกุลต้องไม่เกิน 50 ตัวอักษร';
  static const String phoneRequired = 'กรุณากรอกหมายเลขโทรศัพท์';
  static const String phoneInvalid =
      'หมายเลขโทรศัพท์ไม่ถูกต้อง (ต้องเป็นตัวเลข 10 หลัก)';
  static const String passwordRequired = 'กรุณากรอกรหัสผ่าน';
  static const String passwordTooShort = 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
  static const String passwordTooLong = 'รหัสผ่านต้องไม่เกิน 50 ตัวอักษร';
  static const String plateNumberRequired = 'กรุณากรอกหมายเลขทะเบียนรถ';
  static const String avatarRequired = 'กรุณาเลือกรูปโปรไฟล์';

  static const String imagePickerError = 'เกิดข้อผิดพลาดในการเลือกรูปภาพ';
  static const String navigationError = 'เกิดข้อผิดพลาดในการนำทาง';
}

class _RiderSignupTexts {
  static const String pageTitle = 'สร้างบัญชีไรเดอร์';
  static const String uploadImageButton = 'อัปโหลดรูปภาพ';
  static const String continueButton = 'ดำเนินการต่อ';
  static const String processingButton = 'กำลังดำเนินการ...';
  static const String haveAccountText = 'มีบัญชีอยู่แล้ว? ';
  static const String loginLinkText = 'เข้าสู่ระบบเลย';

  // Form field labels
  static const String firstNameLabel = 'ชื่อ';
  static const String lastNameLabel = 'นามสกุล (ไม่บังคับ)';
  static const String phoneLabel = 'หมายเลขโทรศัพท์';
  static const String passwordLabel = 'รหัสผ่าน';
  static const String plateNumberLabel = 'หมายเลขทะเบียนรถ';

  // Accessibility labels
  static const String avatarSemantic = 'รูปโปรไฟล์ไรเดอร์';
  static const String uploadButtonSemantic = 'เลือกรูปโปรไฟล์';
}

class RiderSignupPage extends StatefulWidget {
  const RiderSignupPage({super.key});

  @override
  State<RiderSignupPage> createState() => RiderSignupPageState();
}

class RiderSignupPageState extends State<RiderSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _vehiclePlateNumberController = TextEditingController();

  XFile? _selectedAvatar;
  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _vehiclePlateNumberController.dispose();
    super.dispose();
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _RiderSignupErrorMessages.firstNameRequired;
    }
    if (value.trim().length > _RiderSignupConfig.maxNameLength) {
      return _RiderSignupErrorMessages.firstNameTooLong;
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value != null &&
        value.trim().length > _RiderSignupConfig.maxNameLength) {
      return _RiderSignupErrorMessages.lastNameTooLong;
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _RiderSignupErrorMessages.phoneRequired;
    }
    if (!_RiderSignupConfig.phonePattern.hasMatch(value.trim())) {
      return _RiderSignupErrorMessages.phoneInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return _RiderSignupErrorMessages.passwordRequired;
    }
    if (value.length < _RiderSignupConfig.minPasswordLength) {
      return _RiderSignupErrorMessages.passwordTooShort;
    }
    if (value.length > _RiderSignupConfig.maxPasswordLength) {
      return _RiderSignupErrorMessages.passwordTooLong;
    }
    return null;
  }

  String? _validatePlateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _RiderSignupErrorMessages.plateNumberRequired;
    }
    return null;
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'ตกลง',
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  Future<void> _selectProfileImage() async {
    try {
      final source = await ImageSourceSheet.show(context);

      if (source == null) return;

      final pickedImage = await ImagePicker().pickImage(
        source: source,
        imageQuality: _RiderSignupConfig.imageQuality,
        maxWidth: _RiderSignupConfig.maxImageWidth,
      );

      if (pickedImage != null && mounted) {
        setState(() {
          _selectedAvatar = pickedImage;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError(_RiderSignupErrorMessages.imagePickerError);
      }
    }
  }

  Future<void> _processFormSubmission() async {
    if (_isProcessing) return;

    FocusScope.of(context).unfocus();

    if (_selectedAvatar == null) {
      _showError(_RiderSignupErrorMessages.avatarRequired);
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final draft = RiderSignupDraft(
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        avatar: _selectedAvatar!,
        vehiclePlateNumber: _vehiclePlateNumberController.text.trim(),
      );

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RiderAddVehicleImage(draft: draft),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(_RiderSignupErrorMessages.navigationError);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Build the page title widget
  Widget _buildTitle() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Text(
          _RiderSignupTexts.pageTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _RiderSignupConfig.titleFontSize,
            fontWeight: _RiderSignupConfig.titleFontWeight,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: _RiderSignupConfig.sectionSpacing),
      ],
    );
  }

  /// Build the avatar selection section
  Widget _buildAvatarSection() {
    return Column(
      children: [
        Semantics(
          label: _RiderSignupTexts.avatarSemantic,
          child: CircleAvatar(
            radius: _RiderSignupConfig.avatarRadius,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest,
            backgroundImage: _selectedAvatar != null
                ? FileImage(File(_selectedAvatar!.path))
                : null,
            child: _selectedAvatar == null
                ? Icon(
                    Icons.person,
                    size: _RiderSignupConfig.avatarIconSize,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: _RiderSignupTexts.uploadButtonSemantic,
          child: GhostButton(
            text: _RiderSignupTexts.uploadImageButton,
            onPressed: _selectProfileImage,
            fullWidth: false,
          ),
        ),
        SizedBox(height: _RiderSignupConfig.sectionSpacing),
      ],
    );
  }

  /// Build all form input fields
  Widget _buildFormFields() {
    return Column(
      children: [
        PrimaryTextField(
          labelText: _RiderSignupTexts.firstNameLabel,
          controller: _firstNameController,
          validator: _validateFirstName,
          keyboardType: TextInputType.name,
        ),
        SizedBox(height: _RiderSignupConfig.verticalSpacing),
        PrimaryTextField(
          labelText: _RiderSignupTexts.lastNameLabel,
          controller: _lastNameController,
          validator: _validateLastName,
          keyboardType: TextInputType.name,
        ),
        SizedBox(height: _RiderSignupConfig.verticalSpacing),
        PrimaryTextField(
          labelText: _RiderSignupTexts.phoneLabel,
          controller: _phoneController,
          validator: _validatePhone,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: _RiderSignupConfig.verticalSpacing),
        PrimaryTextField(
          labelText: _RiderSignupTexts.passwordLabel,
          controller: _passwordController,
          validator: _validatePassword,
          isPassword: true,
        ),
        SizedBox(height: _RiderSignupConfig.verticalSpacing),
        PrimaryTextField(
          labelText: _RiderSignupTexts.plateNumberLabel,
          controller: _vehiclePlateNumberController,
          validator: _validatePlateNumber,
          keyboardType: TextInputType.text,
        ),
      ],
    );
  }

  /// Build error message display
  Widget _buildErrorMessage() {
    if (_errorMessage == null) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _RiderSignupConfig.contentPadding,
        0,
        _RiderSignupConfig.contentPadding,
        8,
      ),
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
                onPressed: () => setState(() => _errorMessage = null),
                tooltip: 'ปิด',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the continue button
  Widget _buildContinueButton() {
    return PrimaryButton(
      text: _isProcessing
          ? _RiderSignupTexts.processingButton
          : _RiderSignupTexts.continueButton,
      onPressed: () => _processFormSubmission(),
      disabled: _isProcessing,
    );
  }

  /// Build the login link text
  Widget _buildLoginLink() {
    return Semantics(
      label: 'ลิงก์สำหรับผู้ที่มีบัญชีแล้ว',
      child: Text.rich(
        TextSpan(
          text: _RiderSignupTexts.haveAccountText,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          children: [
            TextSpan(
              text: _RiderSignupTexts.loginLinkText,
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _navigateToLogin(),
            ),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Navigate to login page safely
  Future<void> _navigateToLogin() async {
    if (_isProcessing) return;

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      if (mounted) {
        _showError(_RiderSignupErrorMessages.navigationError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      _buildTitle(),
                      _buildAvatarSection(),
                      _buildFormFields(),
                    ],
                  ),
                ),
              ),
            ),

            _buildErrorMessage(),

            Padding(
              padding: EdgeInsets.fromLTRB(
                _RiderSignupConfig.contentPadding,
                0,
                _RiderSignupConfig.contentPadding,
                8,
              ),
              child: Column(
                children: [
                  _buildContinueButton(),
                  const SizedBox(height: 16),
                  _buildLoginLink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
