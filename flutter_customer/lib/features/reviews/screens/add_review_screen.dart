import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/review_provider.dart';
import '../../../core/theme/app_theme.dart';

class AddReviewScreen extends ConsumerStatefulWidget {
  final String productUuid;
  final String productName;

  const AddReviewScreen(
      {super.key, required this.productUuid, required this.productName});

  @override
  ConsumerState<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends ConsumerState<AddReviewScreen> {
  int _rating = 5;
  final _commentCtrl = TextEditingController();
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null && _images.length < 3) {
      setState(() => _images.add(image));
    }
  }

  Future<void> _submit() async {
    if (_rating < 1) return;

    setState(() => _isSubmitting = true);
    try {
      // ملحوظة: في الواقع الصور يجب رفعها أولاً لـ Cloudinary والحصول على روابط
      // سنقوم هنا بإرسال الروابط كمصفوفة فارغة مؤقتاً أو محاكاة الرفع
      await ref.read(reviewProvider.notifier).addReview({
        'product_uuid': widget.productUuid,
        'rating': _rating,
        'comment': _commentCtrl.text,
        'images': [], // سيتم تطبيق الرفع الحقيقي في مرحلة لاحقة
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('شكراً لتقييمك! تم منحك 10 نقاط')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل إضافة التقييم: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة تقييم')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('كيف كانت تجربتك مع ${widget.productName}؟',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // Stars
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                    5,
                    (index) => IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 40,
                          ),
                          onPressed: () => setState(() => _rating = index + 1),
                        )),
              ),
            ),
            const SizedBox(height: 32),

            const Text('أضف تعليقك (اختياري)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب رأيك هنا...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            const Text('أضف صوراً للمنتج',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                ..._images.map((img) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                            image: FileImage(File(img.path)),
                            fit: BoxFit.cover),
                      ),
                    )),
                if (_images.length < 3)
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(Icons.add_a_photo, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال التقييم',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
