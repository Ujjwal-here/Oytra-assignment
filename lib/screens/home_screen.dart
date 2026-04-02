import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'product_list_screen.dart';
import 'barcode_scanner_screen.dart';
import 'order_summary_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    final op = context.watch<OrderProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: r.dp(28),
              height: r.dp(28),
              decoration: BoxDecoration(
                gradient: AppTheme.cyanGradient,
                borderRadius: BorderRadius.circular(r.dp(7)),
              ),
              child: Icon(
                Icons.business_center_rounded,
                size: r.dp(16),
                color: const Color(0xFF001820),
              ),
            ),
            SizedBox(width: r.dp(10)),
            Text(
              'Oytra',
              style: GoogleFonts.cabin(
                color: AppTheme.textHigh,
                fontWeight: FontWeight.w800,
                fontSize: r.sp(18),
              ),
            ),
            Text(
              ' Internal',
              style: GoogleFonts.cabin(
                color: AppTheme.textMid,
                fontWeight: FontWeight.w400,
                fontSize: r.sp(18),
              ),
            ),
          ],
        ),
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
          child: SingleChildScrollView(
            padding: r.contentPadding(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: r.dp(8)),
                Text(
                  'Good morning 👋',
                  style: GoogleFonts.cabin(
                    color: AppTheme.textMid,
                    fontSize: r.sp(13),
                  ),
                ),
                SizedBox(height: r.dp(2)),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Business ',
                        style: GoogleFonts.cabin(
                          color: AppTheme.textHigh,
                          fontSize: r.sp(30),
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      TextSpan(
                        text: 'Hub',
                        style: GoogleFonts.cabin(
                          foreground: Paint()
                            ..shader = AppTheme.cyanGradient.createShader(
                              const Rect.fromLTWH(0, 0, 140, 40),
                            ),
                          fontSize: r.sp(30),
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: r.dp(28)),

                _SectionLabel(label: 'CUSTOMER TYPE', r: r),
                SizedBox(height: r.dp(10)),
                Row(
                  children: [
                    _TypeTile(
                      label: 'Dealer',
                      sub: '15% off base price',
                      icon: Icons.store_rounded,
                      gradient: AppTheme.amberGradient,
                      glowColor: AppTheme.amberGlow,
                      selected: op.customerType == 'Dealer',
                      onTap: () => op.setCustomerType('Dealer'),
                      r: r,
                    ),
                    SizedBox(width: r.dp(12)),
                    _TypeTile(
                      label: 'Retail',
                      sub: 'Standard pricing',
                      icon: Icons.person_rounded,
                      gradient: AppTheme.violetGradient,
                      glowColor: AppTheme.violetGlow,
                      selected: op.customerType == 'Retail',
                      onTap: () => op.setCustomerType('Retail'),
                      r: r,
                    ),
                  ],
                ),

                if (op.itemCount > 0) ...[
                  SizedBox(height: r.dp(16)),
                  _OrderBanner(op: op, r: r),
                ],

                SizedBox(height: r.dp(28)),

                _SectionLabel(label: 'MODULES', r: r),
                SizedBox(height: r.dp(12)),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: r.gridColumns,
                  mainAxisSpacing: r.dp(12),
                  crossAxisSpacing: r.dp(12),
                  childAspectRatio: r.moduleTileAspectRatio,
                  children: [
                    _ModuleTile(
                      title: 'Products',
                      sub: 'Browse catalog',
                      icon: Icons.inventory_2_rounded,
                      gradient: AppTheme.productGradient,
                      accentColor: AppTheme.cyan,
                      accentGlow: AppTheme.cyanGlow,
                      r: r,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductListScreen(),
                        ),
                      ),
                    ),
                    _ModuleTile(
                      title: 'Scanner',
                      sub: 'Scan barcode',
                      icon: Icons.qr_code_scanner_rounded,
                      gradient: AppTheme.scannerGradient,
                      accentColor: AppTheme.violetLight,
                      accentGlow: AppTheme.violetGlow,
                      r: r,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const BarcodeScannerScreen(),
                        ),
                      ),
                    ),
                    _ModuleTile(
                      title: 'Orders',
                      sub: 'Placed orders',
                      icon: Icons.receipt_long_rounded,
                      gradient: AppTheme.orderGradient,
                      accentColor: AppTheme.success,
                      accentGlow: AppTheme.successGlow,
                      r: r,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrderSummaryScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final R r;
  const _SectionLabel({required this.label, required this.r});
  @override
  Widget build(BuildContext context) => Text(
    label,
    style: GoogleFonts.cabin(
      color: AppTheme.textLow,
      fontSize: r.sp(10),
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
    ),
  );
}

