import 'package:flutter/material.dart';
// ต้อง import หน้าจอปลายทางสำหรับทุก Role
import '../../../menu/presentation/screens/menu_screen.dart'; 
// ต้อง import หน้าจอตั้งค่า PIN
import 'pin_setup_screen.dart';
// ต้อง import หน้าจอตรวจสอบ PIN
import 'pin_verification_screen.dart'; 
// ต้อง import หน้าจอหลักของบริกร
import 'waiter_screen.dart'; 

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final Color _primaryColor = const Color(0xFF007AFF);
  final Color _darkBackgroundColor = const Color(0xFF121212);
  final Color _darkCardColor = const Color(0xFF1E1E1E);

  // *** ตัวแปรจำลองสถานะ PIN ที่จำเป็น (แก้ไขจุดที่เคย Error) ***
  bool _hasPinSet = false; 
  String? _userPin;
  // *************************************************************

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPinStatus());
  }

  void _checkPinStatus() {
    if (!_hasPinSet) {
      _promptForPinSetup();
    }
  }

  void _promptForPinSetup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PinSetupScreen(
          onPinSet: _handlePinSetSuccess,
        ),
      ),
    );
  }

  void _handlePinSetSuccess(String pin) {
    setState(() {
      _hasPinSet = true;
      _userPin = pin; 
    });
    // ปิดหน้า PinSetupScreen (ถ้ายังเปิดอยู่)
    if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); 
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ตั้งค่า PIN สำเร็จ!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  // ฟังก์ชันนำทางเมื่อเลือก Role
  void _navigateToRole(BuildContext context, String role) {
    if (!_hasPinSet || _userPin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาตั้งค่า PIN 6 หลักก่อนดำเนินการต่อ', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.orange,
        ),
      );
      _promptForPinSetup();
      return;
    }
    
    // 1. กำหนดหน้าจอปลายทาง (NextScreen)
    Widget nextScreen;
    if (role == 'Server') {
        // ** SERVER ROLE: ไปที่ WaiterScreen **
        nextScreen = const WaiterScreen();
    } else {
        // ** บทบาทอื่น ๆ: ไปที่ MenuScreen (หรือหน้าจอที่เกี่ยวข้อง) **
        nextScreen = const MenuScreen(); 
    }

    // 2. นำทางไปยัง PinVerificationScreen เพื่อตรวจสอบ PIN ก่อน
    Navigator.of(context).push(
        MaterialPageRoute(
            builder: (context) => PinVerificationScreen(
                correctPin: _userPin!, // ส่ง PIN ที่ตั้งไว้ไปตรวจสอบ
                nextScreen: nextScreen, 
            ),
        ),
    );
  }

  // Widget แสดงตัวเลือกบทบาท
  Widget _buildRoleCard(
      BuildContext context, IconData icon, String title, String role) {
    return InkWell(
      onTap: () => _navigateToRole(context, role), 
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _darkCardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: _primaryColor),
            const SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackgroundColor,
      appBar: AppBar(
        title: const Text('เลือกบทบาทการทำงาน', style: TextStyle(color: Colors.white)),
        backgroundColor: _darkBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'สถานะ PIN: ${_hasPinSet ? 'ตั้งค่าแล้ว' : 'ต้องตั้งค่า!'}', 
                style: TextStyle(fontSize: 18, color: _hasPinSet ? Colors.green : Colors.red),
              ),
              const SizedBox(height: 20),
              Text(
                'คุณต้องการเข้าใช้งานในฐานะใด?',
                style: TextStyle(fontSize: 20, color: Colors.grey[300]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Grid สำหรับแสดงตัวเลือกบทบาท
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.0, 
                children: <Widget>[
                  _buildRoleCard(context, Icons.dinner_dining, 'บริกร (Server)', 'Server'),
                  _buildRoleCard(context, Icons.point_of_sale, 'จุดชำระเงิน (POS)', 'POS'),
                  _buildRoleCard(context, Icons.kitchen, 'ห้องครัว (Kitchen)', 'Kitchen'),
                  _buildRoleCard(context, Icons.manage_accounts, 'ผู้จัดการ (Manager)', 'Manager'),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}