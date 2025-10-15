// lib/features/menu/presentation/screens/menu_screen.dart

import 'package:flutter/material.dart';

class MenuItem {
  final String name;
  final String description;
  final double price;

  MenuItem(this.name, this.description, this.price);
}

class MenuScreen extends StatelessWidget {
  final VoidCallback onLogout;
  MenuScreen({super.key, required this.onLogout});

  final List<MenuItem> menuItems = [
    MenuItem('เบอร์เกอร์เนื้อ', 'เนื้อย่างพรีเมียม, ชีส, ซอสสูตรพิเศษ', 129.0),
    MenuItem('เฟรนช์ฟรายส์ใหญ่', 'กรอบนอกนุ่มใน เสิร์ฟพร้อมซอสมะเขือเทศ', 59.0),
    MenuItem('ไก่ทอดกรอบ', 'ปีกไก่ทอดสูตรต้นตำรับ 3 ชิ้น', 99.0),
    MenuItem('โค้กแก้วใหญ่', 'โค้กเย็นชื่นใจ', 39.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เมนูอาหาร Fast Food'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              // 💡 ตรรกะ: นำทางไปหน้าตะกร้า (CartScreen)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('จำลอง: ไปหน้าตะกร้าสินค้า'))
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogout, // เรียกใช้ callback เพื่อ Logout
            tooltip: 'ออกจากระบบ',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.local_dining, color: Colors.red),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item.description),
              trailing: Text('฿${item.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, color: Colors.red)),
              onTap: () {
                // 💡 ตรรกะ: เพิ่มลงตะกร้า (Add to Cart)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.name} ถูกเพิ่มลงในตะกร้าแล้ว!'))
                );
              },
            ),
          );
        },
      ),
    );
  }
}