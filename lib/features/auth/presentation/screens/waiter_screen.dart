import 'package:flutter/material.dart';
// 1. IMPORT หน้าจอจัดการออร์เดอร์และ Models
import 'order_detail_screen.dart'; 

// โมเดลสำหรับสถานะโต๊ะ (ใช้ TableStatus เดิม แต่เพิ่ม Order เข้าไป)
class TableStatus {
  final int id;
  final String name;
  final bool isOccupied;
  final int peopleCount;
  final String qrCode; 
  final TableOrder? order; // <<-- เพิ่ม Order object
  final Color statusColor;

  TableStatus({
    required this.id,
    required this.name,
    required this.isOccupied,
    this.peopleCount = 0,
    required this.qrCode,
    this.order, // <<-- เพิ่ม order ใน constructor
    required this.statusColor,
  });
  
  // ฟังก์ชันช่วยในการ Copy (เพื่อให้ง่ายต่อการอัปเดตสถานะใน setState)
  TableStatus copyWith({
    bool? isOccupied,
    int? peopleCount,
    TableOrder? order,
    Color? statusColor,
  }) {
    return TableStatus(
      id: id,
      name: name,
      qrCode: qrCode,
      isOccupied: isOccupied ?? this.isOccupied,
      peopleCount: peopleCount ?? this.peopleCount,
      order: order,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}

// หน้าจอหลักสำหรับบริกร (Waiter/Server)
class WaiterScreen extends StatefulWidget {
  const WaiterScreen({super.key});

  @override
  State<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> {
  final Color _primaryColor = const Color(0xFF007AFF);
  final Color _darkBackgroundColor = const Color(0xFF121212);
  final Color _darkCardColor = const Color(0xFF1E1E1E);

  // สถานะโต๊ะจำลอง (ปรับให้ใช้ Order object เป็น Null)
  List<TableStatus> _tables = [
    TableStatus(id: 1, name: 'T1', isOccupied: false, qrCode: 'FASTFOOD-T1', statusColor: Colors.green),
    TableStatus(id: 2, name: 'T2', isOccupied: true, peopleCount: 2, qrCode: 'FASTFOOD-T2', statusColor: Colors.red),
    TableStatus(id: 3, name: 'T3', isOccupied: false, peopleCount: 0, qrCode: 'FASTFOOD-T3', statusColor: Colors.green),
    TableStatus(id: 4, name: 'T4', isOccupied: false, qrCode: 'FASTFOOD-T4', statusColor: Colors.green),
    TableStatus(id: 5, name: 'T5', isOccupied: true, peopleCount: 1, qrCode: 'FASTFOOD-T5', statusColor: Colors.red),
    TableStatus(id: 6, name: 'T6', isOccupied: false, qrCode: 'FASTFOOD-T6', statusColor: Colors.green),
    TableStatus(id: 7, name: 'T7', isOccupied: false, qrCode: 'FASTFOOD-T7', statusColor: Colors.green),
    TableStatus(id: 8, name: 'T8', isOccupied: true, peopleCount: 3, qrCode: 'FASTFOOD-T8', statusColor: Colors.red),
  ];

  // ******************************
  // ฟังก์ชันจัดการ Order ใหม่
  // ******************************
  
  // ฟังก์ชันจัดการเมื่อ Order มีการเปลี่ยนแปลง
  void _handleOrderUpdate(int tableId, TableOrder newOrder) {
    setState(() {
      final index = _tables.indexWhere((table) => table.id == tableId);
      if (index != -1) {
        
        Color newStatusColor = Colors.green; 
        bool isOccupied = newOrder.items.isNotEmpty || !newOrder.isComplete;
        
        // กำหนดสีตามสถานะใหม่
        if (newOrder.items.isNotEmpty && !newOrder.isComplete) {
            newStatusColor = Colors.red; // ไม่ว่าง มีรายการสั่ง
        } else if (newOrder.isComplete) {
            // โต๊ะว่างทันที (ปิดบิลแล้ว)
            newStatusColor = Colors.green;
            isOccupied = false;
        }

        // อัปเดต TableStatus
        _tables[index] = _tables[index].copyWith(
          isOccupied: isOccupied,
          peopleCount: isOccupied ? (_tables[index].peopleCount > 0 ? _tables[index].peopleCount : 1) : 0, // ถ้าไม่ว่างแต่ไม่มีคนให้เป็น 1
          order: newOrder.isComplete ? null : newOrder, // ล้าง Order ถ้าปิดบิลแล้ว
          statusColor: newStatusColor,
        );
      }
    });
  }

  // ฟังก์ชันเปิดหน้า OrderDetailScreen
  void _openOrderDetails(TableStatus table) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(
          tableId: table.id,
          tableName: table.name,
          currentOrder: table.order, // ส่ง Order ที่มีอยู่ไป
          onOrderUpdated: (updatedOrder) => _handleOrderUpdate(table.id, updatedOrder),
        ),
      ),
    );
  }

  // ******************************
  // Widget Builder Methods
  // ******************************

  // Widget แสดงสถานะโต๊ะ (แก้ไข onTap)
  Widget _buildTableCard(TableStatus table) {
    final title = 'โต๊ะ ${table.name}';
    final itemCount = table.order?.items.fold(0, (sum, item) => sum + item.quantity) ?? 0;
    
    final subtitle = table.isOccupied 
        ? (itemCount > 0 ? 'มี ${itemCount} รายการ' : 'ไม่ว่าง (รอสั่ง)') 
        : 'ว่าง';
        
    final statusIcon = table.isOccupied ? Icons.fastfood : Icons.check_circle_outline;

    return InkWell(
      // *** เปลี่ยน onTap ให้เรียก _openOrderDetails แทน _toggleTableStatus ***
      onTap: () => _openOrderDetails(table), 
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: _darkCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: table.statusColor, width: 2),
        ),
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
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(statusIcon, color: table.statusColor, size: 30),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: table.statusColor, fontSize: 16),
            ),
            const Spacer(),
            // ส่วนแสดง QR Code (จำลอง)
            Text(
              'QR ID: ${table.qrCode}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // นับจำนวนโต๊ะว่าง/ไม่ว่าง
    final emptyTables = _tables.where((t) => !t.isOccupied).length;
    final occupiedTables = _tables.length - emptyTables;

    return Scaffold(
      backgroundColor: _darkBackgroundColor,
      appBar: AppBar(
        title: const Text('บริกร (Server View)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: _darkBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.grey[400]),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst); 
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // สรุปสถานะ
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusChip(Icons.event_seat, 'ว่าง', emptyTables, Colors.green),
                _buildStatusChip(Icons.person, 'ไม่ว่าง', occupiedTables, Colors.red),
                _buildStatusChip(Icons.grid_on, 'ทั้งหมด', _tables.length, _primaryColor),
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
  
  // Widget สำหรับแสดงสรุปสถานะ
  Widget _buildStatusChip(IconData icon, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _darkCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$label: $count',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}