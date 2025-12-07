import 'package:hive/hive.dart';

part 'order_model.g.dart';

enum OrderType { buy, sell }
enum OrderStatus { pending, completed, cancelled }

@HiveType(typeId: 3)
class OrderModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String petName;

  @HiveField(3)
  String buyerId;

  @HiveField(4)
  String sellerId;

  @HiveField(5)
  double amount;

  @HiveField(6)
  int orderType; // 0: buy, 1: sell

  @HiveField(7)
  int status; // 0: pending, 1: completed, 2: cancelled

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  String? petImagePath;

  OrderModel({
    required this.id,
    required this.petId,
    required this.petName,
    required this.buyerId,
    required this.sellerId,
    required this.amount,
    required this.orderType,
    required this.status,
    required this.createdAt,
    this.petImagePath,
  });

  OrderType get type => OrderType.values[orderType];
  OrderStatus get orderStatus => OrderStatus.values[status];

  static List<OrderModel> getDummyOrders(String userId) {
    final now = DateTime.now();
    return [
      OrderModel(
        id: 'order_1',
        petId: 'pet_1',
        petName: 'Golden Retriever',
        buyerId: userId,
        sellerId: 'seller_1',
        amount: 500.0,
        orderType: 0, // buy
        status: 1, // completed
        createdAt: now.subtract(const Duration(days: 5)),
        petImagePath: null,
      ),
      OrderModel(
        id: 'order_2',
        petId: 'pet_2',
        petName: 'Persian Cat',
        buyerId: userId,
        sellerId: 'seller_2',
        amount: 350.0,
        orderType: 0, // buy
        status: 1, // completed
        createdAt: now.subtract(const Duration(days: 10)),
        petImagePath: null,
      ),
      OrderModel(
        id: 'order_3',
        petId: 'pet_3',
        petName: 'Beagle Puppy',
        buyerId: 'buyer_1',
        sellerId: userId,
        amount: 600.0,
        orderType: 1, // sell
        status: 1, // completed
        createdAt: now.subtract(const Duration(days: 3)),
        petImagePath: null,
      ),
      OrderModel(
        id: 'order_4',
        petId: 'pet_4',
        petName: 'Siamese Cat',
        buyerId: userId,
        sellerId: 'seller_3',
        amount: 400.0,
        orderType: 0, // buy
        status: 0, // pending
        createdAt: now.subtract(const Duration(hours: 12)),
        petImagePath: null,
      ),
      OrderModel(
        id: 'order_5',
        petId: 'pet_5',
        petName: 'Labrador',
        buyerId: 'buyer_2',
        sellerId: userId,
        amount: 550.0,
        orderType: 1, // sell
        status: 0, // pending
        createdAt: now.subtract(const Duration(hours: 6)),
        petImagePath: null,
      ),
    ];
  }
}
