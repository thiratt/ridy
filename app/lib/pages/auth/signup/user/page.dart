import 'dart:io';
import 'package:app/models/user_signup_draft.dart';
import 'package:app/pages/auth/login/page.dart';
import 'package:app/pages/auth/signup/user/add_address.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:app/widgets/text_field.dart';
import 'package:app/widgets/button.dart';

class UserSignupPage extends StatefulWidget {
  const UserSignupPage({super.key});

  @override
  State<UserSignupPage> createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  XFile? _avatar;
  bool _isPickingImage = false;

  static const String _titleText = 'สร้างบัญชีผู้ใช้ทั่วไป';
  static const String _uploadImageText = 'อัปโหลดรูปภาพ';
  static const String _firstNameLabel = 'ชื่อ';
  static const String _lastNameLabel = 'นามสกุล (ไม่บังคับ)';
  static const String _phoneLabel = 'หมายเลขโทรศัพท์';
  static const String _passwordLabel = 'รหัสผ่าน';
  static const String _continueButtonText = 'ดำเนินการต่อ';
  static const String _loginPromptText = 'มีบัญชีอยู่แล้ว? ';
  static const String _loginLinkText = 'เข้าสู่ระบบเลย';
  static const String _cameraOptionText = 'ถ่ายรูป';
  static const String _galleryOptionText = 'เลือกจากคลังภาพ';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกชื่อ';
    }

    if (value.trim().length < 2) {
      return 'ชื่อต้องมีอย่างน้อย 2 ตัวอักษร';
    }

    if (value.trim().length > 50) {
      return 'ชื่อต้องไม่เกิน 50 ตัวอักษร';
    }

    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (value.trim().length > 50) {
      return 'นามสกุลต้องไม่เกิน 50 ตัวอักษร';
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกหมายเลขโทรศัพท์';
    }

    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanPhone.length != 10) {
      return 'หมายเลขโทรศัพท์ต้องมี 10 หลัก';
    }

    if (!cleanPhone.startsWith('0')) {
      return 'หมายเลขโทรศัพท์ต้องเริ่มต้นด้วย 0';
    }

    final prefix = cleanPhone.substring(0, 2);
    if (!['08', '09', '06'].contains(prefix)) {
      return 'รูปแบบหมายเลขโทรศัพท์ไม่ถูกต้อง';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }

    if (value.length < 6) {
      return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    }

    if (value.length > 128) {
      return 'รหัสผ่านต้องไม่เกิน 128 ตัวอักษร';
    }

    return null;
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final source = await _showImageSourceBottomSheet();
      if (source == null) return;

      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (picked != null && mounted) {
        setState(() {
          _avatar = picked;
        });

        _showSuccessMessage('อัปโหลดรูปภาพเรียบร้อยแล้ว');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(
          'เกิดข้อผิดพลาดในการเลือกรูปภาพ กรุณาลองใหม่อีกครั้ง',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<ImageSource?> _showImageSourceBottomSheet() async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'เลือกรูปภาพ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.photo_camera_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(_cameraOptionText),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(
                Icons.photo_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(_galleryOptionText),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNext() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showErrorMessage('กรุณาตรวจสอบข้อมูลที่กรอกให้ถูกต้อง');
      return;
    }

    if (_avatar == null) {
      _showErrorMessage('กรุณาเลือกรูปภาพโปรไฟล์');
      return;
    }

    try {
      final draft = UserSignupDraft(
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim().isEmpty
            ? null
            : _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        avatar: _avatar!,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserSignupAddAddressPage(draft: draft),
        ),
      );
    } catch (e) {
      if (mounted) {
        _showErrorMessage('เกิดข้อผิดพลาดในการดำเนินการ กรุณาลองใหม่อีกครั้ง');
      }
    }
  }

  Future<void> _navigateToLogin() async {
    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      if (mounted) {
        _showErrorMessage('เกิดข้อผิดพลาดในการเปิดหน้าเข้าสู่ระบบ');
      }
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'ปิด',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                      const SizedBox(height: 8),
                      _buildTitle(),

                      const SizedBox(height: 32),

                      _buildAvatarSection(),

                      const SizedBox(height: 32),

                      _buildFormFields(),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  PrimaryButton(
                    text: _continueButtonText,
                    onPressed: () => _handleNext(),
                  ),
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

  Widget _buildTitle() {
    return Text(
      _titleText,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 56,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest,
          backgroundImage: _avatar != null
              ? FileImage(File(_avatar!.path))
              : null,
          child: _avatar == null
              ? Icon(
                  Icons.person,
                  size: 56,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )
              : null,
        ),
        const SizedBox(height: 12),
        GhostButton(
          text: _isPickingImage ? 'กำลังเลือกรูป...' : _uploadImageText,
          onPressed: () => _pickImage(),
          fullWidth: false,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        PrimaryTextField(
          labelText: _firstNameLabel,
          controller: _firstNameController,
          validator: _validateFirstName,
        ),
        const SizedBox(height: 16),
        PrimaryTextField(
          labelText: _lastNameLabel,
          controller: _lastNameController,
          validator: _validateLastName,
        ),
        const SizedBox(height: 16),
        PrimaryTextField(
          labelText: _phoneLabel,
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
        ),
        const SizedBox(height: 16),
        PrimaryTextField(
          labelText: _passwordLabel,
          controller: _passwordController,
          isPassword: true,
          validator: _validatePassword,
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Text.rich(
      TextSpan(
        text: _loginPromptText,
        children: [
          TextSpan(
            text: _loginLinkText,
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
      style: const TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}
