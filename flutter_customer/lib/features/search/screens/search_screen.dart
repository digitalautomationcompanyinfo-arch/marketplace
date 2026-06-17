import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _selectedCategory = '';
  double _selectedRating = 0;
  double _selectedRadius = 20;
  bool _openNow = false;
  bool _showFilters = false;
  List<String> _suggestions = [];
  List<String> _trending = ['مطاعم', 'صيدليات', 'سباكة', 'حلاقة', 'كهرباء'];
  List<String> _recentSearches = ['مطعم البيك', 'صيدلية النيل'];

  void _onSearchChanged(String q) {
    if (q.length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    // FIX M2: Sudan-specific local context suggestions
    setState(() => _suggestions = [
          '$q في الخرطوم',
          '$q في أم درمان',
          '$q في بحري',
          '$q في بورتسودان'
        ]);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A3C5E),
        title: TextField(
          controller: _ctrl,
          focusNode: _focus,
          autofocus: true,
          textDirection: TextDirection.rtl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'ابحث عن خدمة أو منتج...',
            hintStyle: const TextStyle(color: Colors.white60),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            suffixIcon: _ctrl.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() => _suggestions = []);
                    })
                : null,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: (q) => _doSearch(q),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune,
                color: _showFilters ? Colors.amber : Colors.white),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Column(children: [
        if (_showFilters)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Text('مفتوح الآن فقط',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                const Spacer(),
                Switch(
                    value: _openNow,
                    onChanged: (v) => setState(() => _openNow = v),
                    activeColor: const Color(0xFF27AE60)),
              ]),
              const Text('الحد الأدنى للتقييم',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Row(
                  children: List.generate(
                      5,
                      (i) => GestureDetector(
                            onTap: () => setState(
                                () => _selectedRating = (i + 1).toDouble()),
                            child: Icon(Icons.star,
                                size: 30,
                                color: i < _selectedRating
                                    ? Colors.amber
                                    : Colors.grey[300]),
                          ))),
              const SizedBox(height: 8),
              Row(children: [
                const Text('نطاق البحث: ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_selectedRadius.toInt()} كم',
                    style: const TextStyle(
                        color: Color(0xFF2980B9), fontWeight: FontWeight.bold)),
              ]),
              Slider(
                value: _selectedRadius,
                min: 1,
                max: 100,
                divisions: 20,
                activeColor: const Color(0xFF2980B9),
                onChanged: (v) => setState(() => _selectedRadius = v),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3C5E),
                      foregroundColor: Colors.white),
                  onPressed: () {
                    setState(() => _showFilters = false);
                    _doSearch(_ctrl.text);
                  },
                  child: const Text('تطبيق الفلاتر'),
                ),
              ),
            ]),
          ),
        if (_suggestions.isNotEmpty)
          Container(
            color: Colors.white,
            child: Column(
                children: _suggestions
                    .map((s) => ListTile(
                          leading: const Icon(Icons.search, color: Colors.grey),
                          title: Text(s),
                          onTap: () {
                            _ctrl.text = s;
                            _doSearch(s);
                          },
                        ))
                    .toList()),
          ),
        Expanded(
          child: searchState.when(
            data: (results) => _ctrl.text.isEmpty && results.isEmpty
                ? _buildDiscovery()
                : _buildResults(results),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('خطأ في الاتصال: $e')),
          ),
        ),
      ]),
    );
  }

  Widget _buildDiscovery() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('🔥 الأكثر بحثاً',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _trending
                  .map((t) => GestureDetector(
                        onTap: () {
                          _ctrl.text = t;
                          _doSearch(t);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: const Color(0xFF2980B9)
                                      .withOpacity(0.4))),
                          child: Text(t,
                              style: const TextStyle(
                                  color: Color(0xFF2980B9),
                                  fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList()),
          if (_recentSearches.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('🕐 البحث الأخير',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                  onPressed: () => setState(() => _recentSearches.clear()),
                  child: const Text('حذف الكل')),
            ]),
            ..._recentSearches.map((r) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.history, color: Colors.grey),
                  title: Text(r),
                  trailing: const Icon(Icons.north_west,
                      color: Colors.grey, size: 16),
                  onTap: () {
                    _ctrl.text = r;
                    _doSearch(r);
                  },
                )),
          ],
        ]),
      );

  Widget _buildResults(List<dynamic> results) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('لم نجد نتائج تطابق بحثك',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey)),
            const Text('جرب كلمات بحث مختلفة أو فلاتر أخرى',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final p = results[i];
        return GestureDetector(
          onTap: () => context.push('/provider/${p['uuid']}'),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 4)
                ]),
            child: Row(children: [
              Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: const Color(0xFFD6EAF8),
                      borderRadius: BorderRadius.circular(10)),
                  child: p['logo_url'] != null
                      ? Image.network(p['logo_url'])
                      : const Icon(Icons.store,
                          color: Color(0xFF2980B9), size: 32)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(p['business_name'] ?? 'بدون اسم',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                        '${p['category_name'] ?? 'عام'} · ${p['region_name'] ?? 'غير محدد'}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 13)),
                    Row(children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      Text(' ${p['rating_avg'] ?? 0} ',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      if (p['distance_meters'] != null)
                        Text(
                            '· ${(p['distance_meters'] / 1000).toStringAsFixed(1)} كم',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 13)),
                    ]),
                  ])),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFFD5F5E3),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('مفتوح',
                      style: TextStyle(
                          color: Color(0xFF27AE60),
                          fontSize: 12,
                          fontWeight: FontWeight.bold))),
            ]),
          ),
        );
      },
    );
  }

  void _doSearch(String q) {
    if (q.trim().isEmpty) return;
    setState(() {
      _suggestions = [];
    });
    ref.read(searchProvider.notifier).search(
          query: q,
          ratingMin: _selectedRating > 0 ? _selectedRating : null,
          radius: _selectedRadius,
          // يمكن إضافة الموقع الجغرافي هنا إذا توفر
        );
  }
}
