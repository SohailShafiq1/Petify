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
  double price;

  @HiveField(6)
  String ownerName;

  @HiveField(7)
  String ownerContact;

  @HiveField(8)
  String? imagePath;

  @HiveField(9)
  String ownerId;

  @HiveField(10)
  DateTime createdAt;

  PetModel({
    required this.id,
    required this.name,
    required this.category,
    required this.age,
    required this.description,
    required this.price,
    required this.ownerName,
    required this.ownerContact,
    required this.ownerId,
    this.imagePath,
    DateTime? createdAt,
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
    };
  }

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      age: json['age'] as int,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      ownerName: json['ownerName'] as String,
      ownerContact: json['ownerContact'] as String,
      ownerId: json['ownerId'] as String,
      imagePath: json['imagePath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
