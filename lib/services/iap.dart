// Single IAP: "Buy Me a Coffee" ($0.99, consumable-style non-consumable).
import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class CoffeeIap {
  static const productId = 'qavexdominoeselitecoffee';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  bool available = false;
  ProductDetails? product;
  void Function()? onCoffeeBought;

  Future<void> init({void Function()? onCoffeeBought}) async {
    this.onCoffeeBought = onCoffeeBought;
    available = await _iap.isAvailable();
    if (!available) return;
    final resp = await _iap.queryProductDetails({productId});
    if (resp.productDetails.isNotEmpty) product = resp.productDetails.first;
    _sub = _iap.purchaseStream.listen(_onPurchases,
        onError: (_) {}, onDone: () {});
  }

  void _onPurchases(List<PurchaseDetails> list) {
    for (final p in list) {
      if (p.productID == productId &&
          (p.status == PurchaseStatus.purchased ||
              p.status == PurchaseStatus.restored)) {
        onCoffeeBought?.call();
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
  }

  Future<bool> buy() async {
    if (!available || product == null) return false;
    final param = PurchaseParam(productDetails: product!);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    if (available) await _iap.restorePurchases();
  }

  Future<void> dispose() async => _sub?.cancel();
}
