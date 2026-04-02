import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/placed_order.dart';
import '../theme/app_theme.dart';

class PlacedOrderCard extends StatefulWidget {
  const PlacedOrderCard({super.key, required this.order, required this.r});

  final PlacedOrder order;
  final R r;

  @override
  State<PlacedOrderCard> createState() => _PlacedOrderCardState();
}

class _PlacedOrderCardState extends State<PlacedOrderCard> {
  bool _expanded = false;

  static String _formatDate(DateTime? d) {
    if (d == null) return 'Date unknown';
    return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static String _price(dynamic v) {
    if (v is num) return v.toStringAsFixed(2);
    return '0.00';
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    final order = widget.order;
    final isDealer = order.customerType == 'Dealer';

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(r.dp(14)),
        side: const BorderSide(color: AppTheme.border, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            expanded: _expanded,
            button: true,
            label: 'Order ${order.id}, ${order.grandTotal} rupees',
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: EdgeInsets.only(
                  left: r.dp(4),
                  right: r.dp(4),
                  top: r.dp(4),
                  bottom: r.dp(2),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: r.dp(10),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: r.dp(8),
                          vertical: r.dp(3),
                        ),
                        decoration: BoxDecoration(
                          gradient: isDealer
                              ? AppTheme.amberGradient
                              : AppTheme.violetGradient,
                          borderRadius: BorderRadius.circular(r.dp(6)),
                        ),
                        child: Text(
                          order.customerType,
                          style: GoogleFonts.cabin(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: r.sp(10),
                          ),
                        ),
                      ),
                      SizedBox(width: r.dp(8)),
                      Expanded(
                        child: Text(
                          _formatDate(order.createdAt),
                          style: GoogleFonts.cabin(
                            color: AppTheme.textMid,
                            fontSize: r.sp(12),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${order.grandTotal.toStringAsFixed(2)}',
                        style: GoogleFonts.cabin(
                          color: AppTheme.cyan,
                          fontWeight: FontWeight.w800,
                          fontSize: r.sp(15),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: EdgeInsets.only(top: r.dp(8)),
                    child: Row(
                      children: [
                        Icon(
                          Icons.tag_rounded,
                          size: r.dp(12),
                          color: AppTheme.textLow,
                        ),
                        SizedBox(width: r.dp(4)),
                        Expanded(
                          child: Text(
                            order.id,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.robotoMono(
                              color: AppTheme.textLow,
                              fontSize: r.sp(10),
                            ),
                          ),
                        ),
                        Chip(
                          label: Text(
                            order.status,
                            style: GoogleFonts.cabin(
                              color: AppTheme.success,
                              fontSize: r.sp(10),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          labelPadding: EdgeInsets.symmetric(
                            horizontal: r.dp(8),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: AppTheme.successGlow,
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ),
                  trailing: AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: AppTheme.textMid,
                      size: r.dp(26),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Divider(
                        height: 1,
                        thickness: 0.8,
                        color: AppTheme.border,
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(
                          r.dp(8),
                          r.dp(4),
                          r.dp(8),
                          r.dp(12),
                        ),
                        itemCount: order.itemLines.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          thickness: 0.6,
                          color: AppTheme.border.withValues(alpha: 0.6),
                        ),
                        itemBuilder: (context, i) {
                          final line = order.itemLines[i];
                          final name =
                              line['name']?.toString() ?? 'Item';
                          final qty = line['quantity'] ?? 0;
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: r.dp(8),
                            ),
                            leading: CircleAvatar(
                              radius: r.dp(16),
                              backgroundColor: AppTheme.surfaceHigh,
                              child: Text(
                                '${i + 1}',
                                style: GoogleFonts.cabin(
                                  color: AppTheme.textMid,
                                  fontWeight: FontWeight.w700,
                                  fontSize: r.sp(11),
                                ),
                              ),
                            ),
                            title: Text(
                              name,
                              style: GoogleFonts.cabin(
                                color: AppTheme.textHigh,
                                fontWeight: FontWeight.w600,
                                fontSize: r.sp(13),
                              ),
                            ),
                            subtitle: Text(
                              '$qty × ₹${_price(line['unitPrice'])}',
                              style: GoogleFonts.cabin(
                                color: AppTheme.textMid,
                                fontSize: r.sp(11),
                              ),
                            ),
                            trailing: Text(
                              '₹${_price(line['totalPrice'])}',
                              style: GoogleFonts.cabin(
                                color: AppTheme.textHigh,
                                fontWeight: FontWeight.w700,
                                fontSize: r.sp(13),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
