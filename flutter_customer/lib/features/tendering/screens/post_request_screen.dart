import 'package:flutter/material.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/theme/app_theme.dart';

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  int? _selectedCategoryId;
  bool _isLoading = false;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final res = await ApiService.instance.get('/categories');
      if (res['success']) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(res['data']);
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('يرجى اختيار الفئة')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final min = double.tryParse(_minBudgetController.text) ?? 0;
      final max = double.tryParse(_maxBudgetController.text) ?? 0;

      if (min <= 0) {
        throw 'الميزانية الدنيا يجب أن تكون أكبر من صفر';
      }
      if (max < min) {
        throw 'الميزانية القصوى لا يمكن أن تكون أصغر من الدنيا';
      }

      final res = await ApiService.instance.createServiceRequest({
        'category_id': _selectedCategoryId,
        'title': _titleController.text,
        'description': _descController.text,
        'budget_min': min,
        'budget_max': max,
      });

      if (res['success'] && mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(const SnackBar(content: Text('تم نشر طلبك بنجاح!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اطلب خدمة مخصصة (مناقصة)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                  'ما الذي تحتاجه؟ سنقوم بإرسال طلبك للمزودين لتقديم عروضهم',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 24),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'فئة الخدمة',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem<int>(
                          value: c['id'],
                          child: Text(c['name']),
                        ))
                    .toList(),
                onChanged: _categories.isEmpty
                    ? null
                    : (v) => setState(() => _selectedCategoryId = v),
                hint: _categories.isEmpty
                    ? const Text('جاري تحميل الفئات...')
                    : const Text('اختر فئة'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'عنوان الطلب (مثلا: تصليح مكيف بصورة عاجلة)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'يرجى إدخال العنوان' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'تفاصيل الطلب',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? 'يرجى إدخال التفاصيل' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minBudgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'أدنى ميزانية (ج.س)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _maxBudgetController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'أعلى ميزانية (ج.س)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('نشر الطلب الآن'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
