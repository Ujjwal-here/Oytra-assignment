import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../services/order_repository.dart';
import '../widgets/app_top_message.dart';
import 'order_summary_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    final op = context.watch<OrderProvider>();
    final items = op.items;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          if (items.isNotEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, r, op),
              child: Text(
                'Clear all',
                style: GoogleFonts.cabin(
                  color: AppTheme.danger,
                  fontSize: r.sp(13),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: _CartBody(
            r: r,
            op: op,
            onPlaceOrder: () => _placeOrder(context, r, op),
          ),
        ),
      ),
    );
  }

  void _confirmClear(BuildContext ctx, R r, OrderProvider op) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r.dp(16)),
        ),
        title: Text(
          'Clear cart?',
          style: GoogleFonts.cabin(
            color: AppTheme.textHigh,
            fontWeight: FontWeight.w700,
            fontSize: r.sp(18),
          ),
        ),
        content: Text(
          'All items will be removed.',
          style: GoogleFonts.cabin(color: AppTheme.textMid, fontSize: r.sp(14)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.cabin(color: AppTheme.textMid),
            ),
          ),
          TextButton(
            onPressed: () {
              op.clearOrder();
              Navigator.pop(ctx);
            },
            child: Text(
              'Clear',
              style: GoogleFonts.cabin(
                color: AppTheme.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder(BuildContext ctx, R r, OrderProvider op) async {
    if (op.items.isEmpty) return;

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(r.dp(16)),
        ),
        content: Row(
          children: [
            SizedBox(
              width: r.dp(24),
              height: r.dp(24),
              child: const CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: r.dp(12)),
            Expanded(
              child: Text(
                'Processing payment...',
                style: GoogleFonts.cabin(color: AppTheme.textMid),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final orders = OrderRepository();
      final totalSnapshot = op.grandTotal;
      final typeSnapshot = op.customerType;

      await orders.createOrder(
        uid: OrderRepository.localOrdersUid,
        customerType: typeSnapshot,
        items: op.items,
        grandTotal: totalSnapshot,
      );

      op.clearOrder();

      if (ctx.mounted) Navigator.pop(ctx);
      if (!ctx.mounted) return;

      await showDialog(
        context: ctx,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.dp(16)),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(r.dp(8)),
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: r.dp(20),
                ),
              ),
              SizedBox(width: r.dp(10)),
              Text(
                'Order Placed!',
                style: GoogleFonts.cabin(
                  color: AppTheme.textHigh,
                  fontWeight: FontWeight.w700,
                  fontSize: r.sp(18),
                ),
              ),
            ],
          ),
          content: Text(
            '$typeSnapshot order of ₹${totalSnapshot.toStringAsFixed(2)} confirmed.',
            style: GoogleFonts.cabin(
              color: AppTheme.textMid,
              fontSize: r.sp(14),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (!ctx.mounted) return;
                Navigator.of(ctx).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const OrderSummaryScreen(),
                  ),
                );
              },
              child: const Text('View orders'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (ctx.mounted) Navigator.pop(ctx);
      if (!ctx.mounted) return;

      showTopMessage(
        ctx,
        'Order failed: $e',
        isError: true,
      );
    }
  }
}

class _CartBody extends StatelessWidget {
  final R r;
  final OrderProvider op;
  final VoidCallback onPlaceOrder;

  const _CartBody({
    required this.r,
    required this.op,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final items = op.items;
    final isDealer = op.customerType == 'Dealer';

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: r.dp(48),
              color: AppTheme.textLow,
            ),
            SizedBox(height: r.dp(16)),
            Text(
              'Your cart is empty',
              style: GoogleFonts.cabin(
                color: AppTheme.textMid,
                fontSize: r.sp(16),
              ),
            ),
            SizedBox(height: r.dp(6)),
            Text(
              'Add products from the catalog or scanner',
              style: GoogleFonts.cabin(
                color: AppTheme.textLow,
                fontSize: r.sp(13),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            r.dp(16),
            r.dp(4),
            r.dp(16),
            r.dp(8),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.dp(10),
                  vertical: r.dp(4),
                ),
                decoration: BoxDecoration(
                  gradient: isDealer
                      ? AppTheme.amberGradient
                      : AppTheme.violetGradient,
                  borderRadius: BorderRadius.circular(r.dp(20)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isDealer
                          ? Icons.store_rounded
                          : Icons.person_rounded,
                      color: Colors.white,
                      size: r.dp(12),
                    ),
                    SizedBox(width: r.dp(5)),
                    Text(
                      '${op.customerType} pricing',
                      style: GoogleFonts.cabin(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              r.dp(16),
              r.dp(4),
              r.dp(16),
              r.dp(16),
            ),
            itemCount: items.length,
            separatorBuilder: (_, _) => SizedBox(height: r.dp(8)),
            itemBuilder: (ctx, i) {
              final item = items[i];
              return Container(
                padding: EdgeInsets.all(r.dp(14)),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(r.dp(14)),
                  border: Border.all(
                    color: AppTheme.border,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: r.dp(3),
                      height: r.dp(40),
                      decoration: BoxDecoration(
                        gradient: isDealer
                            ? AppTheme.amberGradient
                            : AppTheme.violetGradient,
                        borderRadius: BorderRadius.circular(r.dp(2)),
                      ),
                    ),
                    SizedBox(width: r.dp(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: GoogleFonts.cabin(
                              color: AppTheme.textHigh,
                              fontWeight: FontWeight.w700,
                              fontSize: r.sp(14),
                            ),
                          ),
                          SizedBox(height: r.dp(3)),
                          Text(
                            '${item.quantity} × ₹${item.unitPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.cabin(
                              color: AppTheme.textMid,
                              fontSize: r.sp(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item.totalPrice.toStringAsFixed(2)}',
                      style: GoogleFonts.cabin(
                        color: AppTheme.textHigh,
                        fontWeight: FontWeight.w800,
                        fontSize: r.sp(15),
                      ),
                    ),
                    SizedBox(width: r.dp(10)),
                    GestureDetector(
                      onTap: () => op.removeItem(item.product.id),
                      child: Container(
                        width: r.dp(26),
                        height: r.dp(26),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerGlow,
                          borderRadius: BorderRadius.circular(r.dp(7)),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppTheme.danger,
                          size: r.dp(14),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(
            r.dp(20),
            r.dp(16),
            r.dp(20),
            r.dp(24),
          ),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            border: Border(
              top: BorderSide(color: AppTheme.border, width: 0.8),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grand Total',
                        style: GoogleFonts.cabin(
                          color: AppTheme.textHigh,
                          fontWeight: FontWeight.w700,
                          fontSize: r.sp(15),
                        ),
                      ),
                      Text(
                        '${items.length} item(s)',
                        style: GoogleFonts.cabin(
                          color: AppTheme.textMid,
                          fontSize: r.sp(12),
                        ),
                      ),
                    ],
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.cyanGradient.createShader(bounds),
                    child: Text(
                      '₹${op.grandTotal.toStringAsFixed(2)}',
                      style: GoogleFonts.cabin(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: r.sp(26),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: r.dp(16)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onPlaceOrder,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Place Order'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
