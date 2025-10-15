// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ตรวจสอบให้แน่ใจว่า import ถูกต้องตามชื่อ project ของคุณ
import 'package:flutter_application_1/main.dart'; 

void main() {
  // เปลี่ยนชื่อ test ให้สอดคล้องกับฟังก์ชันของแอปพลิเคชันจริง
  testWidgets('App should build and show Login or Loading screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // ✅ FIX: เปลี่ยน MyApp() เป็น FastFoodApp()
    await tester.pumpWidget(const FastFoodApp());

    // 💡 เนื่องจาก main.dart มี Future.delayed(Duration(seconds: 1)) 
    // เราต้องรอให้ Future นั้นเสร็จสิ้นเพื่อให้หน้าจอหลักปรากฏ
    await tester.pumpAndSettle(); 
    
    // 💡 การทดสอบใหม่: ตรวจสอบว่าแอปพลิเคชันเข้าสู่หน้า Login 
    // ซึ่งจะมี AppBar ที่มีคำว่า 'เข้าสู่ระบบสั่งอาหาร'
    expect(find.text('เข้าสู่ระบบสั่งอาหาร'), findsOneWidget); 
    
    // ตรรกะการทดสอบ Counter เก่า (หาปุ่ม '+' และเลข '0') ถูกลบออกไปแล้ว
    // เพราะไม่มีอยู่ในแอปพลิเคชันสั่งอาหารของคุณ
    
  });
}
