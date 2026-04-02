import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/product_repository.dart';

import '../models/product.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_top_message.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _future;
  final _products = ProductRepository();

  @override
  void initState() {
    super.initState();
    _future = _products.fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    final op = context.watch<OrderProvider>();
    final isDealer = op.customerType == 'Dealer';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: r.dp(8)),
            child: IconButton(
              tooltip: 'Cart',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
              icon: Badge(
                isLabelVisible: op.itemCount > 0,
                label: Text(
                  op.itemCount > 99 ? '99+' : '${op.itemCount}',
                  style: GoogleFonts.cabin(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: r.dp(22),
                  color: AppTheme.textHigh,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ResponsiveBody(
          child: Column(
            children: [
              Padding(
            padding: EdgeInsets.fromLTRB(r.dp(16), r.dp(4), r.dp(16), r.dp(12)),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.dp(14),
                vertical: r.dp(10),
              ),
              decoration: BoxDecoration(
                color: isDealer ? AppTheme.amberGlow : AppTheme.violetGlow,
                borderRadius: BorderRadius.circular(r.dp(12)),
                border: Border.all(
                  color: isDealer
                      ? AppTheme.amber.withValues(alpha: 0.3)
                      : AppTheme.violet.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(r.dp(6)),
                    decoration: BoxDecoration(
                      gradient: isDealer
                          ? AppTheme.amberGradient
                          : AppTheme.violetGradient,
                      borderRadius: BorderRadius.circular(r.dp(8)),
                    ),
                    child: Icon(
                      isDealer ? Icons.store_rounded : Icons.person_rounded,
                      color: Colors.white,
                      size: r.dp(14),
                    ),
                  ),
                  SizedBox(width: r.dp(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDealer ? 'Dealer Pricing' : 'Retail Pricing',
                          style: GoogleFonts.cabin(
                            color: isDealer
                                ? AppTheme.amber
                                : AppTheme.violetLight,
                            fontWeight: FontWeight.w700,
                            fontSize: r.sp(13),
                          ),
                        ),
                        Text(
                          isDealer
                              ? '15% off on all products'
                              : 'Standard base price',
                          style: GoogleFonts.cabin(
                            color: AppTheme.textMid,
                            fontSize: r.sp(11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
              ),

              Expanded(
                child: FutureBuilder<List<Product>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: r.dp(40),
                          height: r.dp(40),
                          child: CircularProgressIndicator(
                            color: AppTheme.cyan,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(height: r.dp(16)),
                        Text(
                          'Fetching products from API…',
                          style: GoogleFonts.cabin(
                            color: AppTheme.textMid,
                            fontSize: r.sp(14),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (snap.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: AppTheme.danger,
                          size: r.dp(48),
                        ),
                        SizedBox(height: r.dp(12)),
                        Text(
                          '${snap.error}',
                          style: GoogleFonts.cabin(
                            color: AppTheme.textMid,
                            fontSize: r.sp(13),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: r.dp(16)),
                        ElevatedButton.icon(
                          onPressed: () =>
                              setState(() => _future = _products.fetchProducts()),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                final products = snap.data!;
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(r.dp(16), 0, r.dp(16), r.dp(80)),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => SizedBox(height: r.dp(10)),
                  itemBuilder: (ctx, i) => _ProductCard(
                    product: products[i],
                    customerType: op.customerType,
                    r: r,
                    onAdd: (qty) {
                      final err = op.addItem(products[i], qty);
                      _showSnack(
                        ctx,
                        err == null,
                        err ?? '${products[i].name} added!',
                      );
                    },
                  ),
                );
              },
            ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnack(BuildContext ctx, bool ok, String msg) {
    showTopMessage(ctx, msg, isError: !ok);
  }
}

class _ProductCard extends StatefulWidget {
  final Product product;
  final String customerType;
  final Function(int) onAdd;
  final R r;
  const _ProductCard({
    required this.product,
    required this.customerType,
    required this.onAdd,
    required this.r,
  });
  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  final _ctrl = TextEditingController();
  bool _open = false;
  R get r => widget.r;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDealer = widget.customerType == 'Dealer';
    final price = widget.product.priceForCustomerType(widget.customerType);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r.dp(16)),
        side: BorderSide(
          color: _open
              ? AppTheme.cyan.withValues(alpha: 0.35)
              : AppTheme.border,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(r.dp(14)),
            child: Row(
              children: [
                Container(
                  width: r.dp(46),
                  height: r.dp(46),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceHigh,
                    borderRadius: BorderRadius.circular(r.dp(12)),
                    border: Border.all(color: AppTheme.border, width: 0.8),
                  ),
                  child: Center(
                    child: Text(
                      _emoji(widget.product.category),
                      style: TextStyle(fontSize: r.sp(22)),
                    ),
                  ),
                ),
                SizedBox(width: r.dp(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: GoogleFonts.cabin(
                          color: AppTheme.textHigh,
                          fontWeight: FontWeight.w700,
                          fontSize: r.sp(14),
                        ),
                      ),
                      SizedBox(height: r.dp(4)),
                      Row(
                        children: [
                          Text(
                            widget.product.category,
                            style: GoogleFonts.cabin(
                              color: AppTheme.textMid,
                              fontSize: r.sp(11),
                            ),
                          ),
                          SizedBox(width: r.dp(6)),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: r.dp(6),
                              vertical: r.dp(2),
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.amber.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(r.dp(4)),
                              border: Border.all(
                                color: AppTheme.amber.withValues(alpha: 0.25),
                                width: 0.6,
                              ),
                            ),
                            child: Text(
                              'MOQ ${widget.product.moq}',
                              style: GoogleFonts.cabin(
                                color: AppTheme.amber,
                                fontSize: r.sp(10),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: r.dp(8)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${price.toStringAsFixed(2)}',
                      style: GoogleFonts.cabin(
                        color: isDealer ? AppTheme.amber : AppTheme.textHigh,
                        fontWeight: FontWeight.w800,
                        fontSize: r.sp(16),
                      ),
                    ),
                    if (isDealer)
                      Text(
                        '₹${widget.product.basePrice.toStringAsFixed(0)}',
                        style: GoogleFonts.cabin(
                          color: AppTheme.textLow,
                          fontSize: r.sp(11),
                          decoration: TextDecoration.lineThrough,
                          decorationColor: AppTheme.textLow,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 0.8, color: AppTheme.border),
          Material(
            color: _open ? AppTheme.cyanGlow : AppTheme.surfaceHigh,
            child: InkWell(
              onTap: () => setState(() => _open = !_open),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.dp(14),
                  vertical: r.dp(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.cyan,
                        size: r.dp(22),
                      ),
                    ),
                    SizedBox(width: r.dp(6)),
                    Icon(
                      _open
                          ? Icons.close_rounded
                          : Icons.add_shopping_cart_rounded,
                      color: AppTheme.cyan,
                      size: r.dp(16),
                    ),
                    SizedBox(width: r.dp(6)),
                    Text(
                      _open ? 'Cancel' : 'Add to Order',
                      style: GoogleFonts.cabin(
                        color: AppTheme.cyan,
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _open
                ? Material(
                    color: AppTheme.surfaceHigh,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        r.dp(14),
                        r.dp(8),
                        r.dp(14),
                        r.dp(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              keyboardType: TextInputType.number,
                              style: GoogleFonts.cabin(
                                color: AppTheme.textHigh,
                                fontSize: r.sp(14),
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Qty (min ${widget.product.moq})',
                              ),
                            ),
                          ),
                          SizedBox(width: r.dp(10)),
                          ElevatedButton(
                            onPressed: () {
                              final qty = int.tryParse(_ctrl.text);
                              if (qty == null || qty <= 0) {
                                showTopMessage(
                                  context,
                                  'Enter a valid quantity',
                                  isError: true,
                                );
                                return;
                              }
                              widget.onAdd(qty);
                              _ctrl.clear();
                              setState(() => _open = false);
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  String _emoji(String cat) =>
      const {
        'Fasteners': '🔩',
        'Pipes': '🪣',
        'Electrical': '⚡',
        'Fittings': '🔧',
      }[cat] ??
      '📦';
}
