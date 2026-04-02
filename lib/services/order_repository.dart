import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_item.dart';
import '../models/placed_order.dart';

class OrderRepository {
  final FirebaseFirestore _db;

  static const String localOrdersUid = 'local_device';

  OrderRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Stream<List<PlacedOrder>> streamOrdersForUser(String uid) {
    return _db
        .collection('orders')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final orders = snapshot.docs.map(PlacedOrder.fromDoc).toList();
          orders.sort((a, b) {
            final ta = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final tb = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return tb.compareTo(ta);
          });
          return orders;
        });
  }

  Future<String> createOrder({
    required String uid,
    required String customerType,
    required List<OrderItem> items,
    required double grandTotal,
  }) async {
    final ref = _db.collection('orders').doc();

    await ref.set({
      'uid': uid,
      'customerType': customerType,
      'items': items.map((e) => e.toMap()).toList(),
      'grandTotal': grandTotal,
      'status': 'CREATED',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return ref.id;
  }
}
