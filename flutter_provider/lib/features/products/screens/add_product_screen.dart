import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/network/api_service.dart';
import 'dart:io';
import 'dart:convert';
import '../providers/products_provider.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final ProviderProduct? initialProduct;
  const AddProductScreen({super.key, this.initialProduct});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _name     = TextEditingController();
  final _desc     = TextEditingController();
  final _price    = TextEditingController();
  final _barcode  = TextEditingController();
  final _attrKey  = TextEditingController();
  final _attrValues = TextEditingController();

  final Map<String, List<String>> _attributes = {};

  File? _mainImage;
  final List<File> _extraImages = [];
  bool _isScanning  = false;
  bool _isLoading   = false;
  bool _isAvailable = true;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      final p = widget.initialProduct!;
      _name.text = p.name;
      _desc.text = p.description;
      _price.text = p.price;
      _barcode.text = p.barcode ?? '';
      _isAvailable = p.isAvailable;
      _selectedCategory = p.categoryId?.toString();
      _attributes.addAll(p.attributes.map((k, v) => MapEntry(k, List<String>.from(v))));
    }
  }

  // ─── مسح الباركود ────────────────────────────────────
  void _openScanner() {
    setState(() => _isScanning = true);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Stack(children: [
          MobileScanner(
            onDetect: (capture) async {
              final barcode = capture.barcodes.firstOrNull?.rawValue;
              if (barcode == null) return;
              Navigator.pop(context);
              await _lookupBarcode(barcode);
            },
          ),
          // إطار المسح
          Center(
            child: Container(
              width: 250, height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          Positioned(
            top: 16, left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () { Navigator.pop(context); setState(() => _isScanning = false); },
            ),
          ),
          const Positioned(
            bottom: 24, left: 0, right: 0,
            child: Text('وجّه الكاميرا نحو الباركود', textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ]),
      ),
    );
  }

  // ─── البحث عن بيانات الباركود من API ────────────────
  Future<void> _lookupBarcode(String code) async {
    setState(() { _isLoading = true; _barcode.text = code; });
    try {
      // TODO: استبدل بـ Dio call حقيقي
      // final response = await apiService.get('/products/barcode/$code');
      // if (response.data['source'] != 'not_found') {
      //   _name.text = response.data['data']['name'] ?? '';
      //   _desc.text = response.data['data']['description'] ?? '';
      // }
      await Future.delayed(const Duration(seconds: 1)); // محاكاة
      _name.text = 'منتج تجريبي من الباركود';
      _desc.text = 'وصف تلقائي من قاعدة البيانات';
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم تحميل بيانات المنتج تلقائياً'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لم يُعثر على المنتج: $code — أدخل البيانات يدوياً'), backgroundColor: Colors.orange),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── اختيار صور ──────────────────────────────────────
  Future<void> _pickMainImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) setState(() => _mainImage = File(picked.path));
  }

  Future<void> _pickExtraImages() async {
    final picked = await ImagePicker().pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        _extraImages.addAll(picked.take(10 - _extraImages.length).map((x) => File(x.path)));
      });
    }
  }

  // ─── ترجمة الوصف ذكائياً ─────────────────────────────
  Future<void> _translateDescription() async {
    if (_desc.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.instance.translate(_desc.text);
      if (res['success'] == true) {
        setState(() => _desc.text = res['data']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✨ تمت الترجمة بذكاء اصطناعي'), backgroundColor: Colors.blue),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ في الترجمة: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ─── حفظ المنتج ──────────────────────────────────────
    final formData = FormData.fromMap({
      'name': _name.text.trim(),
      'description': _desc.text.trim(),
      'price': _price.text.trim(),
      'barcode': _barcode.text.trim(),
      'is_available': _isAvailable,
      'category_id': _selectedCategory,
      'attributes': json.encode(_attributes),
    });

    if (_mainImage != null) {
      formData.files.add(MapEntry('main_image', await MultipartFile.fromFile(_mainImage!.path)));
    }
    for (var file in _extraImages) {
      formData.files.add(MapEntry('images', await MultipartFile.fromFile(file.path)));
    }

    try {
      if (widget.initialProduct != null) {
        await ApiService.instance.updateProduct(widget.initialProduct!.id, formData);
      } else {
        await ApiService.instance.createProduct(formData);
      }
      
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.initialProduct != null ? '✅ تم تحديث المنتج بنجاح' : '✅ تم إضافة المنتج بنجاح'),
            backgroundColor: Colors.green
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addAttribute() {
    if (_attrKey.text.isEmpty || _attrValues.text.isEmpty) return;
    final values = _attrValues.text.split(',').map((v) => v.trim()).where((v) => v.isNotEmpty).toList();
    if (values.isEmpty) return;
    
    setState(() {
      _attributes[_attrKey.text.trim()] = values;
      _attrKey.clear();
      _attrValues.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(widget.initialProduct != null ? 'تعديل المنتج' : 'إضافة منتج جديد'),
        backgroundColor: const Color(0xFF1A3C5E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [

                  // ─── زر مسح الباركود ─────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF2980B9), width: 1.5),
                    ),
                    child: Row(children: [
                      const Icon(Icons.qr_code_scanner, color: Color(0xFF2980B9), size: 40),
                      const SizedBox(width: 12),
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('مسح الباركود', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('وفّر وقتك — حمّل بيانات المنتج تلقائياً', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ])),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2980B9), foregroundColor: Colors.white),
                        onPressed: _openScanner,
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: const Text('مسح'),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 20),

                  // ─── الصورة الرئيسية ──────────────────
                  const Text('الصورة الرئيسية *', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickMainImage,
                    child: Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        image: _mainImage != null
                            ? DecorationImage(image: FileImage(_mainImage!), fit: BoxFit.cover)
                            : null,
                      ),
                      child: _mainImage == null
                          ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                              Text('اضغط لإضافة صورة', style: TextStyle(color: Colors.grey)),
                            ])
                          : null,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── حقول النموذج ────────────────────
                  _buildCard(children: [
                    _field(_name,  'اسم المنتج *', required: true),
                    const SizedBox(height: 12),
                    Stack(children: [
                      _field(_desc,  'الوصف', maxLines: 4),
                      Positioned(
                        left: 8, bottom: 8,
                        child: TextButton.icon(
                          onPressed: _translateDescription,
                          icon: const Icon(Icons.translate, size: 14, color: Colors.blue),
                          label: const Text('ترجمة ذكية', style: TextStyle(fontSize: 11, color: Colors.blue)),
                          style: TextButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.05)),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    _field(_price, 'السعر (SDG)', keyboardType: TextInputType.number),
                    const SizedBox(height: 12),
                    _field(_barcode, 'باركود (اختياري)'),
                  ]),

                  const SizedBox(height: 16),

                  // ─── التوفر ───────────────────────────
                  _buildCard(children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('متوفر للبيع'),
                      subtitle: Text(_isAvailable ? 'المنتج ظاهر للعملاء' : 'المنتج مخفي مؤقتاً'),
                      value: _isAvailable,
                      activeColor: const Color(0xFF27AE60),
                      onChanged: (v) => setState(() => _isAvailable = v),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  // ─── صور إضافية ───────────────────────
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('صور إضافية (حتى 10)', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextButton.icon(onPressed: _pickExtraImages, icon: const Icon(Icons.add), label: const Text('إضافة')),
                  ]),
                  if (_extraImages.isNotEmpty)
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _extraImages.length,
                        itemBuilder: (_, i) => Stack(children: [
                          Container(
                            width: 85, height: 85,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(image: FileImage(_extraImages[i]), fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(top: 0, right: 0, child: GestureDetector(
                            onTap: () => setState(() => _extraImages.removeAt(i)),
                            child: Container(
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          )),
                        ]),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ─── خصائص المنتج (Variations) ───────
                  _buildCard(children: [
                    const Text('خصائص المنتج (مثلاً: المقاس، اللون)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: _field(_attrKey, 'الخاصية (مثلاً: المقياس)')),
                      const SizedBox(width: 8),
                      Expanded(child: _field(_attrValues, 'القيم (فواصل ,)')),
                      IconButton(onPressed: _addAttribute, icon: const Icon(Icons.add_circle, color: Colors.blue)),
                    ]),
                    if (_attributes.isNotEmpty) ...[
                      const Divider(height: 24),
                      ..._attributes.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(e.value.join(', '), style: const TextStyle(fontSize: 12))),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                            onPressed: () => setState(() => _attributes.remove(e.key)),
                          ),
                        ]),
                      )).toList(),
                    ],
                  ]),

                  const SizedBox(height: 24),

                  // ─── زر الحفظ ─────────────────────────
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A3C5E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveProduct,
                      child: const Text('حفظ المنتج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildCard({required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false, int maxLines = 1, TextInputType? keyboardType}) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        validator: required ? (v) => (v == null || v.isEmpty) ? '$label مطلوب' : null : null,
      );
}

