import 'package:flutter/material.dart';
// แก้ไข Import: จาก lib/features/menu/ ไปยัง lib/features/auth/ เพื่อนำเข้า LoginScreen
import '../../../auth/presentation/screens/login_screen.dart'; 

// --- โครงสร้างข้อมูลสำหรับ Mock Menu Item ---
class MenuItem {
  final String id;
  final String label;
  final String path;
  final IconData icon;

  MenuItem({
    required this.id,
    required this.label,
    required this.path,
    required this.icon,
  });
}

// --- ข้อมูลจำลอง (Mock Menu Items) ---
final List<MenuItem> mockMenuItems = [
  MenuItem(id: 'home', label: 'หน้าหลัก', path: '/', icon: Icons.home),
  MenuItem(id: 'profile', label: 'ข้อมูลส่วนตัว', path: '/profile', icon: Icons.person),
  MenuItem(id: 'settings', label: 'การตั้งค่า', path: '/settings', icon: Icons.settings),
  MenuItem(id: 'reports', label: 'รายงาน', path: '/reports', icon: Icons.analytics),
  MenuItem(id: 'help', label: 'ช่วยเหลือ', path: '/help', icon: Icons.help_outline),
];

// หน้าจอแสดงรายการเมนู
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เมนูหลัก'),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false, // ซ่อนปุ่มย้อนกลับ
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: mockMenuItems.length,
        itemBuilder: (context, index) {
          final item = mockMenuItems[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: ListTile(
              leading: Icon(item.icon, color: Colors.teal),
              title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('พาธ: ${item.path}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // จำลองการนำทางไปยังหน้าจอที่เกี่ยวข้อง
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('กำลังนำทางไปที่: ${item.label} (${item.path})')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // จำลองการออกจากระบบ โดยกลับไปหน้า Login
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.logout, color: Colors.white),
        tooltip: 'ออกจากระบบ',
      ),
    );
  }
}
