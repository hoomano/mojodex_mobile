import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:mojodex_mobile/src/models/http_caller.dart';
import 'package:mojodex_mobile/src/purchase_manager/product.dart';
import 'package:mojodex_mobile/src/purchase_manager/product_category.dart';
import 'package:mojodex_mobile/src/purchase_manager/purchase.dart';

import '../models/user/user.dart';

enum PurchaseEvent { success, canceled, error }

class PurchaseManager extends ChangeNotifier with HttpCaller {
  final Logger logger = Logger('PurchaseManager');

  List<Purchase>? _expiredPurchases;
  List<Purchase>? get expiredPurchases => _expiredPurchases;

  List<Purchase>? _currentPurchases;
  List<Purchase>? get currentPurchases => _currentPurchases;

  List<Product> _purchasableProducts = [];
  List<Product> get purchasableProducts => _purchasableProducts;

  bool _purchaseInitialized = false;
  bool get purchaseInitialized => _purchaseInitialized;

  Future<void> init() async {
    await refreshPurchase();
  }

  Future<bool> activateFreeTrial(int productCategoryPk) async {
    Map<String, dynamic>? newPurchase = await put(
        service: 'associate_free_product',
        body: {'product_category_pk': productCategoryPk});
    if (newPurchase == null) return false;
    _currentPurchases = (newPurchase['current_purchases'] as List<dynamic>)
        .map((purchase) => Purchase(
            remainingDays: purchase['remaining_days'],
            nTasksConsumed: purchase['n_tasks_consumed'],
            product: Product(
                name: purchase['product_name'],
                tasks: purchase['tasks'].cast<String>(),
                isFree: purchase['is_free_product'],
                nValidityDays: purchase['n_validity_days'],
                nTasksLimit: purchase['n_tasks_limit'])))
        .toList();
    _purchasableProducts =
        (newPurchase['purchasable_products'] as List<dynamic>)
            .map((product) => Product(
                  name: product['name'],
                  tasks: product['tasks'].cast<String>(),
                  isFree: false,
                  nValidityDays: product['n_validity_days'],
                  nTasksLimit: product['n_tasks_limit'],
                  productStripeId: product['product_stripe_id'],
                  productAppleId: product['product_apple_id'],
                  stripePrice: product['stripe_price'],
                ))
            .toList();
    await User().userTasksList.reloadItems();
    notifyListeners();
    return true;
  }

  List<ProductCategory> _productCategories = [];
  List<ProductCategory> get productCategories => _productCategories;
  Future<void> getProductCategories() async {
    Map<String, dynamic>? categories =
        await get(service: 'product_category', params: '');
    if (categories == null) return;
    _productCategories = (categories['product_categories'] as List<dynamic>)
        .map((category) => ProductCategory(
              productCategoryPk: category['product_category_pk'],
              name: category['name'],
              emoji: category['emoji'],
              description: category['description'],
            ))
        .toList();
  }

  Future<void> cancelSubscription() async {
    logger.shout('Cancel subscription not implemented');
  }

  Future<Map<String, dynamic>?> _getCurrentPurchase() async {
    String params = "datetime=${DateTime.now().toIso8601String()}";
    return await get(service: 'purchase', params: params);
  }

  Future<void> refreshPurchase() async {
    try {
      Map<String, dynamic>? purchaseState = await _getCurrentPurchase();
      if (purchaseState == null) return;
      if (purchaseState['current_purchases'] != null) {
        _currentPurchases =
            (purchaseState['current_purchases'] as List<dynamic>)
                .map((purchase) => Purchase(
                    remainingDays: purchase['remaining_days'],
                    nTasksConsumed: purchase['n_tasks_consumed'],
                    product: Product(
                        name: purchase['product_name'],
                        tasks: purchase['tasks'].cast<String>(),
                        isFree: purchase['is_free_product'],
                        nValidityDays: purchase['n_validity_days'],
                        nTasksLimit: purchase['n_tasks_limit'])))
                .toList();
      }
      _purchasableProducts =
          (purchaseState['purchasable_products'] as List<dynamic>)
              .map((product) => Product(
                    name: product['name'],
                    tasks: product['tasks'].cast<String>(),
                    isFree: false,
                    nValidityDays: product['n_validity_days'],
                    nTasksLimit: product['n_tasks_limit'],
                    productStripeId: product['product_stripe_id'],
                    productAppleId: product['product_apple_id'],
                    stripePrice: product['stripe_price'],
                  ))
              .toList();
      _expiredPurchases =
          (purchaseState['last_expired_purchase'] as List<dynamic>)
              .map((purchase) => Purchase(
                  remainingDays: purchase['remaining_days'],
                  nTasksConsumed: purchase['n_tasks_consumed'],
                  product: Product(
                      name: purchase['product_name'],
                      tasks: purchase['tasks'].cast<String>(),
                      isFree: purchase['is_free_product'],
                      nValidityDays: purchase['n_validity_days'],
                      nTasksLimit: purchase['n_tasks_limit'])))
              .toList();

      _purchaseInitialized = true;
      await User().userTasksList.loadMoreItems(offset: 0);
      //await User().userWorkflowsList.loadMoreItems(offset: 0);
      notifyListeners();
    } catch (e) {
      logger.severe("Error while refreshing purchase: $e");
    }
  }

  Future<void> contactUsForPurchase() async {
    logger.shout("ContactUsForPurchase not implemented");
  }
}
