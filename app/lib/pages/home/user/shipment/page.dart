import 'dart:convert';
import 'dart:developer';
import 'package:app/config/api_constants.dart';
import 'package:app/models/user_summary.dart';
import 'package:app/pages/home/user/shipment/upload_image.dart';
import 'package:app/shared/provider.dart';
import 'package:app/utils/navigation.dart';
import 'package:app/widgets/map.dart';
import 'package:app/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'user_detail_sheet.dart';

class _LocationTexts {
  static const String appBarTitle = 'สร้างการจัดส่งใหม่';
}

class ShipmentPage extends StatefulWidget {
  const ShipmentPage({super.key});

  @override
  State<ShipmentPage> createState() => _ShipmentPageState();
}

class _ShipmentPageState extends State<ShipmentPage> {
  bool _isSearchFocused = false;
  final FocusNode _searchFocusNode = FocusNode();
  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();
  bool _isMapReady = false;

  List<UserInformation> _allUsers = [];
  List<UserInformation> _filteredUsers = [];
  bool _isLoadingUsers = false;
  String? _userErrorMessage;
  final TextEditingController _searchController = TextEditingController();
  final RidyMapController _mapController = RidyMapController();

  // Navigation state for user detail view
  bool _showUserDetail = false;
  UserInformation? _selectedUser;

  @override
  void initState() {
    super.initState();
    _initializeSearchFocusNode();
    _fetchAllUsers();
    _searchController.addListener(_filterUsers);
  }

  void _initializeSearchFocusNode() {
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _isSearchFocused = true;
          // Reset to user selection when search is focused
          _showUserDetail = false;
          _selectedUser = null;
        });
        _draggableScrollableController.animateTo(
          0.8,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() {
          _isSearchFocused = false;
        });
        log('Search field unfocused');
      }
    });
  }

  Future<void> _fetchAllUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoadingUsers = true;
      _userErrorMessage = null;
    });

    try {
      final provider = Provider.of<RidyProvider>(context, listen: false);
      final currentUserId = provider.currentUser?.id;

      final url = currentUserId != null
          ? '${ApiConstants.buildUrlEndpoint(ApiRoute.getAllUsers)}?excludeUserId=$currentUserId'
          : ApiConstants.buildUrlEndpoint(ApiRoute.getAllUsers);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final getAllUsersResponse = GetAllUsersResponse.fromJson(
          json.decode(response.body),
        );

        if (mounted) {
          setState(() {
            _allUsers = getAllUsersResponse.data;
            _filteredUsers = _allUsers;
          });
        }
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching users: $e');
      if (mounted) {
        setState(() {
          _userErrorMessage = 'ไม่สามารถโหลดรายชื่อผู้ใช้ได้';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      if (query.isEmpty) {
        _filteredUsers = _allUsers;
      } else {
        _filteredUsers = _allUsers.where((user) {
          final name = user.fullName.toLowerCase();
          final phone = user.phoneNumber.toLowerCase();
          return name.contains(query) || phone.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _LocationTexts.appBarTitle,
          semanticsLabel: _LocationTexts.appBarTitle,
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          RidyMap(
            controller: _mapController,
            onStatusChanged: (status) {
              if (status.status == RidyMapStatus.active && !_isMapReady) {
                if (mounted) {
                  setState(() {
                    _isMapReady = true;
                  });
                }
              }
            },
          ),
          Positioned(
            right: 16,
            bottom: bottom + (screenHeight * 0.15) + 16,
            child: FloatingActionButton(
              onPressed: () => _mapController.moveToUserLocation(),
              heroTag: 'recenter',
              tooltip: "กลับไปยังตำแหน่งของฉัน",
              backgroundColor: theme.colorScheme.primaryContainer,
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              child: !_isMapReady
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_outlined),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: (_isSearchFocused || _showUserDetail) ? 0.8 : 0.2,
            minChildSize: (_isSearchFocused || _showUserDetail) ? 0.8 : 0.2,
            maxChildSize: 0.8,
            snap: true,
            snapSizes: (_isSearchFocused || _showUserDetail)
                ? const [0.8]
                : const [0.2, 0.4, 0.8],
            controller: _draggableScrollableController,
            builder: (context, scrollController) {
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: _showUserDetail && _selectedUser != null
                    ? UserDetailSheet(
                        user: _selectedUser!,
                        onBack: _backToUserSelection,
                        onSelectDeliveryAddress: _selectDeliveryAddress,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            // Drag handle
                            SliverToBoxAdapter(
                              child: Container(
                                height: 32,
                                alignment: Alignment.center,
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),

                            // Header content
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'เลือกผู้รับสินค้า',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    PrimaryTextField(
                                      controller: _searchController,
                                      labelText:
                                          "ค้นหาผู้รับสินค้าด้วยหมายเลขโทรศัพท์",
                                      prefixIcon: const Icon(Icons.search),
                                      focusNode: _searchFocusNode,
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ),

                            // Content list
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              sliver: _buildUserList(),
                            ),
                          ],
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    if (_isLoadingUsers) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_userErrorMessage != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  _userErrorMessage!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchAllUsers,
                  child: const Text('ลองใหม่'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_filteredUsers.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.search_off,
                  size: 48,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isNotEmpty
                      ? 'ไม่พบผู้ใช้ที่ค้นหา'
                      : 'ไม่มีผู้ใช้ในระบบ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index >= _filteredUsers.length) {
          return const SizedBox(height: 100);
        }

        final user = _filteredUsers[index];
        return _buildUserItem(user);
      }, childCount: _filteredUsers.length + 1),
    );
  }

  Widget _buildUserItem(UserInformation user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              user.avatarUrl.replaceAll(
                "localhost",
                "10.0.2.2",
              ), // for development only. Need to change in production
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        title: Text(
          user.fullName,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              user.phoneNumber,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${user.addresses.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_shipping,
                        size: 12,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${user.pickupAddresses.length}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        onTap: () {
          _selectUser(user);
        },
      ),
    );
  }

  void _selectUser(UserInformation user) {
    FocusScope.of(context).unfocus();

    setState(() {
      _selectedUser = user;
      _showUserDetail = true;
    });

    // Animate to expanded state
    _draggableScrollableController.animateTo(
      0.8,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _backToUserSelection() {
    setState(() {
      _showUserDetail = false;
      _selectedUser = null;
    });
  }

  void _selectDeliveryAddress(Address address) {
    // Handle delivery address selection
    navigateTo(context, UploadImagePage(), "/shipment/upload_image");
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: const Text('ยืนยันที่อยู่จัดส่ง'),
    //     content: Column(
    //       mainAxisSize: MainAxisSize.min,
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Text('ผู้รับสินค้า: ${_selectedUser?.fullName}'),
    //         const SizedBox(height: 8),
    //         if (address.label?.isNotEmpty == true) ...[
    //           Text('ป้ายกำกับ: ${address.label}'),
    //           const SizedBox(height: 8),
    //         ],
    //         Text('ที่อยู่: ${address.addressText}'),
    //       ],
    //     ),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.pop(context),
    //         child: const Text('ยกเลิก'),
    //       ),
    //       ElevatedButton(
    //         onPressed: () {
    //           Navigator.pop(context);
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             SnackBar(
    //               content: Text('เลือกที่อยู่จัดส่งเรียบร้อยแล้ว'),
    //               action: SnackBarAction(
    //                 label: 'ต่อไป',
    //                 onPressed: () {
    //                   // Navigate to next step (create shipment form)
    //                 },
    //               ),
    //             ),
    //           );
    //         },
    //         child: const Text('ยืนยัน'),
    //       ),
    //     ],
    //   ),
    // );
  }
}
