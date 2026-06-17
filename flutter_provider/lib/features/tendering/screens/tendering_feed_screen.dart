import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/network/socket_service.dart';
import '../../../../core/theme/app_theme.dart';

class TenderingFeedScreen extends ConsumerStatefulWidget {
  const TenderingFeedScreen({super.key});

  @override
  ConsumerState<TenderingFeedScreen> createState() =>
      _TenderingFeedScreenState();
}

class _TenderingFeedScreenState extends ConsumerState<TenderingFeedScreen> {
  bool _isLoading = true;
  List _requests = [];
  StreamSubscription? _socketSub;

  @override
  void initState() {
    super.initState();
    _loadFeed();
    _setupSocket();
  }

  void _setupSocket() {
    _socketSub =
        ref.read(socketServiceProvider).tenderingEvents.listen((event) {
      if (mounted) {
        _loadFeed();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event['message'] ?? 'تنبيه: تم تحديث حالة المناقصة!'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.instance.getPublicRequests();
      if (res['success']) {
        setState(() => _requests = res['data']);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فرص العمل المتاحة (المناقصات)')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: _requests.isEmpty
                  ? const Center(child: Text('لا توجد طلبات عامة حالياً'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final req = _requests[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Chip(
                                        label: Text(
                                            req['category_name'] ?? 'عام')),
                                    Text(
                                        '${req['budget_min']} - ${req['budget_max']} ج.س',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(req['title'],
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(req['description'],
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(req['customer_name'],
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                    const Spacer(),
                                    ElevatedButton(
                                      onPressed: () => _showSubmitBid(req),
                                      child: const Text('تقديم عرض سعر'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _showSubmitBid(Map request) {
    showDialog(
      context: context,
      builder: (context) =>
          _SubmitBidDialog(request: request, onComplete: _loadFeed),
    );
  }
}

class _SubmitBidDialog extends StatefulWidget {
  final Map request;
  final VoidCallback onComplete;
  const _SubmitBidDialog({required this.request, required this.onComplete});

  @override
  State<_SubmitBidDialog> createState() => _SubmitBidDialogState();
}

class _SubmitBidDialogState extends State<_SubmitBidDialog> {
  final _amountController = TextEditingController();
  final _daysController = TextEditingController();
  final _notesController = TextEditingController();
  bool _submitting = false;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      final res = await ApiService.instance.submitBid({
        'request_id': widget.request['id'],
        'amount': double.parse(_amountController.text),
        'estimated_days': int.parse(_daysController.text),
        'notes': _notesController.text,
      });

      if (res['success'] && mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        widget.onComplete();
        messenger.showSnackBar(
            const SnackBar(content: Text('تم تقديم عرضك بنجاح!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('تقديم عرض سعر'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'سعر العرض (ج.س)'),
            ),
            TextField(
              controller: _daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: 'مدة التنفيذ المتوقعة (أيام)'),
            ),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'ملاحظات إضافية'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('إرسال العرض'),
        ),
      ],
    );
  }
}
