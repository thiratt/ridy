import 'package:app/pages/home/user/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeWrapper extends StatefulWidget {
  final String uid;
  const HomeWrapper({super.key, required this.uid});
  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _navIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      UserHomePage(uid: widget.uid),
      Container(color: Colors.blueAccent), // TODO: UserShipmentPage
      Container(color: Colors.greenAccent), // TODO: UserProfilePage
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _navIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navIndex,
        onDestinationSelected: (i) => setState(() => _navIndex = i),
        destinations: [
          NavigationDestination(
            icon: SvgPicture.asset('assets/icon/arrows-up-from-line.svg'),
            label: 'ส่งสินค้า',
          ),
          NavigationDestination(icon: Icon(Icons.save_alt), label: 'รับสินค้า'),
          NavigationDestination(icon: Icon(Icons.person), label: 'โปรไฟล์'),
        ],
      ),
    );
  }
}
