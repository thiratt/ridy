import 'dart:io';
import 'package:app/models/user_summary.dart';
import 'package:app/shared/provider.dart';
import 'package:app/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _DeliveryDetailsConfig {
  static const double contentPadding = 16.0;
  static const double verticalSpacing = 12.0;
  static const double sectionSpacing = 20.0;
  static const double titleFontSize = 18.0;
  static const double labelFontSize = 14.0;
  static const double valueFontSize = 14.0;
  static const FontWeight titleFontWeight = FontWeight.w600;
  static const FontWeight labelFontWeight = FontWeight.w500;

  static const double avatarSize = 40.0;
  static const double packageImageHeight = 200.0;
  static const double borderRadius = 12.0;
  static const double buttonHeight = 56.0;

  static const Color sectionBorderColor = Color(0xFFE0E0E0);
  static const Color packageBackgroundColor = Color(0xFFF5F5F5);
}

/// Text constants for delivery details page
class _DeliveryDetailsTexts {
  static const String pageTitle = 'สรุปรายละเอียด';
  static const String deliveryDetailsTitle = 'รายละเอียดสินค้า';
  static const String packageTitle = 'รูปสินค้า';
  static const String createShipmentButton = 'สร้างรายการ';

  // User info labels
  static const String senderLabel = 'ส่งจาก';
  static const String recipientLabel = 'ไปยัง';
  static const String phoneLabel = 'หมายเลขโทรศัพท์';
  static const String addressLabel = 'ที่อยู่ปลายทาง';

  // Messages
  static const String createShipmentSuccess = 'สร้างรายการจัดส่งสำเร็จ';
  static const String createShipmentError = 'ไม่สามารถสร้างรายการจัดส่งได้';
  static const String missingDataError = 'ข้อมูลไม่ครบถ้วน';
}

class DeliveryDetailsPage extends StatefulWidget {
  final UserInformation recipient;
  final Address deliveryAddress;
  final File packageImage;

  const DeliveryDetailsPage({
    super.key,
    required this.recipient,
    required this.deliveryAddress,
    required this.packageImage,
  });

  @override
  State<DeliveryDetailsPage> createState() => _DeliveryDetailsPageState();
}

class _DeliveryDetailsPageState extends State<DeliveryDetailsPage> {
  bool _isCreatingShipment = false;

