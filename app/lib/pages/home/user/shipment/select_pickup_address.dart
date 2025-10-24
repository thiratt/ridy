import 'package:app/models/user_information.dart';
import 'package:app/pages/home/user/shipment/upload_image.dart';
import 'package:app/shared/provider.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _PickupAddressTexts {
  static const String pageTitle = 'เลือกที่อยู่รับสินค้า';
  static const String sectionTitle = 'เลือกที่อยู่รับสินค้า';
  static const String sectionSubtitle =
      'เลือกที่อยู่ที่ต้องการให้ไรเดอร์มารับสินค้าจากคุณ';
  static const String noAddressTitle = 'ไม่มีที่อยู่รับสินค้า';
  static const String noAddressSubtitle = 'คุณยังไม่มีที่อยู่รับสินค้าในระบบ';
  static const String addAddressButton = 'เพิ่มที่อยู่รับสินค้า';
  static const String continueButton = 'ดำเนินการต่อ';
}

class _PickupAddressConfig {
  static const double contentPadding = 16.0;
  static const double verticalSpacing = 12.0;
  static const double sectionSpacing = 20.0;
  static const double titleFontSize = 18.0;
  static const double subtitleFontSize = 14.0;
  static const FontWeight titleFontWeight = FontWeight.w600;
  static const double buttonHeight = 56.0;
  static const double borderRadius = 12.0;

  static const Color selectedBackgroundColor = Color(0xFFE3F2FD);
  static const Color selectedBorderColor = Color(0xFF2196F3);
}

class SelectPickupAddressPage extends StatefulWidget {
  final UserInformation recipient;
  final Address deliveryAddress;

  const SelectPickupAddressPage({
    super.key,
    required this.recipient,
    required this.deliveryAddress,
  });

  @override
  State<SelectPickupAddressPage> createState() =>
      _SelectPickupAddressPageState();
}

class _SelectPickupAddressPageState extends State<SelectPickupAddressPage> {
  Address? _selectedPickupAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(_PickupAddressTexts.pageTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<RidyProvider>(
        builder: (context, provider, child) {
          final currentUser = provider.currentUser;
          if (currentUser == null) {
            return const Center(child: Text('ไม่พบข้อมูลผู้ใช้'));
          }

          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(
                      _PickupAddressConfig.contentPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(
                          height: _PickupAddressConfig.sectionSpacing,
                        ),
                        _buildPickupAddressList(currentUser.pickupAddresses),
                      ],
                    ),
                  ),
                ),
                _buildContinueButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _PickupAddressTexts.sectionTitle,
          style: TextStyle(
            fontSize: _PickupAddressConfig.titleFontSize,
            fontWeight: _PickupAddressConfig.titleFontWeight,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: _PickupAddressConfig.verticalSpacing / 2),
        Text(
          _PickupAddressTexts.sectionSubtitle,
          style: TextStyle(
            fontSize: _PickupAddressConfig.subtitleFontSize,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildPickupAddressList(List<Address> pickupAddresses) {
    if (pickupAddresses.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: pickupAddresses
          .map((address) => _buildAddressItem(address))
          .toList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 40,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _PickupAddressTexts.noAddressTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _PickupAddressTexts.noAddressSubtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to add pickup address page
                // This would typically navigate to an add address flow
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ฟีเจอร์เพิ่มที่อยู่กำลังพัฒนา'),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text(_PickupAddressTexts.addAddressButton),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(Address address) {
    final isSelected = _selectedPickupAddress?.id == address.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedPickupAddress = address;
          });
        },
        borderRadius: BorderRadius.circular(_PickupAddressConfig.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? _PickupAddressConfig.selectedBackgroundColor
                : Colors.white,
            border: Border.all(
              color: isSelected
                  ? _PickupAddressConfig.selectedBorderColor
                  : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(
              _PickupAddressConfig.borderRadius,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? _PickupAddressConfig.selectedBorderColor
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? _PickupAddressConfig.selectedBorderColor
                            : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.addressText,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _PickupAddressConfig.selectedBorderColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        _PickupAddressConfig.contentPadding,
        8,
        _PickupAddressConfig.contentPadding,
        16 + bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: _PickupAddressConfig.buttonHeight,
        child: PrimaryButton(
          text: _PickupAddressTexts.continueButton,
          onPressed: _continueToUploadImage,
          disabled: _selectedPickupAddress == null,
        ),
      ),
    );
  }

  void _continueToUploadImage() {
    if (_selectedPickupAddress == null) return;

    navigateTo(
      context,
      UploadImagePage(
        recipient: widget.recipient,
        deliveryAddress: widget.deliveryAddress,
        pickupAddress: _selectedPickupAddress!,
      ),
      "/shipment/upload_image",
    );
  }
}
