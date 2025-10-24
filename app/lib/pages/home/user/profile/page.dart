import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/shared/provider.dart';
import 'package:app/pages/auth/login/page.dart';
import 'package:app/utils/navigation.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: SafeArea(
        child: Column(
          children: [
            _buildProfileHeader(context),
            Expanded(child: _buildMenuItems(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<RidyProvider>(
      builder: (context, provider, child) {
        final user = provider.currentUser;
        final userName = user?.fullname ?? 'ผู้ใช้งาน';

        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE8A5A5), Color(0xFF7FB3D3)],
                  ),
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),

              const SizedBox(height: 16),

              Text(
                userName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.edit_outlined,
            title: 'แก้ไขข้อมูลส่วนตัว',
            onTap: () {
              _showComingSoon(context, 'แก้ไขข้อมูลส่วนตัว');
            },
          ),

          const SizedBox(height: 12),

          _buildMenuItem(
            icon: Icons.location_on_outlined,
            title: 'แก้ไขที่อยู่',
            onTap: () {
              _showComingSoon(context, 'แก้ไขที่อยู่');
            },
          ),

          const SizedBox(height: 12),

          _buildMenuItem(
            icon: Icons.lock_outline,
            title: 'เปลี่ยนรหัสผ่าน',
            onTap: () {
              _showComingSoon(context, 'เปลี่ยนรหัสผ่าน');
            },
          ),

          const SizedBox(height: 12),

          _buildMenuItem(
            icon: Icons.logout,
            title: 'ออกจากระบบ',
            isLogout: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isLogout ? Colors.red : Colors.black,
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isLogout ? Colors.red : Colors.black,
                    ),
                  ),
                ),

                if (!isLogout)
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เร็วๆ นี้'),
          content: Text('ฟีเจอร์ "$feature" จะเปิดให้ใช้งานเร็วๆ นี้'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ออกจากระบบ'),
          content: const Text('คุณต้องการออกจากระบบหรือไม่?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () => _logout(context),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('ออกจากระบบ'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) {
    final provider = Provider.of<RidyProvider>(context, listen: false);
    provider.clearUser();

    navigateAndRemoveUntil(
      context,
      const LoginPage(),
      '/login',
      useDefaultTransition: true,
    );
  }
}
