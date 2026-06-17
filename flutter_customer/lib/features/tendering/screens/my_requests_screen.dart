import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/socket_service.dart';
import '../../../../core/theme/app_theme.dart';

class MyRequestsScreen extends ConsumerStatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  ConsumerState<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends ConsumerState<MyRequestsScreen> {
  bool _isLoading = true;
  List _requests = [];
  StreamSubscription? _socketSub;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupSocket();
  }

  void _setupSocket() {
    final socketService = ref.read(socketServiceProvider);
    _socketSub = socketService.tenderingUpdates.listen((event) {
      if (event['type'] == 'new_bid') {
        _loadData(); // Refresh list to get new bid count
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(event['message'] ?? 'تحذير: عرض جديد وصل لمناقصتك!'),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final res = await ApiService.instance.getMyServiceRequests();
      if (res['success']) setState(() => _requests = res['data']);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلباتي الخاصة (المناقصات)')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _requests.isEmpty
                  ? const Center(child: Text('لا توجد طلبات سابقة'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _requests.length,
                      itemBuilder: (context, index) {
                        final req = _requests[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            title: Text(req['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text(
                                '${req['category_name']} • ${req['status']}'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('${req['bids_count']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.blue)),
                                const Text('عروض',
                                    style: TextStyle(fontSize: 10)),
                              ],
                            ),
                            onTap: () => _showBids(req),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  void _showBids(Map request) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BidsListModal(request: request),
    );
  }
}

class _BidsListModal extends StatefulWidget {
  final Map request;
  const _BidsListModal({required this.request});

  @override
  State<_BidsListModal> createState() => _BidsListModalState();
}

class _BidsListModalState extends State<_BidsListModal> {
  bool _loading = true;
  List _bids = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    final res = await ApiService.instance.getRequestBids(widget.request['id']);
    if (res['success'])
      setState(() {
        _bids = res['data'];
        _loading = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.all(20),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Text('عروض المزودين للطلب: ${widget.request['title']}',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 30),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _bids.isEmpty
                    ? const Center(child: Text('لم يتم تقديم أي عروض بعد'))
                    : ListView.builder(
                        itemCount: _bids.length,
                        itemBuilder: (context, i) {
                          final bid = _bids[i];
                          return Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                  backgroundImage: bid['logo_url'] != null
                                      ? NetworkImage(bid['logo_url'])
                                      : null),
                              title: Text(bid['business_name']),
                              subtitle: Text(
                                  'خلال ${bid['estimated_days']} أيام • ${bid['notes'] ?? ""}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${bid['amount']} ج.س',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green)),
                                  if (widget.request['status'] == 'open')
                                    TextButton(
                                      onPressed: () => _accept(bid),
                                      child: const Text('قبول'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _accept(Map bid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('قبول العرض'),
        content: Text(
            'هل أنت متأكد من قبول عرض ${bid['business_name']} بمبلغ ${bid['amount']} ج.س؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('قبول')),
        ],
      ),
    );

    if (confirm == true) {
      final res = await ApiService.instance.acceptBid(bid['id']);
      if (res['success'] && mounted) {
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(const SnackBar(
            content: Text('تم قبول العرض! يمكنك التواصل مع المزود الآن')));
      }
    }
  }
}
