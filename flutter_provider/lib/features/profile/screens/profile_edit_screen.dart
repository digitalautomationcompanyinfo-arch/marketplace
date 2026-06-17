import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'مطعم البيت السعودي');
  final _phoneController = TextEditingController(text: '050xxxxxxx');
  final _descController = TextEditingController(
      text: 'أفضل الأكلات السعودية والمندي الطازج يومياً.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: const Text('الملف الشخصي والوثائق'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryLight,
                  child: Icon(Icons.store, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              const Text('المعلومات الأساسية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المتجر/المزود',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.storefront),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الجوال',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'وصف المتجر',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              const Text('الوثائق والتراخيص (مرفوعة)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildDocumentItem('السجل التجاري', 'ينتهي في 2027-10-15', true),
              _buildDocumentItem('الهوية الوطنية', 'مراجعة معتمدة', true),
              _buildDocumentItem('الشهادة الصحية', 'غير مرفقة', false),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('تم حفظ البيانات بنجاح ✅'),
                          backgroundColor: Colors.green),
                    );
                    context.pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('حفظ التغييرات',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentItem(String title, String status, bool isValid) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.description,
              color: isValid ? Colors.green : Colors.grey, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(status,
                    style: TextStyle(
                        color: isValid ? Colors.green : Colors.red,
                        fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: AppTheme.primaryLight),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
