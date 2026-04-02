import 'package:cloud_firestore/cloud_firestore.dart';

class PlacedOrder {
  final String id;
  final String customerType;
  final double grandTotal;
  final String status;
  final DateTime? createdAt;
  final List<Map<String, dynamic>> itemLines;

  const PlacedOrder({
    required this.id,
    required this.customerType,
    required this.grandTotal,
    required this.status,
    required this.createdAt,
    required this.itemLines,
  });

  factory PlacedOrder.fromDoc(DocumentSnapshot doc) {
    final raw = doc.data();
    final d = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    final rawItems = d['items'];
    final lines = <Map<String, dynamic>>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map<String, dynamic>) {
          lines.add(e);
        } else if (e is Map) {
          lines.add(Map<String, dynamic>.from(e));
        }
      }
    }

    final g = d['grandTotal'];
    double gt = 0;
    if (g is num) gt = g.toDouble();

    final ts = d['createdAt'];
    DateTime? created;
    if (ts is Timestamp) created = ts.toDate();

    return PlacedOrder(
      id: doc.id,
      customerType: d['customerType']?.toString() ?? '',
      grandTotal: gt,
      status: d['status']?.toString() ?? '',
      createdAt: created,
      itemLines: lines,
    );
  }
}
