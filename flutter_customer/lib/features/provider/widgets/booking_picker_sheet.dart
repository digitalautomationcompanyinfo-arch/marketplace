import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';

class BookingPickerSheet extends ConsumerStatefulWidget {
  final String providerId;
  final String providerName;
  const BookingPickerSheet(
      {super.key, required this.providerId, required this.providerName});

  @override
  ConsumerState<BookingPickerSheet> createState() => _BookingPickerSheetState();
}

class _BookingPickerSheetState extends ConsumerState<BookingPickerSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlot;

  // Mock slots - in real app fetched from API
  final List<String> _slots = [
    '09:00 ص',
    '10:00 ص',
    '11:00 ص',
    '02:00 م',
    '03:00 م',
    '04:00 م'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
              child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)))),
          const SizedBox(height: 20),
          Text('حجز موعد لدى ${widget.providerName}',
              style: AppTheme.headingMd),
          const SizedBox(height: 20),
          const Text('اختر التاريخ:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildDatePicker(),
          const SizedBox(height: 24),
          const Text('اختر الوقت المتاح:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          _buildSlotGrid(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _selectedSlot == null ? null : () => _confirmBooking(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: const RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMd),
              ),
              child: const Text('تأكيد واحجز الآن',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 14,
        itemBuilder: (context, i) {
          final date = DateTime.now().add(Duration(days: i + 1));
          final isSelected = date.day == _selectedDate.day;
          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
            child: Container(
              width: 60,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey[200]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_getDayShortName(date.weekday),
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
    );
  }

  Widget _buildSlotGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _slots.map((slot) {
        final isSelected = _selectedSlot == slot;
        return GestureDetector(
          onTap: () => setState(() => _selectedSlot = slot),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.accentColor.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isSelected ? AppTheme.accentColor : Colors.grey[200]!),
            ),
            child: Text(
              slot,
              style: TextStyle(
                color: isSelected ? AppTheme.accentColor : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _confirmBooking() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال طلب حجزك لـ ${widget.providerName}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _getDayShortName(int day) {
    switch (day) {
      case 1:
        return 'اثنين';
      case 2:
        return 'ثلاثاء';
      case 3:
        return 'أربعاء';
      case 4:
        return 'خميس';
      case 5:
        return 'جمعة';
      case 6:
        return 'سبت';
      case 7:
        return 'أحد';
      default:
        return '';
    }
  }
}
