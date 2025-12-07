import 'package:flutter/foundation.dart';
import '../models/order_model.dart';

class OrdersProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];

  List<OrderModel> get orders => _orders;
  List<OrderModel> get buyOrders => _orders.where((o) => o.orderType == 0).toList();
  List<OrderModel> get sellOrders => _orders.where((o) => o.orderType == 1).toList();

  void loadOrders(String userId) {
    _orders = OrderModel.getDummyOrders(userId);
    notifyListeners();
  }

  void addOrder(OrderModel order) {
    _orders.add(order);
    notifyListeners();
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index].status = status.index;
      notifyListeners();
    }
  }
}
