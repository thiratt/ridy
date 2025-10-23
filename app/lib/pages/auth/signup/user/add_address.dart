import 'package:app/models/user_signup_draft.dart';
import 'package:app/pages/auth/signup/user/select_address.dart';
import 'package:app/utils/navigation.dart';
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

  final List<AddressInfo> _mainAddresses = [];
  final List<AddressInfo> _pickupAddresses = [];

  bool _isLoading = false;
  bool _isSelectingAddress = false;

  static const String _titleText = 'เพิ่มที่อยู่';
  static const String _aliasLabel = 'ชื่อเล่นของที่อยู่ (เช่น บ้าน)';
  static const String _mainAddressLabel = 'ที่อยู่หลัก';
  static const String _pickupAddressLabel = 'ที่อยู่ในการรับสินค้า';
  static const String _mainAddressPlaceholder = 'ที่อยู่หลัก';
  static const String _pickupAddressPlaceholder = 'ที่อยู่สำหรับรับสินค้า';
  static const String _createAccountButtonText = 'สร้างบัญชี';
  static const String _defaultMainLabel = 'บ้าน';
  static const String _defaultPickupLabel = 'รับสินค้า';
  static const String _apiEndpoint = 'http://10.0.2.2:5200/account/register';

  @override
  void initState() {
    super.initState();
    _initializeAddresses();
  }

  void _initializeAddresses() {
    if (widget.draft.main != null) {
      _mainAddresses.add(widget.draft.main!);
    }
    if (widget.draft.pickup != null) {
      _pickupAddresses.add(widget.draft.pickup!);
    }
  }

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
    if (_mainAddresses.isEmpty) {
      _showErrorMessage('กรุณาเลือกที่อยู่หลักอย่างน้อย 1 ที่อยู่');
      return false;
    }

    if (_pickupAddresses.isEmpty) {
      _showErrorMessage('กรุณาเลือกที่อยู่สำหรับรับสินค้าอย่างน้อย 1 ที่อยู่');
      return false;
    }

    widget.draft.main = _mainAddresses.first;
    widget.draft.pickup = _pickupAddresses.first;
    widget.draft.mainAddresses = _mainAddresses;
    widget.draft.pickupAddresses = _pickupAddresses;

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
      final result = await navigateTo(
        context,
        const SelectLocationPage(),
        '/auth/signup/user/address/select',
      );

      if (result is SelectedLocation && mounted) {
        final aliasText = _aliasController.text.trim();

        final newAddress = AddressInfo(
          label: aliasText.isEmpty
              ? '$_defaultMainLabel ${_mainAddresses.length + 1}'
              : aliasText,
          text: result.address ?? '${result.lat}, ${result.lng}',
          lat: result.lat,
          lng: result.lng,
        );

        setState(() {
          _mainAddresses.add(newAddress);
          if (widget.draft.main == null) {
            widget.draft.main = newAddress;
          }
        });

        _aliasController.clear();
        _showSuccessMessage('เพิ่มที่อยู่หลักเรียบร้อยแล้ว');
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
      final result = await navigateTo(
        context,
        const SelectLocationPage(),
        '/auth/signup/user/address/select',
      );

      if (result is SelectedLocation && mounted) {
        final newAddress = AddressInfo(
          label: '$_defaultPickupLabel ${_pickupAddresses.length + 1}',
          text: result.address ?? '${result.lat}, ${result.lng}',
          lat: result.lat,
          lng: result.lng,
        );

        setState(() {
          _pickupAddresses.add(newAddress);
          if (widget.draft.pickup == null) {
            widget.draft.pickup = newAddress;
          }
        });

        _showSuccessMessage('เพิ่มที่อยู่รับสินค้าเรียบร้อยแล้ว');
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

  void _removeMainAddress(int index) {
    _showRemoveConfirmation(
      'ลบที่อยู่หลัก',
      'คุณต้องการลบที่อยู่ "${_mainAddresses[index].label}" หรือไม่?',
      () {
        setState(() {
          _mainAddresses.removeAt(index);
          widget.draft.main = _mainAddresses.isNotEmpty
              ? _mainAddresses.first
              : null;
        });
        _showSuccessMessage('ลบที่อยู่หลักเรียบร้อยแล้ว');
      },
    );
  }

  void _removePickupAddress(int index) {
    _showRemoveConfirmation(
      'ลบที่อยู่รับสินค้า',
      'คุณต้องการลบที่อยู่ "${_pickupAddresses[index].label}" หรือไม่?',
      () {
        setState(() {
          _pickupAddresses.removeAt(index);
          widget.draft.pickup = _pickupAddresses.isNotEmpty
              ? _pickupAddresses.first
              : null;
        });
        _showSuccessMessage('ลบที่อยู่รับสินค้าเรียบร้อยแล้ว');
      },
    );
  }

  void _showRemoveConfirmation(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onConfirm();
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('ลบ'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRegistration() async {
    if (_isLoading || !mounted) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

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

    final Map<String, dynamic> formDataMap = {
      'PhoneNumber': widget.draft.phone,
      'Password': widget.draft.password,
      'Firstname': widget.draft.firstname,
      'Lastname': widget.draft.lastname ?? '',
      'Role': 'USER',
      'AvatarFileData': await MultipartFile.fromFile(
        widget.draft.avatar.path,
        filename: 'avatar.jpg',
      ),
    };

    if (_mainAddresses.isNotEmpty) {
      formDataMap['MainAddressTexts'] = _mainAddresses
          .map((addr) => addr.text)
          .toList();
      formDataMap['MainAddressLabels'] = _mainAddresses
          .map((addr) => addr.label)
          .toList();
      formDataMap['MainAddressLatitudes'] = _mainAddresses
          .map((addr) => addr.lat)
          .toList();
      formDataMap['MainAddressLongitudes'] = _mainAddresses
          .map((addr) => addr.lng)
          .toList();
    }

    if (_pickupAddresses.isNotEmpty) {
      formDataMap['PickupAddressTexts'] = _pickupAddresses
          .map((addr) => addr.text)
          .toList();
      formDataMap['PickupAddressLatitudes'] = _pickupAddresses
          .map((addr) => addr.lat)
          .toList();
      formDataMap['PickupAddressLongitudes'] = _pickupAddresses
          .map((addr) => addr.lng)
          .toList();
    }

    if (_mainAddresses.isNotEmpty) {
      final firstMainAddress = _mainAddresses.first;
      formDataMap['AddressText'] = firstMainAddress.text;
      formDataMap['AddressLabel'] = firstMainAddress.label;
      formDataMap['AddressLatitude'] = firstMainAddress.lat;
      formDataMap['AddressLongitude'] = firstMainAddress.lng;
    }

    if (_pickupAddresses.isNotEmpty) {
      final firstPickupAddress = _pickupAddresses.first;
      formDataMap['PickupAddressText'] = firstPickupAddress.text;
      formDataMap['PickupAddressLatitude'] = firstPickupAddress.lat;
      formDataMap['PickupAddressLongitude'] = firstPickupAddress.lng;
    }

    final formData = FormData.fromMap(formDataMap);
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
        _SectionLabel('$_mainAddressLabel (${_mainAddresses.length} ที่อยู่)'),
        const SizedBox(height: 16),

        PrimaryTextField(
          labelText: _aliasLabel,
          controller: _aliasController,
          validator: _validateAlias,
          enabled: !_isLoading,
        ),

        const SizedBox(height: 16),

        AddressPickerTile(
          value: null,
          placeholder: 'เพิ่ม$_mainAddressPlaceholder',
          onTap: () => _pickMainAddress(),
        ),

        if (_mainAddresses.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'ที่อยู่หลักที่เลือก:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ..._mainAddresses.asMap().entries.map(
            (entry) => _buildAddressCard(
              entry.value,
              () => _removeMainAddress(entry.key),
              Icons.home,
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          _buildEmptyStateMessage(
            'ยังไม่มีที่อยู่หลัก กรุณาเพิ่มอย่างน้อย 1 ที่อยู่',
          ),
        ],
      ],
    );
  }

  Widget _buildPickupAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          '$_pickupAddressLabel (${_pickupAddresses.length} ที่อยู่)',
        ),
        const SizedBox(height: 16),

        AddressPickerTile(
          value: null,
          placeholder: 'เพิ่ม$_pickupAddressPlaceholder',
          onTap: () => _pickPickupAddress(),
        ),

        if (_pickupAddresses.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'ที่อยู่รับสินค้าที่เลือก:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          ..._pickupAddresses.asMap().entries.map(
            (entry) => _buildAddressCard(
              entry.value,
              () => _removePickupAddress(entry.key),
              Icons.local_shipping,
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          _buildEmptyStateMessage(
            'ยังไม่มีที่อยู่รับสินค้า กรุณาเพิ่มอย่างน้อย 1 ที่อยู่',
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    final hasRequiredAddresses =
        _mainAddresses.isNotEmpty && _pickupAddresses.isNotEmpty;
    final buttonText = _isLoading
        ? 'กำลังสร้างบัญชี...'
        : hasRequiredAddresses
        ? '$_createAccountButtonText (หลัก: ${_mainAddresses.length}, รับสินค้า: ${_pickupAddresses.length})'
        : _createAccountButtonText;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: PrimaryButton(
        text: buttonText,
        onPressed: () => _handleRegistration(),
        disabled: _isLoading || _isSelectingAddress,
      ),
    );
  }

  Widget _buildAddressCard(
    AddressInfo address,
    VoidCallback onRemove,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.text,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: onRemove,
              tooltip: 'ลบที่อยู่',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
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
