import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// **********************************************
// 1. MODELS ที่ใช้ในหน้านี้ (ปรับปรุง)
// **********************************************

// เพิ่ม Enum สำหรับประเภทการชำระเงิน
enum PaymentType { cash, scan }

// โมเดลสำหรับรายการอาหารที่สั่ง (✨ เพิ่ม orderSource)
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

// โมเดลสำหรับ Order ที่ผูกกับโต๊ะ (✨ เพิ่ม tableName)
class TableOrder {
  final String orderId;
  final int tableId;
  final String tableName; // ✨ FIX: เพิ่ม tableName
  List<OrderItem> items;
  bool isPaid;
  bool isComplete;

  TableOrder({
    required this.orderId,
    required this.tableId,
    required this.tableName, // ✨ FIX: ต้องใส่ใน constructor
    required this.items,
    this.isPaid = false,
    this.isComplete = false,
  });
  
  // ฟังก์ชันช่วยในการ Copy
  TableOrder copyWith({
    List<OrderItem>? items,
    bool? isPaid,
    bool? isComplete,
  }) {
    return TableOrder(
      orderId: orderId,
      tableId: tableId,
      tableName: tableName, // tableName คงที่
      items: items ?? this.items,
      isPaid: isPaid ?? this.isPaid,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

// **********************************************
// 2. WIDGET ใหม่: PaymentScreen (จัดการการชำระเงินแยกส่วน)
// **********************************************
class PaymentScreen extends StatefulWidget {
  final TableOrder currentOrder;
  final Function(TableOrder) onOrderPaid; // Callback เพื่อส่ง Order ที่เหลือกลับไป

  const PaymentScreen({
    super.key,
    required this.currentOrder,
    required this.onOrderPaid,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // สถานะสำหรับการเลือกชำระเงิน
  late List<OrderItem> _tempItems; // Order Items ที่ใช้ในการเลือก
  PaymentType _selectedPaymentType = PaymentType.cash;
  Set<String> _selectedSources = {}; // เก็บ orderSource ที่ถูกเลือก (เพื่อจ่ายแยกบิล)

  @override
  void initState() {
    super.initState();
    _tempItems = List.from(widget.currentOrder.items);
    // เริ่มต้นเลือกรายการทั้งหมด
    _selectedSources.addAll(widget.currentOrder.items.map((e) => e.orderSource));
  }

  // กลุ่มรายการสั่งตาม orderSource
  Map<String, List<OrderItem>> _groupItemsBySource() {
    Map<String, List<OrderItem>> grouped = {};
    for (var item in _tempItems) {
      if (!grouped.containsKey(item.orderSource)) {
        grouped[item.orderSource] = [];
      }
      grouped[item.orderSource]!.add(item);
    }
    return grouped;
  }

  // การจัดการการเลือกกลุ่ม Order Source (จ่ายแยกบิลตามอุปกรณ์)
  void _toggleSourceSelection(String source) {
    setState(() {
      if (_selectedSources.contains(source)) {
        _selectedSources.remove(source);
      } else {
        _selectedSources.add(source);
      }
    });
  }

  // คำนวณยอดรวมที่เลือก
  double _calculateSelectedTotal() {
    // 1. คำนวณยอดรวมก่อน VAT
    final subtotal = _tempItems
        .where((item) => _selectedSources.contains(item.orderSource))
        .fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    // 2. คำนวณ VAT 7%
    final vat = subtotal * 0.07;
    return subtotal + vat;
  }

  // ฟังก์ชันดำเนินการชำระเงิน
  void _processPayment() {
    final total = _calculateSelectedTotal();
    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โปรดเลือรายการที่จะชำระเงิน')),
      );
      return;
    }

    // 1. รายการที่เหลือ
    final remainingItems = _tempItems
        .where((item) => !_selectedSources.contains(item.orderSource))
        .toList();

    // 2. สร้าง Order ใหม่
    TableOrder newOrder;
    if (remainingItems.isEmpty) {
      // ชำระเงินทั้งหมด -> ปิดบิล
      newOrder = widget.currentOrder.copyWith(items: remainingItems, isPaid: true, isComplete: true);
    } else {
      // ชำระเงินบางส่วน -> อัปเดตรายการที่เหลือ
      newOrder = widget.currentOrder.copyWith(items: remainingItems, isPaid: false, isComplete: false);
    }
    
    // แจ้งการอัปเดตกลับไปยัง OrderDetailScreen
    widget.onOrderPaid(newOrder);
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupItemsBySource();
    final total = _calculateSelectedTotal();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('ชำระเงิน: ${widget.currentOrder.tableName}', 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Divider(),

            // 1. ส่วนเลือกกลุ่ม Order Source (บิลย่อย)
            const Text('💡 เลือกกลุ่มบิลที่ต้องการชำระเงิน (จัดกลุ่มตาม Source)', 
              style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: groupedItems.keys.map((source) {
                final isSelected = _selectedSources.contains(source);
                return ActionChip(
                  label: Text('บิล: $source'),
                  backgroundColor: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
                  onPressed: () => _toggleSourceSelection(source),
                  side: isSelected ? const BorderSide(color: Colors.blue) : BorderSide.none,
                );
              }).toList(),
            ),
            const SizedBox(height: 15),

            // 2. รายการที่ถูกเลือก
            Expanded(
              child: ListView(
                children: [
                  ..._tempItems
                      .where((item) => _selectedSources.contains(item.orderSource))
                      .map((item) => ListTile(
                            title: Text('${item.name} x ${item.quantity}'),
                            subtitle: Text('บิล: ${item.orderSource}', style: const TextStyle(fontSize: 12)),
                            trailing: Text('${((item.price * item.quantity)*1.07).toStringAsFixed(2)} บาท'), // แสดงราคารวม VAT
                          ))
                      .toList(),
                  if (total == 0)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('โปรดเลือรายการที่จะชำระเงิน', style: TextStyle(color: Colors.red)),
                    )),
                ],
              ),
            ),

            // 3. ส่วนสรุปยอดและเลือกวิธีการชำระ
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'ยอดรวมสุทธิที่ต้องชำระ: ${total.toStringAsFixed(2)} บาท',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 16),
                  
                  // เลือกวิธีการชำระเงิน (เงินสด/สแกน)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ChoiceChip(
                        label: const Text('รับเงินสด 💵'),
                        selected: _selectedPaymentType == PaymentType.cash,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPaymentType = PaymentType.cash;
                          });
                        },
                        selectedColor: Colors.green[100],
                      ),
                      ChoiceChip(
                        label: const Text('สแกน QR 📲'),
                        selected: _selectedPaymentType == PaymentType.scan,
                        onSelected: (selected) {
                          setState(() {
                            _selectedPaymentType = PaymentType.scan;
                          });
                        },
                        selectedColor: Colors.blue[100],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // ปุ่มชำระเงิน
                  ElevatedButton(
                    onPressed: total > 0 ? _processPayment : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: total > 0 ? Colors.green : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      'ยืนยันชำระเงิน: (${_selectedPaymentType == PaymentType.cash ? "เงินสด" : "สแกน"})',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// **********************************************
// 3. WIDGET หลัก: OrderDetailScreen (แก้ไขฟังก์ชัน)
// **********************************************

class OrderDetailScreen extends StatefulWidget {
  final int tableId;
  final String tableName;
  final TableOrder? currentOrder; 
  final Function(TableOrder order) onOrderUpdated;

  const OrderDetailScreen({
    super.key,
    required this.tableId,
    required this.tableName,
    this.currentOrder,
    required this.onOrderUpdated,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> with TickerProviderStateMixin { 
  final Color _primaryColor = const Color(0xFF007AFF); 
  
  final Color _lightBackgroundColor = Colors.white;
  final Color _lightCardColor = Colors.white; 
  final Color _onLightBackground = Colors.black87; 
  final Color _secondaryTextColor = Colors.grey[700]!; 

  final Uuid _uuid = const Uuid(); 
  
  late TabController _tabController; 
  
  late TableOrder _order;
  late List<MenuItem> _fullMenu;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 1. จำลอง Menu ทั้งหมด
    _fullMenu = [
      MenuItem(name: 'เบอร์เกอร์เนื้อ', price: 120.0, category: 'Main'),
      MenuItem(name: 'ฟิช แอนด์ ชิปส์', price: 95.0, category: 'Main'),
      MenuItem(name: 'เฟรนช์ฟรายส์ใหญ่', price: 50.0, category: 'Side'),
      MenuItem(name: 'น้ำอัดลม', price: 35.0, category: 'Drink'),
      MenuItem(name: 'กาแฟเย็น', price: 60.0, category: 'Drink'),
      MenuItem(name: 'นักเก็ตไก่ (6 ชิ้น)', price: 80.0, category: 'Side'),
    ];

    // 2. กำหนด Order ปัจจุบัน
    if (widget.currentOrder != null) {
      _order = widget.currentOrder!;
    } else {
      _order = TableOrder(
        orderId: _uuid.v4(),
        tableId: widget.tableId,
        tableName: widget.tableName, // ✨ FIX: ส่ง tableName ที่ถูกเพิ่มเข้ามา
        items: [
          // ✨ เพิ่มรายการเริ่มต้นพร้อม Source จำลอง
          OrderItem(name: 'เบอร์เกอร์เนื้อ', price: 120.0, quantity: 1, orderSource: 'T${widget.tableId}-Waiter'),
          OrderItem(name: 'น้ำอัดลม', price: 35.0, quantity: 2, orderSource: 'T${widget.tableId}-DeviceA'),
          OrderItem(name: 'ฟิช แอนด์ ชิปส์', price: 95.0, quantity: 1, orderSource: 'T${widget.tableId}-DeviceA'),
          OrderItem(name: 'กาแฟเย็น', price: 60.0, quantity: 1, orderSource: 'T${widget.tableId}-DeviceB'),
        ],
      );
      // ส่ง Order ใหม่กลับไป WaiterScreen ทันทีที่มีการสร้าง
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateOrderCallback();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ******************************
  // การคำนวณยอดรวม
  // ******************************

  double get _subtotal { return _order.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity)); }
  double get _vat { return _subtotal * 0.07; }
  double get _grandTotal { return _subtotal + _vat; }

  // ******************************
  // ฟังก์ชันจัดการรายการอาหาร
  // ******************************

  void _addItemToOrder(MenuItem item) {
    setState(() {
      final existingItem = _order.items.firstWhere(
        (i) => i.name == item.name && i.orderSource == 'T${widget.tableId}-Waiter', // หาจากชื่อและ Source (Waiter)
        orElse: () => OrderItem(name: '', price: 0, orderSource: ''),
      );

      if (existingItem.name.isNotEmpty) {
        existingItem.quantity++;
      } else {
        // ✨ กำหนด orderSource เป็น 'T(tableId)-Waiter' สำหรับรายการที่เพิ่มผ่านหน้านี้
        _order.items.add(OrderItem(name: item.name, price: item.price, orderSource: 'T${widget.tableId}-Waiter'));
      }
      _updateOrderCallback();
    });
  }

  void _updateQuantity(OrderItem item, int change) {
    setState(() {
      item.quantity += change;
      if (item.quantity <= 0) {
        _order.items.remove(item);
      }
      _updateOrderCallback();
    });
  }
  
  void _updateOrderCallback() {
    widget.onOrderUpdated(_order);
  }

  // ******************************
  // ฟังก์ชันปิดบิล / ชำระเงิน (แก้ไขใหม่)
  // ******************************
  void _checkout() {
    _showPaymentSheet();
  }

  void _confirmPayment(TableOrder updatedOrder) {
    setState(() {
      _order = updatedOrder; // อัปเดต Order ด้วยรายการที่เหลือ
    });

    // แสดง SnackBar
    if (updatedOrder.isComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ชำระเงินและปิดบิลเรียบร้อยแล้ว'), backgroundColor: Colors.green),
        );
        _updateOrderCallback();
        Navigator.of(context).pop(); // ปิด OrderDetailScreen หากปิดบิลแล้ว
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ชำระเงินบางส่วนเรียบร้อยแล้ว'), backgroundColor: Colors.orange),
        );
        _updateOrderCallback();
    }
  }
  
  // ✨ สร้าง Payment Bottom Sheet ใหม่
  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return PaymentScreen(
          currentOrder: _order,
          onOrderPaid: (updatedOrder) {
            Navigator.of(context).pop(); // ปิด Bottom Sheet
            _confirmPayment(updatedOrder);
          },
        );
      },
    );
  }

  // ******************************
  // REFACTOR WIDGETS
  // ******************************

  Widget _buildOrderItem(OrderItem item) {
      return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _lightCardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), 
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(color: _onLightBackground, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  // ✨ แสดง Order Source
                  'Source: ${item.orderSource}', 
                  style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: Colors.red.shade600),
                onPressed: () => _updateQuantity(item, -1),
              ),
              Text(
                '${item.quantity}',
                style: TextStyle(color: _onLightBackground, fontSize: 16),
              ),
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: _primaryColor),
                onPressed: () => _updateQuantity(item, 1),
              ),
            ],
          ),
          
          SizedBox(
            width: 70,
            child: Text(
              '${(item.price * item.quantity).toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: TextStyle(color: _onLightBackground, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMenuButton(MenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, bottom: 10),
      child: ActionChip(
        avatar: Icon(Icons.add, color: _primaryColor),
        label: Text('${item.name} (${item.price.toStringAsFixed(0)})', style: TextStyle(color: _onLightBackground)),
        backgroundColor: _lightCardColor,
        onPressed: () => _addItemToOrder(item),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.withOpacity(0.5)), 
        ),
      ),
    );
  }
  
  Widget _buildTotalSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _lightCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildTotalRow('ยอดรวม (Subtotal)', _subtotal),
          _buildTotalRow('VAT (7%)', _vat, isTax: true),
          Divider(color: Colors.grey.shade300),
          _buildTotalRow('ยอดรวมสุทธิ', _grandTotal, isGrandTotal: true),
        ],
      ),
    );
  }
  
  Widget _buildTotalRow(String label, double amount, {bool isTax = false, bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isGrandTotal ? _onLightBackground : _secondaryTextColor,
              fontSize: isGrandTotal ? 18 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} บาท',
            style: TextStyle(
              color: isGrandTotal ? _primaryColor : _secondaryTextColor, 
              fontSize: isGrandTotal ? 18 : 14,
              fontWeight: isGrandTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderListPanel() {
    return Column(
      children: [
        Expanded(
          child: _order.items.isEmpty
              ? Center(
                  child: Text(
                    'ยังไม่มีรายการสั่ง.',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                )
              : ListView(
                  children: _order.items.map(_buildOrderItem).toList(),
                ),
        ),
        const SizedBox(height: 20),
        
        _buildTotalSummary(),
        const SizedBox(height: 20),
        
        ElevatedButton.icon(
          onPressed: _order.items.isEmpty ? null : _checkout, // 💡 เรียก _checkout() เพื่อเปิด Payment Sheet
          icon: const Icon(Icons.payment, color: Colors.white),
          label: Text(
            'ชำระเงิน / ปิดบิล (${_grandTotal.toStringAsFixed(2)} บาท)',
            style: const TextStyle(fontSize: 18),
          ),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),
            backgroundColor: _primaryColor, // ใช้สีหลัก
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMenuSelectionPanel() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: _lightBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'เลือกเมนู',
            style: TextStyle(color: _onLightBackground, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Divider(color: Colors.grey.shade300),
          
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                children: _fullMenu.map(_buildMenuButton).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ******************************
  // BUILD METHOD
  // ******************************
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletLayout = screenWidth > 800; 

    return Scaffold(
      backgroundColor: _lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'จัดการออร์เดอร์: ${widget.tableName}',
          style: TextStyle(color: _onLightBackground, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _lightBackgroundColor,
        iconTheme: IconThemeData(color: _onLightBackground), 
        elevation: 1, 
        bottom: isTabletLayout
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: _primaryColor,
                labelColor: _primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: '1. รายการที่สั่ง'),
                  Tab(text: '2. เพิ่มเมนู'),
                ],
              ),
      ),
      body: isTabletLayout
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildOrderListPanel(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildMenuSelectionPanel(),
                  ),
                ],
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildOrderListPanel(),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildMenuSelectionPanel(),
                ),
              ],
            ),
    );
  }
}