// lib/models/order_models.dart

import 'package:flutter/material.dart';

// เพิ่ม Enum สำหรับประเภทการชำระเงิน
enum PaymentType { cash, scan }

// โมเดลสำหรับรายการอาหารที่สั่ง
class OrderItem {
  final String name;
  final double price;
  int quantity;
  final String orderSource; // เช่น 'T1-Waiter', 'T1-DeviceA'

  OrderItem({required this.name, required this.price, this.quantity = 1, required this.orderSource});

  // ฟังก์ชันช่วยในการ Copy
  OrderItem copyWith({int? quantity}) {
    return OrderItem(
      name: name,
      price: price,
      quantity: quantity ?? this.quantity,
      orderSource: orderSource,
    );
  }
}

// โมเดลสำหรับเมนูทั้งหมด (จำลองฐานข้อมูล)
class MenuItem {
  final String name;
  final double price;
  final String category;

  MenuItem({required this.name, required this.price, required this.category});
}

// โมเดลสำหรับ Order ที่ผูกกับโต๊ะ
class TableOrder {
  final String orderId;
  final int tableId;
  final String tableName; 
  List<OrderItem> items;
  bool isPaid;
  bool isComplete;
  bool? isSentToKitchen; 
  
  // Getter ที่ปลอดภัย: ใช้เพื่อป้องกัน TypeError 
  bool get safeIsSentToKitchen => isSentToKitchen ?? false;

  TableOrder({
    required this.orderId,
    required this.tableId,
    required this.tableName,
    required this.items,
    this.isPaid = false,
    this.isComplete = false,
    this.isSentToKitchen,
  });
  
  // ฟังก์ชันช่วยในการ Copy
  TableOrder copyWith({
    List<OrderItem>? items,
    bool? isPaid,
    bool? isComplete,
    bool? isSentToKitchen,
  }) {
    return TableOrder(
      orderId: orderId,
      tableId: tableId,
      tableName: tableName, 
      items: items ?? this.items,
      isPaid: isPaid ?? this.isPaid,
      isComplete: isComplete ?? this.isComplete,
      isSentToKitchen: isSentToKitchen ?? this.isSentToKitchen, 
    );
  }
}

// โมเดลสำหรับสถานะโต๊ะ (ใช้ใน WaiterScreen)
class TableStatus {
  final int id;
  final String name;
  final bool isOccupied;
  final int peopleCount;
  final String qrCode;
  final TableOrder? order;
  final Color statusColor;

  TableStatus({
    required this.id,
    required this.name,
    this.isOccupied = false,
    this.peopleCount = 0,
    required this.qrCode,
    this.order,
    this.statusColor = Colors.green,
  });

  TableStatus copyWith({
    bool? isOccupied,
    int? peopleCount,
    TableOrder? order,
    Color? statusColor,
  }) {
    return TableStatus(
      id: id,
      name: name,
      isOccupied: isOccupied ?? this.isOccupied,
      peopleCount: peopleCount ?? this.peopleCount,
      qrCode: qrCode,
      order: order ?? this.order,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}

// ****************************************************
// ************ โมเดลและตัวแปรสำหรับประวัติการชำระเงิน ************
// ****************************************************

// โมเดลสำหรับประวัติการชำระเงินที่ปิดบิลแล้ว
class OrderHistory {
  final String historyId;
  final String orderId; 
  final String tableName;
  final String qrCode; // รหัส QR หรือ ID โต๊ะที่ถูกสแกน
  final List<OrderItem> items; // รายการอาหารในบิลนั้น
  final double grandTotal; // ยอดรวมสุดท้าย
  final DateTime paymentTime; // เวลาที่ชำระเงิน
  final PaymentType paymentType; // วิธีการชำระเงิน

  OrderHistory({
    required this.historyId,
    required this.orderId,
    required this.tableName,
    required this.qrCode,
    required this.items,
    required this.grandTotal,
    required this.paymentTime,
    required this.paymentType,
  });
}

// รายการเก็บประวัติการชำระเงินทั้งหมด (จำลองฐานข้อมูล)
List<OrderHistory> globalOrderHistory = [];