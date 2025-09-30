import 'package:app/models/user_signup_draft.dart';
import 'package:app/pages/auth/signup/user/select_address.dart';
import 'package:app/widgets/address_picker.dart';
import 'package:app/widgets/home_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/text_field.dart';
import 'package:app/widgets/button.dart';
import 'package:dio/dio.dart';

class UserSignupAddAddressPage extends StatefulWidget {
  final UserSignupDraft draft;

  const UserSignupAddAddressPage({super.key, required this.draft});

  @override
  State<UserSignupAddAddressPage> createState() =>
      _UserSignupAddAddressPageState();
}

class _UserSignupAddAddressPageState extends State<UserSignupAddAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();

  String? _mainAddress;
  String? _pickupAddress;
  bool _isLoading = false;
  bool _isSelectingAddress = false;

  static const String _titleText = 'เพิ่มที่อยู่';
  static const String _aliasLabel = 'ชื่อเล่นของที่อยู่ (เช่น บ้าน)';
  static const String _mainAddressLabel = 'ที่อยู่';
  static const String _pickupAddressLabel = 'ที่อยู่ในการรับสินค้า';
  static const String _mainAddressPlaceholder = 'ที่อยู่';
  static const String _pickupAddressPlaceholder = 'ที่อยู่สำหรับรับสินค้า';
  static const String _createAccountButtonText = 'สร้างบัญชี';
  static const String _defaultMainLabel = 'บ้าน';
  static const String _defaultPickupLabel = 'รับสินค้า';
  static const String _apiEndpoint = 'http://10.0.2.2:5200/account/register';

  @override
  void dispose() {
    _aliasController.dispose();
    super.dispose();
  }

  String? _validateAlias(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    if (value.trim().length > 50) {
      return 'ชื่อเล่นต้องไม่เกิน 50 ตัวอักษร';
    }

    if (!RegExp(r'^[a-zA-Zก-๙0-9\s]+$').hasMatch(value.trim())) {
      return 'ชื่อเล่นต้องเป็นตัวอักษรและตัวเลขเท่านั้น';
    }

    return null;
  }

  bool _validateAddresses() {
    if (widget.draft.main == null) {
      _showErrorMessage('กรุณาเลือกที่อยู่หลัก');
      return false;
    }

    if (widget.draft.pickup == null) {
      _showErrorMessage('กรุณาเลือกที่อยู่สำหรับรับสินค้า');
      return false;
    }

    return true;
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

  Future<void> _pickMainAddress() async {
    if (_isSelectingAddress || !mounted) return;

    setState(() {
      _isSelectingAddress = true;
    });

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SelectLocationPage()),
      );

      if (result is SelectedLocation && mounted) {
        final aliasText = _aliasController.text.trim();

        setState(() {
          widget.draft.main = AddressInfo(
            label: aliasText.isEmpty ? _defaultMainLabel : aliasText,
            text: result.address ?? '${result.lat}, ${result.lng}',
            lat: result.lat,
            lng: result.lng,
          );
          _mainAddress = widget.draft.main!.text;
        });

        _showSuccessMessage('เลือกที่อยู่หลักเรียบร้อยแล้ว');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(
          'เกิดข้อผิดพลาดในการเลือกที่อยู่ กรุณาลองใหม่อีกครั้ง',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSelectingAddress = false;
        });
      }
    }
  }

  Future<void> _pickPickupAddress() async {
    if (_isSelectingAddress || !mounted) return;

    setState(() {
      _isSelectingAddress = true;
    });

    try {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SelectLocationPage()),
      );

      if (result is SelectedLocation && mounted) {
        setState(() {
          widget.draft.pickup = AddressInfo(
            label: _defaultPickupLabel,
            text: result.address ?? '${result.lat}, ${result.lng}',
            lat: result.lat,
            lng: result.lng,
          );
          _pickupAddress = widget.draft.pickup!.text;
        });

        _showSuccessMessage('เลือกที่อยู่รับสินค้าเรียบร้อยแล้ว');
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(
          'เกิดข้อผิดพลาดในการเลือกที่อยู่ กรุณาลองใหม่อีกครั้ง',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSelectingAddress = false;
        });
      }
    }
  }

  Future<void> _handleRegistration() async {
    if (_isLoading || !mounted) return;

    // Validate form first
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate addresses
    if (!_validateAddresses()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _performRegistration();
    } catch (e) {
      if (mounted) {
        _handleRegistrationError(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _performRegistration() async {
    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);

    final formData = FormData.fromMap({
      'PhoneNumber': widget.draft.phone,
      'Password': widget.draft.password,
      'Firstname': widget.draft.firstname,
      'Lastname': widget.draft.lastname ?? '',
      'Role': 'USER',
      'AvatarFileData': await MultipartFile.fromFile(
        widget.draft.avatar.path,
        filename: 'avatar.jpg',
      ),
      // Main address
      'AddressText': widget.draft.main!.text,
      'AddressLabel': widget.draft.main!.label,
      'AddressLatitude': widget.draft.main!.lat,
      'AddressLongitude': widget.draft.main!.lng,
      // Pickup address
      'PickupAddressText': widget.draft.pickup!.text,
      'PickupAddressLatitude': widget.draft.pickup!.lat,
      'PickupAddressLongitude': widget.draft.pickup!.lng,
    });

    final response = await dio.post(_apiEndpoint, data: formData);

    if (response.statusCode == 200) {
      await _handleSuccessfulRegistration(response);
    } else {
      throw 'การสมัครสมาชิกไม่สำเร็จ รหัสข้อผิดพลาด: ${response.statusCode}';
    }
  }

  Future<void> _handleSuccessfulRegistration(Response response) async {
    if (!mounted) return;

    _showSuccessMessage('สมัครสมาชิกสำเร็จ');

    try {
      final userId = response.data['data']['id'];

      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeWrapper(uid: userId)),
        (route) => false,
      );
    } catch (e) {
      throw 'เกิดข้อผิดพลาดในการประมวลผลข้อมูล';
    }
  }

  void _handleRegistrationError(dynamic error) {
    String errorMessage = 'เกิดข้อผิดพลาดในการสมัครสมาชิก';

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          errorMessage =
              'การเชื่อมต่อหมดเวลา กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';
          break;
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 400) {
            errorMessage = 'ข้อมูลที่กรอกไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
          } else if (statusCode == 409) {
            errorMessage = 'หมายเลขโทรศัพท์นี้ถูกใช้งานแล้ว';
          } else if (statusCode != null && statusCode >= 500) {
            errorMessage = 'เซิร์ฟเวอร์ขัดข้อง กรุณาลองใหม่ภายหลัง';
          } else {
            errorMessage = 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์: $statusCode';
          }
          break;
        case DioExceptionType.connectionError:
          errorMessage =
              'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่อ';
          break;
        default:
          errorMessage = 'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${error.message}';
      }
    } else if (error is String) {
      errorMessage = error;
    }

    _showErrorMessage(errorMessage);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _titleText,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),

                      _buildMainAddressSection(),

                      const SizedBox(height: 32),

                      _buildPickupAddressSection(),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(_mainAddressLabel),
        const SizedBox(height: 16),

        PrimaryTextField(
          labelText: _aliasLabel,
          controller: _aliasController,
          validator: _validateAlias,
          enabled: !_isLoading,
        ),

        const SizedBox(height: 16),

        AddressPickerTile(
          value: _mainAddress,
          placeholder: _mainAddressPlaceholder,
          onTap: () => _pickMainAddress(),
        ),
      ],
    );
  }

  Widget _buildPickupAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(_pickupAddressLabel),
        const SizedBox(height: 16),

        AddressPickerTile(
          value: _pickupAddress,
          placeholder: _pickupAddressPlaceholder,
          onTap: () => _pickPickupAddress(),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: PrimaryButton(
        text: _isLoading ? 'กำลังสร้างบัญชี...' : _createAccountButtonText,
        onPressed: () => _handleRegistration(),
        disabled: _isLoading || _isSelectingAddress,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
