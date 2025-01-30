import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/model/user.dart';
import 'package:physiotherapy/services/session/user_session_service.dart';

class HistoryChatViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _session = UserSessionService();
  List<String> chatRoomIds = [];
  Future<Map<String, dynamic>?> searchDocuments(String docId) async {
    try {
      // Wyszukiwanie dokumentów na podstawie pola 'title' w kolekcji 'documents'
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection('Users').doc(docId).get();

      if (documentSnapshot.exists) {
        // Dokument został znaleziony
        return documentSnapshot.data();
      } else {
        // Dokument nie został znaleziony
        logger.e('Dokument o ID $docId nie istnieje.');
        return null;
      }
    } catch (e) {
      // Obsługa błędów
      logger.e('Wystąpił błąd podczas pobierania dokumentu: $e');
      return null;
    }
  }

  Future<List<UserModel>> getListOfUsersFromTheChat() async {
    await getChatRoomsForUser();
    List<UserModel> listOfChatUsers = [];

    for (var ids in chatRoomIds) {
      List<String> parts = ids.split('_');
      parts.removeWhere((item) => item == _session.userId);
      Map<String, dynamic>? data = await searchDocuments(parts[0]);
      if (data != null) {
        listOfChatUsers.add(await UserModel.fromMap(data));
      } else {
        logger.e("Error in history_chat_viewmodel  in findName");
      }
    }
    return listOfChatUsers;
  }

  Future<void> getChatRoomsForUser() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("ChatRoom").get();
      //QuerySnapshot snapshot = await _firestore.collection("ChatRoom").get();
      List<String> chatRoomIds = [];
      for (var doc in snapshot.docs) {
        if (doc.id.contains(_session.userId)) {
          chatRoomIds.add(doc.id);
        }
      }
      this.chatRoomIds = chatRoomIds;
      // return chatRoomIds;
    } catch (e) {
      logger.e("history chat error message: ${e}");
      // return [];
    }
  }
}
