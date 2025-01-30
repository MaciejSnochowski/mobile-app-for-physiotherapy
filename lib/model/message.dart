import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String? id;
  String senderEmail;
  String senderId;
  String receiverId;
  String content;
  Timestamp timestamp;

  Message({
    this.id,
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toString()
    };
  }

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    return Message(
        id: id,
        senderId: map['senderId'] ?? '',
        senderEmail: map['senderEmail'] ?? '',
        receiverId: map['receiverId'] ?? '',
        content: map['content'] ?? '',
        timestamp: map['timestamp'] ?? Timestamp.now());
  }
}
