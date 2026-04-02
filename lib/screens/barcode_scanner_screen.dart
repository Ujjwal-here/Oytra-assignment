import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../services/product_repository.dart';
import '../widgets/app_top_message.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});
  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final _controller = MobileScannerController();
  final _products = ProductRepository();

  String? _barcode;
  Product? _product;
  bool? _valid;
  bool _paused = false;

  void _onDetect(BarcodeCapture cap) {
    if (_paused) return;
    final raw = cap.barcodes.first.rawValue;
    if (raw == null) return;
    setState(() {
      _paused = true;
      _barcode = raw;
      _product = null;
      final last = int.tryParse(raw.trim().characters.last);
      _valid = last != null ? last % 2 == 0 : false;
    });
    _controller.stop();

    _products.findByBarcode(raw).then((p) {
      if (!mounted) return;
      setState(() => _product = p);
    });
  }

  void _reset() {
    setState(() {
      _barcode = null;
      _product = null;
      _valid = null;
      _paused = false;
    });
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        actions: [
          IconButton(
            icon: Icon(Icons.flash_on_rounded, color: AppTheme.textMid),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: _paused && _barcode != null
          ? SafeArea(
              child: ResponsiveBody(
                child: _ResultView(
                  barcode: _barcode!,
                  product: _product,
                  valid: _valid ?? false,
                  onReset: _reset,
                  r: r,
                ),
              ),
            )
          : _ScannerView(controller: _controller, onDetect: _onDetect, r: r),
    );
  }
}

