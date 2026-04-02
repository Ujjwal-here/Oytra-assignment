class Product {
  final String id;
  final String name;
  final double basePrice;
  final int moq;
  final String category;
  final String barcode;

  const Product({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.moq,
    required this.category,
    required this.barcode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final price = _asNum(json['basePrice']) ??
        _asNum(json['base_price']) ??
        _asNum(json['price']);
    final moqRaw = _asNum(json['moq']) ?? _asNum(json['minimumOrderQuantity']);
    final moq = (moqRaw ?? 1).round().clamp(1, 999999);

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      basePrice: price?.toDouble() ?? 0.0,
      moq: moq,
      category: json['category']?.toString() ?? '',
      barcode:
          json['barcode']?.toString() ?? json['sku']?.toString() ?? '',
    );
  }

  static num? _asNum(dynamic v) {
    if (v is num) return v;
    return null;
  }

  double priceForCustomerType(String customerType) {
    if (customerType == 'Dealer') {
      return basePrice * 0.85;
    }
    return basePrice;
  }
}
