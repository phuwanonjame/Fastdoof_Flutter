import 'package:flutter/material.dart';
import '../../../../models/order_models.dart';
import 'order_detail_screen.dart';
import 'order_history_screen.dart';

class WaiterScreen extends StatefulWidget {
  const WaiterScreen({super.key});

  @override
  State<WaiterScreen> createState() => _WaiterScreenState();
}

class _WaiterScreenState extends State<WaiterScreen> {
  final Color _primaryColor = const Color(0xFF007AFF); // CI น้ำเงิน
  final Color _lightBackgroundColor = const Color(0xFFFAFAFA);
  final Color _lightCardColor = const Color(0xFFFFFFFF);
  final Color _textColor = const Color(0xFF1F1F1F);
  final Color _secondaryTextColor = const Color(0xFF757575);

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

  void _handleOrderUpdate(int tableId, TableOrder newOrder) {
    setState(() {
      final index = _tables.indexWhere((table) => table.id == tableId);
      if (index != -1) {
        final bool isOccupied = newOrder.items.isNotEmpty;
        Color newStatusColor = Colors.green.shade600;
        if (isOccupied) {
          if (newOrder.safeIsSentToKitchen) {
            newStatusColor = Colors.red.shade600;
          } else {
            newStatusColor = Colors.red.shade600;
          }
        }
        if (newOrder.isComplete && newOrder.items.isEmpty) {
          newStatusColor = Colors.green.shade600;
        }
        _tables[index] = _tables[index].copyWith(
          isOccupied: isOccupied,
          peopleCount: isOccupied ? (_tables[index].peopleCount > 0 ? _tables[index].peopleCount : 1) : 0,
          order: isOccupied ? newOrder : null,
          statusColor: newStatusColor,
        );
      }
    });
  }

  void _openOrderDetails(TableStatus table) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(
          tableId: table.id,
          tableName: table.name,
          tableQrCode: table.qrCode,
          currentOrder: table.order,
          onOrderUpdated: (updatedOrder) => _handleOrderUpdate(table.id, updatedOrder),
        ),
      ),
    );
  }

  void _openOrderHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(history: globalOrderHistory),
      ),
    );
  }

  Widget _buildTableCard(TableStatus table) {
    final title = 'โต๊ะ ${table.name}';
    final itemCount = table.order?.items.fold(0, (sum, item) => sum + item.quantity) ?? 0;
    final bool isWaitingToSend = table.isOccupied && itemCount > 0 && table.order!.safeIsSentToKitchen == false;
    final subtitle = table.isOccupied
        ? (itemCount > 0
            ? (isWaitingToSend ? 'รอส่งครัว ($itemCount รายการ)' : 'กำลังปรุง ($itemCount รายการ)')
            : 'ไม่ว่าง (รอสั่ง)')
        : 'ว่าง';

    final statusIcon = table.isOccupied ? Icons.restaurant_menu_rounded : Icons.event_seat_rounded;
    final peopleIcon = table.isOccupied && table.peopleCount > 0 ? Icons.people_alt_rounded : null;
    Color cardBorderColor = table.statusColor;
    if (isWaitingToSend) {
      cardBorderColor = Colors.orange.shade700;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _lightCardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: cardBorderColor.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: cardBorderColor.withOpacity(0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: () => _openOrderDetails(table),
        borderRadius: BorderRadius.circular(20),
        splashColor: cardBorderColor.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(statusIcon, color: cardBorderColor, size: 50),
              Text(
                title,
                style: TextStyle(
                  color: _textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: cardBorderColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (peopleIcon != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(peopleIcon, color: _secondaryTextColor, size: 18),
                    const SizedBox(width: 5),
                    Text('${table.peopleCount}', style: TextStyle(color: _secondaryTextColor, fontSize: 14)),
                  ],
                ),
              const SizedBox(height: 6),
              Text(
                'ID: ${table.qrCode}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
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
    final occupiedWithOrderSent = _tables.where((t) => t.isOccupied && t.order?.items.isNotEmpty == true && t.order?.safeIsSentToKitchen == true).length;
    final occupiedWaiting = _tables.where((t) => t.isOccupied && t.order?.items.isNotEmpty == true && t.order?.safeIsSentToKitchen == false).length;

    return Scaffold(
      backgroundColor: _lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'บริกร (Server View)',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF005BB5), Color(0xFF4DA6FF)], // น้ำเงินเข้ม -> น้ำเงินอ่อน
            ),
          ),
        ),
        elevation: 4,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: _openOrderHistory,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.95,
              ),
              itemCount: _tables.length,
              itemBuilder: (context, index) {
                return _buildTableCard(_tables[index]);
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.5), width: 1.2),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(
          '$label: $count',
          style: TextStyle(
            color: _textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ]),
    );
  }
}
