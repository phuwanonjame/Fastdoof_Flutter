// lib/features/auth/presentation/screens/waiter_screen.dart

import 'package:flutter/material.dart';

import '../../../../models/order_models.dart'; 
import 'order_detail_screen.dart'; 
import 'order_history_screen.dart'; // เพิ่ม Import

// หน้าจอหลักสำหรับบริกร (Waiter/Server)
class WaiterScreen extends StatefulWidget {
  const WaiterScreen({super.key});

  @override
  State<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> {
  // *** ปรับสีสำหรับ Light Mode (ใช้ Material 3 Palette) ***
  final Color _primaryColor = const Color(0xFF007AFF); // สีน้ำเงินหลัก (เดิม)
  final Color _lightBackgroundColor = const Color(0xFFF7F7F7); // พื้นหลังจอ (เกือบขาว)
  final Color _lightCardColor = const Color(0xFFFFFFFF); // พื้นหลัง Card (ขาว)
  final Color _textColor = const Color(0xFF1F1F1F); // สีข้อความหลัก (ดำเข้ม)
  final Color _secondaryTextColor = const Color(0xFF5A5A5A); // สีข้อความรอง (เทาเข้ม)


  // โต๊ะเริ่มต้นเป็น "ว่าง" ทั้งหมด
  List<TableStatus> _tables = [
    TableStatus(id: 1, name: 'A1', isOccupied: false, peopleCount: 0, qrCode: 'FASTFOOD-A1', statusColor: Colors.green.shade600),
    TableStatus(id: 2, name: 'A2', isOccupied: false, peopleCount: 0, qrCode: 'FASTFOOD-A2', statusColor: Colors.green.shade600),
    TableStatus(id: 3, name: 'B1', isOccupied: false, peopleCount: 0, qrCode: 'FASTFOOD-B1', statusColor: Colors.green.shade600),
    TableStatus(id: 4, name: 'B2', isOccupied: false, peopleCount: 0, qrCode: 'FASTFOOD-B2', statusColor: Colors.green.shade600),
    TableStatus(id: 5, name: 'C1', isOccupied: false, peopleCount: 0, qrCode: 'FASTFOOD-C1', statusColor: Colors.green.shade600),
    TableStatus(id: 6, name: 'C2', isOccupied: false, peopleCount: 0, qrCode: 'FASTFOOD-C2', statusColor: Colors.green.shade600),
    TableStatus(id: 7, name: 'D1', isOccupied: false, peopleCount: 0, qrCode: 'FASTFOOD-D1', statusColor: Colors.green.shade600),
    TableStatus(id: 8, name: 'D2', isOccupied: false, peopleCount: 0, qrCode: 'FASTFOOD-D8', statusColor: Colors.green.shade600),
  ];

  // ******************************
  // ฟังก์ชันจัดการ Order ใหม่ (ใช้ TableOrder จาก models)
  // ******************************
  
  // ฟังก์ชันจัดการเมื่อ Order มีการเปลี่ยนแปลง
  void _handleOrderUpdate(int tableId, TableOrder newOrder) {
    setState(() {
      final index = _tables.indexWhere((table) => table.id == tableId);
      if (index != -1) {
        
        // ตรรกะ: ไม่ว่างเมื่อมีรายการสั่ง (items.isNotEmpty) 
        final bool isOccupied = newOrder.items.isNotEmpty;
        
        Color newStatusColor = Colors.green.shade600; // ค่าเริ่มต้น (ว่าง)
        if (isOccupied) {
            // มีรายการสั่ง: ไม่ว่าง
            if (newOrder.safeIsSentToKitchen) {
                // มีรายการสั่ง + ส่งครัวแล้ว = กำลังทำอาหาร (สีแดง)
                newStatusColor = Colors.red.shade600;
            } else {
                // มีรายการสั่ง + ยังไม่ส่งครัว = รอส่งครัว (จะถูกจัดการใน _buildTableCard เป็นสีส้ม)
                newStatusColor = Colors.red.shade600; // ใช้สีแดงเป็นค่าตั้งต้น
            }
        }
        
        // ถ้าปิดบิลและรายการสั่งเป็น 0, โต๊ะต้องว่างเสมอ
        if (newOrder.isComplete && newOrder.items.isEmpty) {
            newStatusColor = Colors.green.shade600; 
        }

        // อัปเดต TableStatus
        _tables[index] = _tables[index].copyWith(
          isOccupied: isOccupied, 
          // กำหนดจำนวนคน: หากมีการสั่งถือว่ามีคนนั่ง (ตั้งเป็น 1) หากว่างก็เป็น 0
          peopleCount: isOccupied ? (_tables[index].peopleCount > 0 ? _tables[index].peopleCount : 1) : 0, 
          order: isOccupied ? newOrder : null, // ถ้าว่าง order จะถูกล้าง
          statusColor: newStatusColor,
        );
      }
    });
  }

  // ฟังก์ชันเปิดหน้า OrderDetailScreen (ใช้ TableOrder จาก models)
  void _openOrderDetails(TableStatus table) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(
          tableId: table.id,
          tableName: table.name,
          tableQrCode: table.qrCode, // ส่ง QR Code ไปด้วย
          currentOrder: table.order, // ใช้ TableOrder จาก order_models.dart
          onOrderUpdated: (updatedOrder) => _handleOrderUpdate(table.id, updatedOrder),
        ),
      ),
    );
  }

  // ฟังก์ชันใหม่: เปิดหน้าจอประวัติ
  void _openOrderHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(
          history: globalOrderHistory, 
        ),
      ),
    );
  }

  // ******************************
  // Widget Builder Methods
  // ******************************

  Widget _buildTableCard(TableStatus table) {
    final title = 'โต๊ะ ${table.name}';
    final itemCount = table.order?.items.fold(0, (sum, item) => sum + item.quantity) ?? 0;
    
    // การตรวจสอบสถานะการส่งครัว (ใช้ safeIsSentToKitchen)
    final bool isWaitingToSend = table.isOccupied && itemCount > 0 && table.order!.safeIsSentToKitchen == false;
    
    // ปรับคำบรรยายให้สอดคล้องกับสถานะ
    final subtitle = table.isOccupied 
        ? (itemCount > 0 
            ? (isWaitingToSend ? 'รอส่งครัว ($itemCount รายการ)' : 'กำลังปรุง ($itemCount รายการ)') 
            : 'ไม่ว่าง (รอสั่ง)') 
        : 'ว่าง';
        
    final statusIcon = table.isOccupied ? Icons.restaurant_menu_rounded : Icons.event_seat_rounded;
    final peopleIcon = table.isOccupied && table.peopleCount > 0 ? Icons.people_alt_rounded : null;
    
    // กำหนดสีขอบ Card ตามสถานะจริง
    Color cardBorderColor = table.statusColor;
    if (isWaitingToSend) {
        cardBorderColor = Colors.orange.shade700; // ใช้สีส้มสำหรับ รอส่งครัว
    }

    return Card(
      elevation: 2,
      color: _lightCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cardBorderColor.withOpacity(0.5), width: 1.5), 
      ),
      child: InkWell(
        onTap: () => _openOrderDetails(table), 
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _textColor, 
                      fontSize: 22, 
                      fontWeight: FontWeight.bold
                    ), 
                  ),
                  Icon(statusIcon, color: cardBorderColor, size: 30),
                ],
              ),
              const SizedBox(height: 10),
              
              Row(
                children: [
                  if (peopleIcon != null) ...[
                    Icon(peopleIcon, color: _secondaryTextColor, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${table.peopleCount}',
                      style: TextStyle(color: _secondaryTextColor, fontSize: 16),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: cardBorderColor, 
                      fontSize: 16,
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'ID: ${table.qrCode}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11), 
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emptyTables = _tables.where((t) => !t.isOccupied).length;
    
    // คำนวณสถานะตามตรรกะใหม่
    final occupiedWithOrderSent = _tables.where((t) => t.isOccupied && t.order?.items.isNotEmpty == true && t.order?.safeIsSentToKitchen == true).length;
    final occupiedWaiting = _tables.where((t) => t.isOccupied && t.order?.items.isNotEmpty == true && t.order?.safeIsSentToKitchen == false).length;

    return Scaffold(
      backgroundColor: _lightBackgroundColor, 
      appBar: AppBar(
        title: Text(
          'บริกร (Server View)', 
          style: TextStyle(
            color: _textColor, 
            fontWeight: FontWeight.bold,
            fontSize: 20,
          )
        ), 
        backgroundColor: _lightCardColor, 
        elevation: 0.5, 
        surfaceTintColor: Colors.transparent, 
        automaticallyImplyLeading: false, 
        actions: [
          // ปุ่มใหม่: ดูประวัติการชำระเงิน
          IconButton(
            icon: Icon(Icons.history_rounded, color: _primaryColor), 
            onPressed: _openOrderHistory,
            tooltip: 'ประวัติการชำระเงิน',
          ),
          IconButton(
            icon: Icon(Icons.logout_rounded, color: Colors.red.shade600), 
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst); 
            },
            tooltip: 'ออกจากระบบ',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // สรุปสถานะ
            Wrap(
              spacing: 10.0,
              runSpacing: 10.0,
              children: [
                _buildStatusChip(Icons.event_seat_rounded, 'ว่าง', emptyTables, Colors.green.shade600),
                _buildStatusChip(Icons.access_time_filled_rounded, 'รอส่งครัว', occupiedWaiting, Colors.orange.shade700),
                _buildStatusChip(Icons.shopping_cart_rounded, 'กำลังปรุง', occupiedWithOrderSent, Colors.red.shade600),
                _buildStatusChip(Icons.grid_on_rounded, 'ทั้งหมด', _tables.length, _primaryColor),
              ],
            ),
            const SizedBox(height: 20),
            
            Expanded(
              // Grid View แสดงสถานะโต๊ะทั้งหมด
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0, 
                ),
                itemCount: _tables.length,
                itemBuilder: (context, index) {
                  return _buildTableCard(_tables[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusChip(IconData icon, String label, int count, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 20),
      label: Text(
        '$label: $count',
        style: TextStyle(color: _textColor, fontWeight: FontWeight.w600), 
      ),
      backgroundColor: color.withOpacity(0.1), 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    );
  }
}