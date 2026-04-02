import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product.dart';

class ProductRepository {
  final FirebaseFirestore _db;

  ProductRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  Future<List<Product>> fetchProducts() async {
    final snap = await _db.collection('products').get();
    return snap.docs
        .map(
          (doc) => Product.fromJson({
            ...doc.data(),
            'id': doc.data()['id'] ?? doc.id,
          }),
        )
        .toList();
  }

  Future<Product?> findByBarcode(String barcode) async {
    final snap = await _db
        .collection('products')
        .where('barcode', isEqualTo: barcode)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final data = doc.data();
    return Product.fromJson({
      ...data,
      'id': data['id'] ?? doc.id,
    });
  }
}
