import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BranchesScreen extends ConsumerStatefulWidget {
  const BranchesScreen({super.key});

  @override
  ConsumerState<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends ConsumerState<BranchesScreen> {
  // Mock data for initial UI - will be replaced with API call
  final List<Map<String, dynamic>> _branches = [
    {
      'id': 1,
      'name': 'فرع الخرطوم - تقاطع القصر',
      'address': 'شارع القصر، عمارة البرير، الطابق الأرضي',
      'phone': '0123456789',
      'is_active': true,
      'distance': 'المقر الرئيسي'
    },
    {
      'id': 2,
      'name': 'فرع بحري - المؤسسة',
      'address': 'شارع المعونة، بجوار بنك الخرطوم',
      'phone': '0987654321',
      'is_active': true,
      'distance': '12 كم'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text('إدارة الفروع والامتيازات'),
        backgroundColor: const Color(0xFF1A3C5E),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_location_alt),
            onPressed: () => _showAddBranchSheet(),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _branches.length,
        itemBuilder: (context, index) {
          final branch = _branches[index];
          return _buildBranchCard(branch);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2980B9),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddBranchSheet(),
      ),
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ]),
      child: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFEBF5FB),
              child: Icon(Icons.location_on, color: Color(0xFF2980B9)),
            ),
            title: Text(branch['name'],
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle:
                Text(branch['address'], style: const TextStyle(fontSize: 12)),
            trailing: Switch(
              value: branch['is_active'],
              onChanged: (val) {},
              activeColor: const Color(0xFF2980B9),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionButton(Icons.edit, 'تعديل', Colors.blue, () {}),
                _buildActionButton(Icons.map, 'الخريطة', Colors.green, () {}),
                _buildActionButton(Icons.delete, 'حذف', Colors.red, () {}),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddBranchSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إضافة فرع جديد',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _buildTextField('اسم الفرع', 'مثال: فرع أم درمان - الشهداء'),
            const SizedBox(height: 16),
            _buildTextField('العنوان التفصيلي', 'وصف دقيق للموقع'),
            const SizedBox(height: 16),
            _buildTextField('رقم هاتف الفرع', 'اختياري'),
            const SizedBox(height: 24),
            Container(
              height: 150,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!)),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map, color: Colors.grey, size: 40),
                    Text('تحديد الموقع من الخريطة',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A3C5E),
                    shape: RoundedRectangle_circular(12)),
                onPressed: () => Navigator.pop(context),
                child: const Text('حفظ الفرع',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// Dummy helper as fix for likely typo in generated code if not careful
RoundedRectangleBorder RoundedRectangle_circular(double r) =>
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(r));
