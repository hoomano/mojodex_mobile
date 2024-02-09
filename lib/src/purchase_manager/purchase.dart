import 'package:mojodex_mobile/src/purchase_manager/product.dart';

class Purchase {
  final Product product;
  final int? remainingDays;
  final int? nTasksConsumed;

  Purchase({required this.product, this.remainingDays, this.nTasksConsumed});
}
