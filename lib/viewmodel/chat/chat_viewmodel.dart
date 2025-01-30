import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:physiotherapy/model/message.dart';
import 'package:physiotherapy/services/session/user_session_service.dart';

class ChatRoomViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // UserModel? _reciverUser;
  // late Physiotherapist? _physiotherapist;
  final _session = UserSessionService();
  late String _reciverId;

  get currentUserId => _session.userId;
  get reciverId => _reciverId;

  // UserModel get reciverUser => _reciverUser!;
  // Physiotherapist get physiotherapist => _physiotherapist!;

  set reciverUser(String value) {
    _reciverId = value;
  }

  late String reciverFirstName;
  late String reciverLastName;

  // set physiotherapist(Physiotherapist value) {
  //   _physiotherapist = value;
  // }
  // void converPhysioToUserModel() {}
  // Future<void> _createChatRoomDocumentIfNotExists(String chatRoomId) async {
  //   DocumentReference chatRoomDocRef =
  //       _firestore.collection("ChatRoom").doc(chatRoomId);

  //   DocumentSnapshot docSnapshot = await chatRoomDocRef.get();
  //   if (!docSnapshot.exists) {
  //     await chatRoomDocRef.set({
  //       'createdAt': FieldValue.serverTimestamp(),
  //       'createdBy': _session.userId,
  //       // Dodaj inne pola, które chcesz tutaj zainicjować
  //     });
  //   }
  // }

  Future<void> sendMessage(String message) async {
    final String currentUserId = _session.userId;
    final String currentUserEmail = _session.currentUser.email;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
        receiverId: reciverId,
        content: message,
        senderEmail: currentUserEmail,
        senderId: currentUserId,
        timestamp: timestamp);
    //chatRoom

    List<String> ids = [currentUserId, reciverId];
    ids.sort();
    String chatRoomID = ids.join('_');
    checkDocument(chatRoomID);
    await _firestore
        .collection("ChatRoom")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  Future<void> checkDocument(String chatRoomID) async {
    DocumentReference chatRoomDocRef =
        _firestore.collection("ChatRoom").doc(chatRoomID);
    DocumentSnapshot docSnapshot = await chatRoomDocRef.get();
    if (!docSnapshot.exists) {
      await _firestore.collection('ChatRoom').doc(chatRoomID).set({});
    }
  }

  Stream<QuerySnapshot> getMessages() {
    String userId = _session.userId;
    List<String> ids = [userId, _reciverId];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection("ChatRoom")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