class _ScannerView extends StatelessWidget {
  final MobileScannerController controller;
  final Function(BarcodeCapture) onDetect;
  final R r;
  const _ScannerView({
    required this.controller,
    required this.onDetect,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;
        final side = math.min(maxW * 0.72, maxH * 0.45).clamp(200.0, 420.0);
        final boxW = side;
        final boxH = r.isLandscape ? boxW * 0.48 : boxW * 0.55;

        return Stack(
          children: [
            MobileScanner(controller: controller, onDetect: onDetect),
            Positioned.fill(
              child: Column(
                children: [
                  Expanded(flex: 2, child: Container(color: Colors.black54)),
                  Row(
                    children: [
                      Expanded(child: Container(color: Colors.black54)),
                      Container(
                        width: boxW,
                        height: boxH,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.cyan, width: 2),
                          borderRadius: BorderRadius.circular(r.dp(12)),
                        ),
                      ),
                      Expanded(child: Container(color: Colors.black54)),
                    ],
                  ),
                  Expanded(flex: 3, child: Container(color: Colors.black54)),
                ],
              ),
            ),
            Positioned(
              bottom: r.dp(60),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.dp(18),
                    vertical: r.dp(9),
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.surface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(r.dp(20)),
                    border: Border.all(color: AppTheme.border, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppTheme.cyan,
                        size: r.dp(15),
                      ),
                      SizedBox(width: r.dp(7)),
                      Text(
                        'Point at a barcode',
                        style: GoogleFonts.cabin(
                          color: AppTheme.textHigh,
                          fontSize: r.sp(13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultView extends StatefulWidget {
  final String barcode;
  final Product? product;
  final bool valid;
  final VoidCallback onReset;
  final R r;

  const _ResultView({
    required this.barcode,
    required this.product,
    required this.valid,
    required this.onReset,
    required this.r,
  });

  @override
  State<_ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<_ResultView> {
  late TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    _qtyCtrl = TextEditingController(text: '${widget.product?.moq ?? 1}');
  }

  @override
  void didUpdateWidget(_ResultView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.product?.id != oldWidget.product?.id) {
      _qtyCtrl.text = '${widget.product?.moq ?? 1}';
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final product = widget.product;
    final valid = widget.valid;
    final glowColor = valid ? AppTheme.successGlow : AppTheme.dangerGlow;
    final statusColor = valid ? AppTheme.success : AppTheme.danger;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(r.dp(24), r.dp(32), r.dp(24), r.dp(32)),
      child: Column(
        children: [
          Container(
            width: r.dp(100),
            height: r.dp(100),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: valid ? AppTheme.successGradient : null,
              color: valid ? null : AppTheme.dangerGlow,
              border: valid
                  ? null
                  : Border.all(color: AppTheme.danger, width: 2),
            ),
            child: Icon(
              valid ? Icons.check_rounded : Icons.close_rounded,
              color: Colors.white,
              size: r.dp(50),
            ),
          ),
          SizedBox(height: r.dp(20)),

          Text(
            valid ? 'Valid Barcode' : 'Invalid Barcode',
            style: GoogleFonts.cabin(
              color: statusColor,
              fontSize: r.sp(24),
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: r.dp(6)),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.dp(14),
              vertical: r.dp(8),
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceHigh,
              borderRadius: BorderRadius.circular(r.dp(8)),
              border: Border.all(color: AppTheme.border, width: 0.8),
            ),
            child: Text(
              widget.barcode,
              style: GoogleFonts.robotoMono(
                color: AppTheme.textMid,
                fontSize: r.sp(13),
              ),
            ),
          ),

          SizedBox(height: r.dp(8)),

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.dp(12),
              vertical: r.dp(6),
            ),
            decoration: BoxDecoration(
              color: glowColor,
              borderRadius: BorderRadius.circular(r.dp(20)),
            ),
            child: Text(
              'Last digit: ${widget.barcode.characters.last}  →  ${valid ? "Even = Valid ✓" : "Odd = Invalid ✗"}',
              style: GoogleFonts.cabin(
                color: statusColor,
                fontSize: r.sp(12),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: r.dp(28)),

          if (product != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(r.dp(18)),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(r.dp(16)),
                border: Border.all(
                  color: AppTheme.cyan.withValues(alpha: 0.2),
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.dp(8),
                          vertical: r.dp(3),
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cyanGlow,
                          borderRadius: BorderRadius.circular(r.dp(4)),
                        ),
                        child: Text(
                          'PRODUCT FOUND',
                          style: GoogleFonts.cabin(
                            color: AppTheme.cyan,
                            fontSize: r.sp(10),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.dp(12)),
                  Text(
                    product.name,
                    style: GoogleFonts.cabin(
                      color: AppTheme.textHigh,
                      fontSize: r.sp(20),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: r.dp(12)),
                  Wrap(
                    spacing: r.dp(8),
                    runSpacing: r.dp(8),
                    children: [
                      _Chip(
                        label: product.category,
                        icon: Icons.category_rounded,
                        r: r,
                      ),
                      _Chip(
                        label: '₹${product.basePrice.toStringAsFixed(0)}',
                        icon: Icons.currency_rupee_rounded,
                        r: r,
                      ),
                      _Chip(
                        label: 'MOQ ${product.moq}',
                        icon: Icons.inventory_2_rounded,
                        r: r,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: r.dp(16)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.cabin(
                      color: AppTheme.textHigh,
                      fontSize: r.sp(14),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Qty (min ${product.moq})',
                    ),
                  ),
                ),
                SizedBox(width: r.dp(10)),
                ElevatedButton.icon(
                  onPressed: () {
                    final qty = int.tryParse(_qtyCtrl.text.trim());
                    if (qty == null || qty <= 0) {
                      showTopMessage(
                        context,
                        'Enter a valid quantity',
                        isError: true,
                      );
                      return;
                    }
                    final op = context.read<OrderProvider>();
                    final err = op.addItem(product, qty);
                    if (!context.mounted) return;
                    showTopMessage(
                      context,
                      err ?? '${product.name} added to order',
                      isError: err != null,
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Add to order'),
                ),
              ],
            ),
          ] else ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(r.dp(16)),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(r.dp(14)),
                border: Border.all(color: AppTheme.border, width: 0.8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    color: AppTheme.textMid,
                    size: r.dp(20),
                  ),
                  SizedBox(width: r.dp(10)),
                  Text(
                    'Not found in catalog',
                    style: GoogleFonts.cabin(
                      color: AppTheme.textMid,
                      fontSize: r.sp(14),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: r.dp(28)),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onReset,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan Again'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  final R r;
  const _Chip({required this.label, required this.icon, required this.r});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: r.dp(10), vertical: r.dp(6)),
    decoration: BoxDecoration(
      color: AppTheme.surfaceHigh,
      borderRadius: BorderRadius.circular(r.dp(8)),
      border: Border.all(color: AppTheme.border, width: 0.8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: r.dp(13), color: AppTheme.textMid),
        SizedBox(width: r.dp(5)),
        Text(
          label,
          style: GoogleFonts.cabin(color: AppTheme.textMid, fontSize: r.sp(12)),
        ),
      ],
    ),
  );
}