class _TypeTile extends StatelessWidget {
  final String label, sub;
  final IconData icon;
  final LinearGradient gradient;
  final Color glowColor;
  final bool selected;
  final VoidCallback onTap;
  final R r;

  const _TypeTile({
    required this.label,
    required this.sub,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.selected,
    required this.onTap,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(r.dp(14)),
          decoration: BoxDecoration(
            color: selected ? glowColor : AppTheme.surface,
            borderRadius: BorderRadius.circular(r.dp(14)),
            border: Border.all(
              color: selected
                  ? gradient.colors.first.withValues(alpha: 0.6)
                  : AppTheme.border,
              width: selected ? 1.2 : 0.8,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: r.dp(36),
                height: r.dp(36),
                decoration: BoxDecoration(
                  gradient: selected ? gradient : null,
                  color: selected ? null : AppTheme.surfaceHigh,
                  borderRadius: BorderRadius.circular(r.dp(10)),
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : AppTheme.textMid,
                  size: r.dp(18),
                ),
              ),
              SizedBox(width: r.dp(10)),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.cabin(
                        color: selected
                            ? gradient.colors.first
                            : AppTheme.textHigh,
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(14),
                      ),
                    ),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
    );
  }
}

class _ModuleTile extends StatelessWidget {
  final String title, sub;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor, accentGlow;
  final VoidCallback onTap;
  final R r;

  const _ModuleTile({
    required this.title,
    required this.sub,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.accentGlow,
    required this.onTap,
    required this.r,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(r.dp(16)),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(r.dp(18)),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.15),
            width: 0.8,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: r.dp(44),
              height: r.dp(44),
              decoration: BoxDecoration(
                color: accentGlow,
                borderRadius: BorderRadius.circular(r.dp(12)),
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 0.8,
                ),
              ),
              child: Icon(icon, color: accentColor, size: r.dp(22)),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: r.dp(24),
                  height: r.dp(24),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: accentColor,
                    size: r.dp(13),
                  ),
                ),
              ],
            ),
            SizedBox(height: r.dp(6)),
            Text(
              title,
              style: GoogleFonts.cabin(
                color: AppTheme.textHigh,
                fontWeight: FontWeight.w700,
                fontSize: r.sp(16),
              ),
            ),
            SizedBox(height: r.dp(2)),
            Text(
              sub,
              style: GoogleFonts.cabin(
                color: AppTheme.textMid,
                fontSize: r.sp(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderBanner extends StatelessWidget {
  final OrderProvider op;
  final R r;
  const _OrderBanner({required this.op, required this.r});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartScreen()),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.dp(16), vertical: r.dp(13)),
        decoration: BoxDecoration(
          color: AppTheme.successGlow,
          borderRadius: BorderRadius.circular(r.dp(14)),
          border: Border.all(
            color: AppTheme.success.withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: r.dp(36),
              height: r.dp(36),
              decoration: BoxDecoration(
                gradient: AppTheme.successGradient,
                borderRadius: BorderRadius.circular(r.dp(10)),
              ),
              child: Icon(
                Icons.shopping_cart_rounded,
                color: Colors.white,
                size: r.dp(18),
              ),
            ),
            SizedBox(width: r.dp(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${op.itemCount} item(s) in cart',
                    style: GoogleFonts.cabin(
                      color: AppTheme.textHigh,
                      fontWeight: FontWeight.w600,
                      fontSize: r.sp(13),
                    ),
                  ),
                  Text(
                    op.customerType,
                    style: GoogleFonts.cabin(
                      color: AppTheme.textMid,
                      fontSize: r.sp(11),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₹${op.grandTotal.toStringAsFixed(2)}',
              style: GoogleFonts.cabin(
                color: AppTheme.success,
                fontWeight: FontWeight.w800,
                fontSize: r.sp(17),
              ),
            ),
            SizedBox(width: r.dp(6)),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textMid,
              size: r.dp(18),
            ),
          ],
        ),
      ),
    );
  }
}