  Future<void> _createShipment() async {
    final provider = Provider.of<RidyProvider>(context, listen: false);
    final currentUser = provider.currentUser;

    if (currentUser == null) {
      _showErrorMessage(_DeliveryDetailsTexts.missingDataError);
      return;
    }

    setState(() => _isCreatingShipment = true);

    try {
      // TODO: Implement actual API call to create shipment
      // This would typically involve:
      // 1. Upload package image
      // 2. Create shipment record with sender, recipient, and address info
      // 3. Get shipment ID and status

      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(_DeliveryDetailsTexts.createShipmentSuccess),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home or shipment list
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('${_DeliveryDetailsTexts.createShipmentError}: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingShipment = false);
      }
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Widget _buildDeliveryDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(_DeliveryDetailsConfig.contentPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          _DeliveryDetailsConfig.borderRadius,
        ),
        border: Border.all(
          color: _DeliveryDetailsConfig.sectionBorderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _DeliveryDetailsTexts.deliveryDetailsTitle,
            style: TextStyle(
              fontSize: _DeliveryDetailsConfig.titleFontSize,
              fontWeight: _DeliveryDetailsConfig.titleFontWeight,
            ),
          ),

          SizedBox(height: _DeliveryDetailsConfig.verticalSpacing),

          // Sender and Recipient Row
          Consumer<RidyProvider>(
            builder: (context, provider, child) {
              final currentUser = provider.currentUser;
              if (currentUser == null) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfo(
                    label: _DeliveryDetailsTexts.senderLabel,
                    fullName: currentUser.fullName,
                    avatarUrl: provider.getFormattedAvatarUrl(),
                    // address: currentUser.address ?? '-', // เพิ่มที่อยู่ใต้ชื่อ
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: Icon(Icons.arrow_downward)),
                  ),
                  _buildUserInfo(
                    label: _DeliveryDetailsTexts.recipientLabel,
                    fullName: widget.recipient.fullName,
                    avatarUrl: widget.recipient.avatarUrl.replaceAll(
                      "localhost",
                      "10.0.2.2",
                    ),
                    address: widget
                        .deliveryAddress
                        .addressText, // เพิ่มที่อยู่ใต้ชื่อ
                  ),
                ],
              );
            },
          ),

          SizedBox(height: _DeliveryDetailsConfig.verticalSpacing),

          // Phone number
          _buildInfoRow(
            _DeliveryDetailsTexts.phoneLabel,
            widget.recipient.phoneNumber,
          ),

          SizedBox(height: _DeliveryDetailsConfig.verticalSpacing),

          // Address
          _buildAddressRow(),
        ],
      ),
    );
  }

  Widget _buildUserInfo({
    required String label,
    required String fullName,
    required String avatarUrl,
    String? address, // 👈 เพิ่มพารามิเตอร์นี้
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: _DeliveryDetailsConfig.labelFontSize,
            fontWeight: _DeliveryDetailsConfig.labelFontWeight,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: _DeliveryDetailsConfig.avatarSize,
              height: _DeliveryDetailsConfig.avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
              ),
              child: ClipOval(
                child: Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.person, color: Colors.grey.shade600, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: TextStyle(
                      fontSize: _DeliveryDetailsConfig.valueFontSize,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: _DeliveryDetailsConfig.labelFontSize,
              fontWeight: _DeliveryDetailsConfig.labelFontWeight,
              color: Colors.grey.shade600,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: _DeliveryDetailsConfig.valueFontSize),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            _DeliveryDetailsTexts.addressLabel,
            style: TextStyle(
              fontSize: _DeliveryDetailsConfig.labelFontSize,
              fontWeight: _DeliveryDetailsConfig.labelFontWeight,
              color: Colors.grey.shade600,
            ),
          ),
        ),

        Expanded(
          child: Text(
            widget.deliveryAddress.addressText,
            style: TextStyle(fontSize: _DeliveryDetailsConfig.valueFontSize),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _DeliveryDetailsTexts.packageTitle,
          style: TextStyle(
            fontSize: _DeliveryDetailsConfig.titleFontSize,
            fontWeight: _DeliveryDetailsConfig.titleFontWeight,
          ),
        ),

        SizedBox(height: _DeliveryDetailsConfig.verticalSpacing),

        Container(
          width: double.infinity,
          height: _DeliveryDetailsConfig.packageImageHeight,
          decoration: BoxDecoration(
            color: _DeliveryDetailsConfig.packageBackgroundColor,
            borderRadius: BorderRadius.circular(
              _DeliveryDetailsConfig.borderRadius,
            ),
            border: Border.all(
              color: _DeliveryDetailsConfig.sectionBorderColor,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              _DeliveryDetailsConfig.borderRadius,
            ),
            child: Image.file(widget.packageImage, fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }

  Widget _buildCreateShipmentButton() {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        _DeliveryDetailsConfig.contentPadding,
        8,
        _DeliveryDetailsConfig.contentPadding,
        16 + bottom,
      ),
      color: Colors.white,
      child: SizedBox(
        width: double.infinity,
        height: _DeliveryDetailsConfig.buttonHeight,
        child: PrimaryButton(
          text: _isCreatingShipment
              ? 'กำลังสร้างรายการ...'
              : _DeliveryDetailsTexts.createShipmentButton,
          onPressed: () => _createShipment(),
          disabled: _isCreatingShipment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(_DeliveryDetailsTexts.pageTitle),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                _DeliveryDetailsConfig.contentPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery details section
                  _buildDeliveryDetailsSection(),

                  SizedBox(height: _DeliveryDetailsConfig.sectionSpacing),

                  // Package image section
                  _buildPackageSection(),

                  SizedBox(height: _DeliveryDetailsConfig.sectionSpacing),
                ],
              ),
            ),
          ),

          // Create shipment button
          _buildCreateShipmentButton(),
        ],
      ),
    );
  }
}
