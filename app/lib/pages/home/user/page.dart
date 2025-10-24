import 'dart:convert';

import 'package:app/models/delivery.dart';
import 'package:app/services/location_service.dart';
import 'package:app/themes/app_theme.dart';
import 'package:app/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserHomePage extends StatefulWidget {
  final String uid;
  const UserHomePage({super.key, required this.uid});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final List<Delivery> _deliveries = [];
  late Future<String> imageUrl;

  // Location state
  String _currentLocation = 'กำลังโหลดตำแหน่ง...';
  bool _isLoadingLocation = true;
  bool _isLoadingDeliveries = true;
  String _selectedFilter = 'ทั้งหมด';

  // Search state
  final TextEditingController _searchController = TextEditingController();
  List<Delivery> _filteredDeliveries = [];

  void _createShipment() {
    // TODO: Navigate to create shipment page
  }

  void _openFilter() {
    _showFilterBottomSheet();
  }

  void _openSearch(String q) {
    _searchDeliveries(q);
  }

  void _searchDeliveries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDeliveries = List.from(_deliveries);
      } else {
        _filteredDeliveries = _deliveries.where((delivery) {
          final searchLower = query.toLowerCase();
          final senderName = delivery.sender?.fullName.toLowerCase() ?? '';
          final receiverName = delivery.receiver?.fullName.toLowerCase() ?? '';
          final status = delivery.statusText.toLowerCase();
          final pickupAddress =
              delivery.pickupAddress?.addressText.toLowerCase() ?? '';
          final dropoffAddress =
              delivery.dropoffAddress?.addressText.toLowerCase() ?? '';

          return senderName.contains(searchLower) ||
              receiverName.contains(searchLower) ||
              status.contains(searchLower) ||
              pickupAddress.contains(searchLower) ||
              dropoffAddress.contains(searchLower);
        }).toList();
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'ตัวกรองสถานะ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...[
              'ทั้งหมด',
              'รอการยืนยัน',
              'ยืนยันแล้ว',
              'รับสินค้าแล้ว',
              'กำลังส่ง',
              'ส่งสำเร็จ',
              'ยกเลิก',
            ].map(
              (filter) => ListTile(
                title: Text(filter),
                trailing: _selectedFilter == filter
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  _applyFilter(filter);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _applyFilter(String filter) {
    setState(() {
      if (filter == 'ทั้งหมด') {
        _filteredDeliveries = List.from(_deliveries);
      } else {
        _filteredDeliveries = _deliveries.where((delivery) {
          return delivery.statusText == filter;
        }).toList();
      }
    });
  }

  Future<void> _loadCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationData =
          await LocationService.getCurrentLocationWithAddress();
      if (locationData != null && mounted) {
        setState(() {
          _currentLocation =
              locationData['address'] ?? 'ไม่สามารถระบุตำแหน่งได้';
          _isLoadingLocation = false;
        });
      } else if (mounted) {
        setState(() {
          _currentLocation = 'ไม่สามารถระบุตำแหน่งได้';
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocation = 'ไม่สามารถระบุตำแหน่งได้';
          _isLoadingLocation = false;
        });
      }
    }
  }

  Future<void> _loadDeliveries() async {
    setState(() {
      _isLoadingDeliveries = true;
    });

    try {
      final deliveries = await DeliveryService.getUserDeliveries(widget.uid);
      if (mounted) {
        setState(() {
          _deliveries.clear();
          _deliveries.addAll(deliveries);
          _filteredDeliveries = List.from(_deliveries);
          _isLoadingDeliveries = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDeliveries = false;
        });
        _showErrorMessage('ไม่สามารถโหลดรายการส่งสินค้าได้');
      }
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshData() async {
    await Future.wait([_loadCurrentLocation(), _loadDeliveries()]);
  }

  Future<String> _getImageUrl() async {
    String endpoint = 'http://10.0.2.2:5200/account/${widget.uid}';

    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['data']['avatarUrl'].toString().replaceAll(
        "localhost",
        "10.0.2.2",
      );
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    imageUrl = _getImageUrl();
    _loadCurrentLocation();
    _loadDeliveries();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      body: FutureBuilder(
        future: imageUrl,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          } else if (!asyncSnapshot.hasData) {
            return const Center(child: Text('No data found'));
          }
          final imageUrl = asyncSnapshot.data;

          return Column(
            children: [
              _Header(
                onSearch: _openSearch,
                imageUrl: imageUrl,
                currentLocation: _currentLocation,
                isLoadingLocation: _isLoadingLocation,
                searchController: _searchController,
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: [
                      Row(
                        children: [
                          Text(
                            'รายการส่งสินค้า (${_filteredDeliveries.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton.icon(
                            onPressed: _openFilter,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              visualDensity: VisualDensity.compact,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            icon: const Icon(Icons.tune, size: 16),
                            label: Text(
                              _selectedFilter,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_isLoadingDeliveries)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_filteredDeliveries.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.local_shipping_outlined,
                                  size: 64,
                                  color: Colors.black.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _deliveries.isEmpty
                                      ? 'ไม่มีรายการส่งสินค้า'
                                      : 'ไม่พบรายการส่งสินค้าที่ตรงกับการค้นหา',
                                  style: TextStyle(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._filteredDeliveries.map(
                          (delivery) => _DeliveryTile(
                            delivery: delivery,
                            currentUserId: widget.uid,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 12,
        children: [
          FloatingActionButton(
            heroTag: 'statBtn',
            onPressed: () {},
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.show_chart),
          ),
          FloatingActionButton.extended(
            onPressed: _createShipment,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('ส่งสินค้า'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _Header extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final String? imageUrl;
  final String currentLocation;
  final bool isLoadingLocation;
  final TextEditingController searchController;

  const _Header({
    required this.onSearch,
    required this.imageUrl,
    required this.currentLocation,
    required this.isLoadingLocation,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 237, 200),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (imageUrl == null || imageUrl!.isEmpty)
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, size: 20),
                )
              else
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: NetworkImage(imageUrl!),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.near_me_rounded, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'ตำแหน่งของคุณ',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (isLoadingLocation)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.light.colorScheme.primary
                                .withValues(alpha: 0.7),
                          ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            currentLocation,
                            style: TextStyle(
                              color: AppTheme.light.colorScheme.primary
                                  .withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryTextField(
            controller: searchController,
            labelText: 'ค้นหาการส่งสินค้า',
            prefixIcon: const Icon(Icons.search),
            borderRadius: 48,
            onChanged: onSearch,
          ),
        ],
      ),
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  final Delivery delivery;
  final String currentUserId;

  const _DeliveryTile({required this.delivery, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isSender = delivery.senderId == currentUserId;

    String getStatusColor() {
      switch (delivery.baseStatus.toLowerCase()) {
        case 'pending':
          return '#FFA726'; // Orange
        case 'confirmed':
          return '#42A5F5'; // Blue
        case 'picked_up':
          return '#AB47BC'; // Purple
        case 'in_transit':
          return '#FF7043'; // Deep Orange
        case 'delivered':
          return '#66BB6A'; // Green
        case 'cancelled':
          return '#EF5350'; // Red
        default:
          return '#9E9E9E'; // Grey
      }
    }

    Color statusColor = Color(
      int.parse(getStatusColor().replaceFirst('#', '0xFF')),
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to delivery details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      delivery.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: (isSender ? Colors.blue : Colors.green)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isSender ? 'ส่ง' : 'รับ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSender ? Colors.blue : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isSender
                          ? 'ส่งให้: ${delivery.receiver?.fullName ?? 'ไม่ระบุ'}'
                          : 'ส่งจาก: ${delivery.sender?.fullName ?? 'ไม่ระบุ'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      delivery.deliveryDescription,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(delivery.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  const Spacer(),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else {
      return 'เมื่อสักครู่';
    }
  }
}
