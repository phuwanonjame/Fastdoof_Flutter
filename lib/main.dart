import 'package:flutter/material.dart';
// ต้องใช้ Package Import เพื่อชี้ไปยังตำแหน่งจริงของ LoginScreen ในโครงสร้างฟีเจอร์
// **สำคัญ: หากชื่อโปรเจกต์ของคุณไม่ใช่ 'flutter_application_1' โปรดแก้ไขบรรทัดนี้ด้วย**
import 'package:flutter_application_1/features/auth/presentation/screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo App Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto', // กำหนดฟอนต์หลัก
      ),
      // เริ่มต้นที่หน้าจอเข้าสู่ระบบ (LoginScreen)
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}