import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AvailabilitySettingsScreen extends ConsumerStatefulWidget {
  const AvailabilitySettingsScreen({super.key});

  @override
  ConsumerState<AvailabilitySettingsScreen> createState() =>
      _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState
    extends ConsumerState<AvailabilitySettingsScreen> {
  final List<String> _days = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد'
  ];
  final Map<String, List<String>> _schedules = {
    'الاثنين': ['09:00', '10:00', '11:00', '14:00', '15:00'],
    'الثلاثاء': ['09:00', '10:00', '11:00'],
    'الأربعاء': ['09:00', '10:00', '11:00', '14:00', '15:00'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('إعدادات التوفر والمواعيد'),
        backgroundColor: const Color(0xFF1A3C5E),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          final slots = _schedules[day] ?? [];
          return _buildDayCard(day, slots);
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A3C5E),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Text('حفظ الإعدادات',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildDayCard(String day, List<String> slots) {
    final isActive = slots.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
      child: ExpansionTile(
        leading: Icon(Icons.calendar_today,
            color: isActive ? const Color(0xFF2980B9) : Colors.grey),
        title: Text(day,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.black87 : Colors.grey)),
        subtitle: Text(
            isActive
                ? '${slots.length} خانات زمنية مبرمجة'
                : 'مغلق / لا توجد مواعيد',
            style: const TextStyle(fontSize: 12)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('الخانات الزمنية المتاحة:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...slots.map((s) => Chip(
                          label: Text(s),
                          backgroundColor: const Color(0xFFEBF5FB),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () {},
                        )),
                    ActionChip(
                      avatar:
                          const Icon(Icons.add, size: 16, color: Colors.white),
                      label: const Text('إضافة وقت',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      backgroundColor: const Color(0xFF2980B9),
                      onPressed: () => _showAddTimePicker(day),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTimePicker(String day) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        final timeStr =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        _schedules.putIfAbsent(day, () => []).add(timeStr);
        _schedules[day]!.sort();
      });
    }
  }
}
