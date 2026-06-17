// order_tracking_screen.dart - Real-time order tracking like Uber/Careem
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/orders_provider.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 1; // 0=confirmed, 1=preparing, 2=on_way, 3=delivered
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  final _steps = [
    {
      'title': 'تم تأكيد الطلب',
      'subtitle': 'الطلب # 12045',
      'icon': Icons.check_circle_outline,
      'time': '2:30 م'
    },
    {
      'title': 'جاري التحضير',
      'subtitle': 'المطعم يجهّز طلبك',
      'icon': Icons.restaurant_outlined,
      'time': '2:35 م'
    },
    {
      'title': 'في الطريق إليك',
      'subtitle': 'المندوب توجّه لاستلام طلبك',
      'icon': Icons.delivery_dining_outlined,
      'time': null
    },
    {
      'title': 'تم التوصيل',
      'subtitle': 'استمتع بوجبتك! 🎉',
      'icon': Icons.home_outlined,
      'time': null
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  int _resolveStep(String status) {
    if (status == 'pending') return 0;
    if (status == 'accepted' || status == 'processing') return 1;
    if (status == 'out_for_delivery') return 2;
    if (status == 'delivered') return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ordersProvider);
    final order = state.orders.firstWhere(
      (o) => o.uuid == widget.orderId || o.id.toString() == widget.orderId,
      orElse: () => throw Exception('Order not found'),
    );

    _currentStep = _resolveStep(order.status);

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        title: Text('تتبّع الطلب #${widget.orderId}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.support_agent, size: 18),
            label: const Text('دعم', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Map View (Placeholder) ───────────────────
          Container(
            height: MediaQuery.of(context).size.height * 0.38,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFCFE8F7), Color(0xFFE8F4FD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Grid lines simulation
                ...List.generate(
                    5,
                    (i) => Positioned(
                          top: i * 60.0,
                          left: 0,
                          right: 0,
                          child: Divider(
                              color: Colors.blue.withOpacity(0.1),
                              thickness: 1),
                        )),
                ...List.generate(
                    6,
                    (i) => Positioned(
                          left: i * 70.0,
                          top: 0,
                          bottom: 0,
                          child: VerticalDivider(
                              color: Colors.blue.withOpacity(0.1),
                              thickness: 1),
                        )),
                // Route line
                Positioned(
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _RoutePainter(),
                  ),
                ),
                // Driver icon
                Positioned(
                  top: 80,
                  right: 120,
                  child: ScaleTransition(
                    scale: _pulseAnim,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                        boxShadow: AppTheme.shadowPrimary,
                      ),
                      child: const Icon(Icons.delivery_dining,
                          color: Colors.white, size: 28),
                    ),
                  ),
                ),
                // Destination icon
                Positioned(
                  bottom: 60,
                  left: 80,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: AppTheme.errorColor.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4))
                          ],
                        ),
                        child: const Icon(Icons.location_on,
                            color: Colors.white, size: 20),
                      ),
                      Container(
                          width: 2, height: 12, color: AppTheme.errorColor),
                    ],
                  ),
                ),
                // ETA Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.radiusMd,
                      boxShadow: AppTheme.shadowMd,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 16, color: AppTheme.primaryLight),
                        SizedBox(width: 6),
                        Text('~12 دقيقة',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Driver Info Card ─────────────────────────
          Transform.translate(
            offset: const Offset(0, -24),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppTheme.radiusLg,
                boxShadow: AppTheme.shadowMd,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryLight,
                    child: const Text('م',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('محمد السلوم',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 16)),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: AppTheme.warningColor, size: 14),
                            const SizedBox(width: 4),
                            const Text('4.9',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(width: 8),
                            Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                    color: AppTheme.textMuted,
                                    shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            const Text('237 رحلة', style: AppTheme.bodySm),
                          ],
                        ),
                        const Text('تويوتا كامري - ABC 1234',
                            style: AppTheme.bodyMd),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _CircleAction(
                          icon: Icons.phone_outlined,
                          onTap: () {},
                          tooltip: 'اتصال'),
                      const SizedBox(width: 8),
                      _CircleAction(
                          icon: Icons.chat_outlined,
                          onTap: () {},
                          tooltip: 'رسالة'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ─── Steps Timeline ───────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حالة الطلب', style: AppTheme.headingSm),
                  const SizedBox(height: 16),
                  ..._steps.asMap().entries.map((e) => _StepItem(
                        step: e.value,
                        index: e.key,
                        currentStep: _currentStep,
                        isLast: e.key == _steps.length - 1,
                      )),
                  const SizedBox(height: 16),
                  // Order summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: AppTheme.radiusMd,
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ملخص الطلب', style: AppTheme.headingSm),
                        const SizedBox(height: 12),
                        ...order.items
                            .map((i) => _OrderRow(
                                label:
                                    '${i['product_name']} × ${i['quantity']}',
                                value:
                                    '${(double.tryParse(i['price'].toString()) ?? 0.0) * (i['quantity'] as int)} ج.س'))
                            .toList(),
                        const Divider(height: 20),
                        _OrderRow(
                            label: 'رسوم التوصيل',
                            value: 'مجاني',
                            valueColor: AppTheme.accentColor),
                        _OrderRow(
                            label: 'الإجمالي',
                            value: '${order.totalAmount} ج.س',
                            bold: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _CircleAction(
      {required this.icon, required this.onTap, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryLight.withOpacity(0.1),
          ),
          child: Icon(icon, color: AppTheme.primaryLight, size: 20),
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final Map step;
  final int index;
  final int currentStep;
  final bool isLast;
  const _StepItem(
      {required this.step,
      required this.index,
      required this.currentStep,
      required this.isLast});

  @override
  Widget build(BuildContext context) {
    final isDone = index < currentStep;
    final isActive = index == currentStep;
    final isPending = index > currentStep;

    final color = isDone
        ? AppTheme.accentColor
        : isActive
            ? AppTheme.primaryLight
            : AppTheme.textMuted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPending ? AppTheme.bgLight : color.withOpacity(0.15),
                border: Border.all(
                    color: isPending ? AppTheme.borderColor : color, width: 2),
              ),
              child: Icon(
                isDone ? Icons.check : step['icon'] as IconData,
                size: 18,
                color: color,
              ),
            ),
            if (!isLast)
              Container(
                  width: 2,
                  height: 40,
                  color: isDone ? AppTheme.accentColor : AppTheme.borderColor),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'] as String,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14,
                    color:
                        isPending ? AppTheme.textMuted : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(step['subtitle'] as String, style: AppTheme.bodySm),
                if (step['time'] != null) ...[
                  const SizedBox(height: 4),
                  Text(step['time'] as String,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600)),
                ],
                if (isActive) ...[
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    backgroundColor: AppTheme.borderColor,
                    color: AppTheme.primaryLight,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  const _OrderRow(
      {required this.label,
      required this.value,
      this.valueColor,
      this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bold ? AppTheme.headingSm : AppTheme.bodyMd),
          Text(value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                fontSize: bold ? 16 : 14,
                color: valueColor ??
                    (bold ? AppTheme.textPrimary : AppTheme.textSecondary),
                fontFamily: 'Cairo',
              )),
        ],
      ),
    );
  }
}

// Route painter for map visual
class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryLight.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.7, size.height * 0.3)
      ..cubicTo(size.width * 0.8, size.height * 0.5, size.width * 0.4,
          size.height * 0.5, size.width * 0.3, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
