import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/order_item.dart';

class OrderProvider extends ChangeNotifier {
  String _customerType = 'Retail';
  final List<OrderItem> _items = [];

  String get customerType => _customerType;
  List<OrderItem> get items => List.unmodifiable(_items);

  double get grandTotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get itemCount => _items.length;

  void setCustomerType(String type) {
    _customerType = type;
    final updated = _items
        .map(
          (i) => OrderItem(
            product: i.product,
            quantity: i.quantity,
            customerType: type,
          ),
        )
        .toList();
    _items
      ..clear()
      ..addAll(updated);
    notifyListeners();
  }

  String? addItem(Product product, int quantity) {
    if (quantity < product.moq) {
      return 'Minimum order quantity is ${product.moq} units';
    }

    final existingIndex = _items.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      final prev = _items[existingIndex].quantity;
      _items[existingIndex] = OrderItem(
        product: product,
        quantity: prev + quantity,
        customerType: _customerType,
      );
    } else {
      _items.add(
        OrderItem(
          product: product,
          quantity: quantity,
          customerType: _customerType,
        ),
      );
    }
    notifyListeners();
    return null;
  }

  void removeItem(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void clearOrder() {
    _items.clear();
    notifyListeners();
  }
}
