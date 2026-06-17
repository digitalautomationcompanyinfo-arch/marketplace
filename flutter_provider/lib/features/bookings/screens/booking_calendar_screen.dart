import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingCalendarScreen extends ConsumerStatefulWidget {
  const BookingCalendarScreen({super.key});

  @override
  ConsumerState<BookingCalendarScreen> createState() =>
      _BookingCalendarScreenState();
}

class _BookingCalendarScreenState extends ConsumerState<BookingCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _bookings = [
    {
      'id': 1,
      'customer': 'أحمد محمد',
      'time': '09:00',
      'status': 'confirmed',
      'notes': 'فحص دوري للمكيف'
    },
    {
      'id': 2,
      'customer': 'سارة إبراهيم',
      'time': '10:30',
      'status': 'pending',
      'notes': 'تركيب سخان جديد'
    },
    {
      'id': 3,
      'customer': 'خالد عبيد',
      'time': '14:00',
      'status': 'completed',
      'notes': ''
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('أجندة المواعيد'),
        backgroundColor: const Color(0xFF1A3C5E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _bookings.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(_bookings[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      color: Colors.white,
      child: SizedBox(
        height: 80,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 14, // 2 weeks
          itemBuilder: (context, i) {
            final date = DateTime.now().add(Duration(days: i));
            final isSelected = date.day == _selectedDate.day &&
                date.month == _selectedDate.month;
            return GestureDetector(
              onTap: () => setState(() => _selectedDate = date),
              child: Container(
                width: 60,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1A3C5E)
                        : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey[200]!)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_getDayName(date.weekday),
                        style: TextStyle(
                            color: isSelected ? Colors.white70 : Colors.grey,
                            fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(date.day.toString(),
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final statusColor = booking['status'] == 'confirmed'
        ? Colors.green
        : (booking['status'] == 'pending' ? Colors.orange : Colors.grey);
    final statusText = booking['status'] == 'confirmed'
        ? 'مؤكد'
        : (booking['status'] == 'pending' ? 'بانتظار التأكيد' : 'مكتمل');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFF8F9FA),
              child: Text(booking['time'],
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A3C5E))),
            ),
            title: Text(booking['customer'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                booking['notes'].isEmpty ? 'لا توجد ملاحظات' : booking['notes'],
                style: const TextStyle(fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8)),
              child: Text(statusText,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          if (booking['status'] == 'pending') ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white),
                      onPressed: () {},
                      child: const Text('تأكيد الموعد'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red)),
                      onPressed: () {},
                      child: const Text('إلغاء'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getDayName(int day) {
    switch (day) {
      case 1:
        return 'الاثنين';
      case 2:
        return 'الثلاثاء';
      case 3:
        return 'الأربعاء';
      case 4:
        return 'الخميس';
      case 5:
        return 'الجمعة';
      case 6:
        return 'السبت';
      case 7:
        return 'الأحد';
      default:
        return '';
    }
  }
}
