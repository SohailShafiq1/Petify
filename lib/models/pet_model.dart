import 'package:hive/hive.dart';

part 'pet_model.g.dart';

@HiveType(typeId: 1)
class PetModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category;

  @HiveField(3)
  int age;

  @HiveField(4)
  String description;

  @HiveField(5)
  String? breed;

  @HiveField(6)
  double price;

  @HiveField(7)
  String ownerName;

  @HiveField(8)
  String ownerContact;

  @HiveField(9)
  String? imagePath;

  @HiveField(10)
  String ownerId;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  bool isAvailable;

  @HiveField(13)
  String? buyerName;

  @HiveField(14)
  String? buyerContact;

  @HiveField(15)
  String? buyerAddress;

  @HiveField(16)
  DateTime? soldAt;

  @HiveField(17)
  String? buyerId;

  @HiveField(18)
  String? deliveryStatus;

  @HiveField(19)
  DateTime? deliveredAt;

  List<Map<String, dynamic>>? reviews;

  PetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.age,
    required this.description,
    this.breed,
    required this.price,
    required this.ownerName,
    required this.ownerContact,
    required this.ownerId,
    this.imagePath,
    DateTime? createdAt,
    this.isAvailable = true,
    this.buyerName,
    this.buyerContact,
    this.buyerAddress,
    this.soldAt,
    this.buyerId,
    this.deliveryStatus,
    this.deliveredAt,
    this.reviews,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'age': age,
      'description': description,
      'price': price,
      'ownerName': ownerName,
      'ownerContact': ownerContact,
      'ownerId': ownerId,
      'imagePath': imagePath,
      'createdAt': createdAt.toIso8601String(),
      'isAvailable': isAvailable,
      'buyerName': buyerName,
      'buyerContact': buyerContact,
      'buyerAddress': buyerAddress,
      'soldAt': soldAt?.toIso8601String(),
      'buyerId': buyerId,
      'deliveryStatus': deliveryStatus,
      'deliveredAt': deliveredAt?.toIso8601String(),
      'reviews': reviews,
    };
  }

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] as String,
      category: json['category'] as String,
      age: json['age'] as int,
      description: json['description'] as String,
      breed: json['breed'] as String?,
      price: (json['price'] as num).toDouble(),
      ownerName: json['ownerName'] as String,
      ownerContact: json['ownerContact'] as String,
      ownerId: json['ownerId'] as String,
      imagePath: json['imageUrl'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : null,
      isAvailable: json['isAvailable'] as bool? ?? true,
      buyerName: json['buyerName'] as String?,
      buyerContact: json['buyerContact'] as String?,
      buyerAddress: json['buyerAddress'] as String?,
      soldAt: json['soldAt'] != null ? DateTime.parse(json['soldAt'] as String) : null,
      buyerId: json['buyerId'] as String?,
      deliveryStatus: json['deliveryStatus'] as String?,
      deliveredAt: json['deliveredAt'] != null ? DateTime.parse(json['deliveredAt'] as String) : null,
      reviews: (json['reviews'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .toList(),
    );
  }
}
