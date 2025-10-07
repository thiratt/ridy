import 'dart:convert';

import 'package:app/pages/onboarding.dart';
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
  final List<Map<String, String>> _shipments = [];
  late Future<String> imageUrl;

  void _createShipment() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnBoardingPage()),
      (route) => false,
    );
    // TODO: Navigate to create shipment page
  }

  void _openFilter() {
    // TODO: Open filter panel
  }

  void _openSearch(String q) {
    // TODO: Search shipments
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
      // setState(() {
      //   imageUrl = responseData['data']['avatarUrl'].toString().replaceAll(
      //     "localhost",
      //     "10.0.2.2",
      //   );
      // });
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    imageUrl = _getImageUrl();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      // backgroundColor: Colors.white,
      // appBar: AppBar(backgroundColor: Color(0xFFFFF1D7)),
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
              _Header(onSearch: _openSearch, imageUrl: imageUrl),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // TODO: Fetch latest shipments
                    await Future<void>.delayed(
                      const Duration(milliseconds: 600),
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                    children: [
                      Row(
                        children: [
                          const Text(
                            'รายการส่งสินค้า',
                            style: TextStyle(
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
                            label: const Text(
                              'ทั้งหมด',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      if (_shipments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: Center(
                            child: Text(
                              'ไม่มีรายการส่งสินค้า',
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.6),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._shipments.map(
                          (s) => _ShipmentTile(
                            title: s['title'] ?? '',
                            subtitle: s['subtitle'] ?? '',
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

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 12 + bottom),
        child: FloatingActionButton.extended(
          onPressed: _createShipment,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('ส่งสินค้า'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _Header extends StatelessWidget {
  final ValueChanged<String> onSearch;
  final String? imageUrl;

  const _Header({required this.onSearch, required this.imageUrl});

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
                    Row(
                      children: const [
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
                    Text(
                      'กันทรวิชัย, มหาสารคาม',
                      style: TextStyle(
                        color: AppTheme.light.colorScheme.primary.withValues(
                          alpha: 0.7,
                        ),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PrimaryTextField(
            labelText: 'ค้นหาการส่งสินค้า',
            prefixIcon: const Icon(Icons.search),
            borderRadius: 48,
          ),
        ],
      ),
    );
  }
}

class _ShipmentTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ShipmentTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to shipment details
        },
      ),
    );
  }
}
