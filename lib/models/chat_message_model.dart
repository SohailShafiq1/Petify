import 'package:hive/hive.dart';

part 'chat_message_model.g.dart';

@HiveType(typeId: 2)
class ChatMessageModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String petId;

  @HiveField(2)
  String senderId;

  @HiveField(3)
  String senderName;

  @HiveField(4)
  String message;

  @HiveField(5)
  DateTime timestamp;

  @HiveField(6)
  bool isCurrentUser;

  ChatMessageModel({
    required this.id,
    required this.petId,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isCurrentUser,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isCurrentUser': isCurrentUser,
    };
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      petId: json['petId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isCurrentUser: json['isCurrentUser'] as bool,
    );
  }

  factory ChatMessageModel.fromApi(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final senderId = (json['senderId'] ?? '').toString();
    final timestampValue = json['createdAt'] ?? json['timestamp'];
    final timestamp = timestampValue != null
        ? DateTime.parse(timestampValue.toString())
        : DateTime.now();

    return ChatMessageModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      petId: (json['petId'] ?? '').toString(),
      senderId: senderId,
      senderName: (json['senderName'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      timestamp: timestamp,
      isCurrentUser: senderId == currentUserId,
    );
  }
}
