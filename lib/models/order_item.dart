import 'product.dart';

class OrderItem {
  final Product product;
  final int quantity;
  final String customerType;

  const OrderItem({
    required this.product,
    required this.quantity,
    required this.customerType,
  });

  double get unitPrice => product.priceForCustomerType(customerType);
  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'barcode': product.barcode,
      'category': product.category,
      'moq': product.moq,
      'quantity': quantity,
      'customerType': customerType,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
    };
  }
}
