import 'package:app/models/request/signup_request.dart';
import 'package:app/models/user_information.dart';
import 'package:app/models/user_signup_draft.dart';
import 'package:app/models/response/all_users.dart';
import 'package:app/pages/auth/signup/user/select_address.dart';
import 'package:app/services/authentication.dart';
import 'package:app/shared/provider.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/widgets/address_picker.dart';
import 'package:app/widgets/home_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:app/widgets/text_field.dart';
import 'package:app/widgets/button.dart';
import 'package:provider/provider.dart';

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
    final authService = AuthenticationService();
    final provider = Provider.of<RidyProvider>(context, listen: false);

    final signupRequest = SignupRequest(
      phoneNumber: widget.draft.phone,
      password: widget.draft.password,
      firstname: widget.draft.firstname,
      lastname: widget.draft.lastname,
      role: 'USER',
      avatarFileData: widget.draft.avatar,
      mainAddressTexts: _mainAddresses.isNotEmpty
          ? _mainAddresses.map((addr) => addr.text).toList()
          : null,
      mainAddressLabels: _mainAddresses.isNotEmpty
          ? _mainAddresses.map((addr) => addr.label).toList()
          : null,
      mainAddressLatitudes: _mainAddresses.isNotEmpty
          ? _mainAddresses.map((addr) => addr.lat).toList()
          : null,
      mainAddressLongitudes: _mainAddresses.isNotEmpty
          ? _mainAddresses.map((addr) => addr.lng).toList()
          : null,
      pickupAddressTexts: _pickupAddresses.isNotEmpty
          ? _pickupAddresses.map((addr) => addr.text).toList()
          : null,
      pickupAddressLabels: _pickupAddresses.isNotEmpty
          ? _pickupAddresses.map((addr) => addr.label).toList()
          : null,
      pickupAddressLatitudes: _pickupAddresses.isNotEmpty
          ? _pickupAddresses.map((addr) => addr.lat).toList()
          : null,
      pickupAddressLongitudes: _pickupAddresses.isNotEmpty
          ? _pickupAddresses.map((addr) => addr.lng).toList()
          : null,
      addressText: _mainAddresses.isNotEmpty ? _mainAddresses.first.text : null,
      addressLabel: _mainAddresses.isNotEmpty
          ? _mainAddresses.first.label
          : null,
      addressLatitude: _mainAddresses.isNotEmpty
          ? _mainAddresses.first.lat
          : null,
      addressLongitude: _mainAddresses.isNotEmpty
          ? _mainAddresses.first.lng
          : null,
      pickupAddressText: _pickupAddresses.isNotEmpty
          ? _pickupAddresses.first.text
          : null,
      pickupAddressLabel: _pickupAddresses.isNotEmpty
          ? _pickupAddresses.first.label
          : null,
      pickupAddressLatitude: _pickupAddresses.isNotEmpty
          ? _pickupAddresses.first.lat
          : null,
      pickupAddressLongitude: _pickupAddresses.isNotEmpty
          ? _pickupAddresses.first.lng
          : null,
    );

    final response = await authService.signup(signupRequest);

    switch (response.result) {
      case SignupResult.success:
        if (response.user != null) {
          authService.saveUserToProvider(provider, response.user!);
          await _handleSuccessfulRegistration(response.user!);
        } else {
          throw 'เกิดข้อผิดพลาดในการประมวลผลข้อมูล';
        }
        break;
      case SignupResult.phoneNumberAlreadyExists:
        throw response.message ?? 'หมายเลขโทรศัพท์นี้ถูกใช้แล้ว';
      case SignupResult.validationError:
        throw response.message ?? 'ข้อมูลที่กรอกไม่ถูกต้อง';
      case SignupResult.serverError:
        throw response.message ?? 'เซิร์ฟเวอร์ขัดข้อง กรุณาลองใหม่ภายหลัง';
      case SignupResult.networkError:
        throw response.message ?? 'เกิดข้อผิดพลาดในการเชื่อมต่อ';
    }
  }

  Future<void> _handleSuccessfulRegistration(UserInformation userData) async {
    if (!mounted) return;

    _showSuccessMessage('สมัครสมาชิกสำเร็จ');

    try {
      await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeWrapper(uid: userData.id)),
        (route) => false,
      );
    } catch (e) {
      throw 'เกิดข้อผิดพลาดในการประมวลผลข้อมูล';
    }
  }

  void _handleRegistrationError(dynamic error) {
    String errorMessage = 'เกิดข้อผิดพลาดในการสมัครสมาชิก';

    if (error is String) {
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
