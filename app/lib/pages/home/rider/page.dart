import 'dart:convert';

import 'package:app/pages/onboarding.dart';
import 'package:app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RiderHomePage extends StatefulWidget {
  final String uid;
  const RiderHomePage({super.key, required this.uid});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  late Future<List<String>> riderData;

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  @override
  void initState() {
    super.initState();
    riderData = _getImageUrl();
  }

  Future<List<String>> _getImageUrl() async {
    String endpoint = 'http://10.0.2.2:5200/account/${widget.uid}';

    final response = await http.get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      String imageUrl = responseData['data']['avatarUrl'].toString().replaceAll(
        "localhost",
        "10.0.2.2",
      );
      String vehiclePlate =
          responseData['data']['riderProfile']['vehiclePlate'];
      String fullname =
          '${responseData['data']['firstName']} ${responseData['data']['lastName']}';

      return [imageUrl, vehiclePlate, fullname];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;

    return Scaffold(
      // backgroundColor: Colors.white,
      body: FutureBuilder(
        future: riderData,
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (asyncSnapshot.hasError) {
            return Center(child: Text('Error: ${asyncSnapshot.error}'));
          } else if (!asyncSnapshot.hasData || asyncSnapshot.data!.isEmpty) {
            return const Center(child: Text('No data found'));
          }

          final imageUrl = asyncSnapshot.data![0];
          final vehiclePlate = asyncSnapshot.data![1];
          final fullname = asyncSnapshot.data![2];

          return Column(
            children: [
              // ---------------- Header ----------------
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  16,
                  MediaQuery.of(context).viewPadding.top + 12,
                  8,
                  14,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1D7),
                ),
                child: Row(
                  children: [
                    if (imageUrl.isEmpty)
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, size: 20),
                      )
                    else
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: NetworkImage(imageUrl),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                fullname,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            vehiclePlate,
                            style: TextStyle(
                              color: AppTheme.light.colorScheme.primary
                                  .withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: 'ออกจากระบบ',
                      child: IconButton.filledTonal(
                        onPressed: () => {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OnBoardingPage(),
                            ),
                            (route) => false,
                          ),
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                        icon: Icon(Icons.power_settings_new_rounded),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------------- Body ----------------
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    children: const [_EmptyJobsCard()],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: SizedBox(height: 12 + bottom),
    );
  }
}

class _EmptyJobsCard extends StatelessWidget {
  const _EmptyJobsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 18, 14, 18),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.motorcycle_rounded, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ยังไม่มีงานในบริเวณนี้',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black.withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
