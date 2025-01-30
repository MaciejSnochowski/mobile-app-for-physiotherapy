import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:physiotherapy/core/theme/theme.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/view/chat/chat_bubble.dart';
import 'package:physiotherapy/viewmodel/chat/chat_viewmodel.dart';
import 'package:provider/provider.dart';

class ChatRoomView extends StatelessWidget {
  // Kontroler do pola tekstowego
  final TextEditingController _messageController = TextEditingController();

  // ViewModel do zarządzania logiką czatu
  late final ChatRoomViewModel _chatViewModel;
  //send message if physiotherapist s

  //send message if userModel
  // Metoda do wysyłania wiadomości
  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatViewModel.sendMessage(_messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inicjalizacja ViewModelu
    _chatViewModel = Provider.of<ChatRoomViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Rozmowa z ${_chatViewModel.reciverFirstName} ${_chatViewModel.reciverLastName}"), //${_chatViewModel.reciverUser.firstName} ${_chatViewModel.reciverUser.lastName}"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            color: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            }),
        backgroundColor: Colors.black38,
      ),
      body: Column(
        children: [
          // Lista wiadomości
          Expanded(
            child: _buildMessageList(_chatViewModel),
          ),
          // Pole do wprowadzania wiadomości
          _buildUserInput(),
        ],
      ),
    );
  }

  // Budowanie listy wiadomości
  Widget _buildMessageList(ChatRoomViewModel chatViewModel) {
    return StreamBuilder(
      stream: chatViewModel.getMessages(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          logger.e("Error in chat_view with message");
          return const Center(
            child: Text("Wystąpił błąd podczas ładowania danych."),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  // Budowanie pojedynczego elementu listy wiadomości
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == _chatViewModel.currentUserId;

    // Ustawienie wyrównania w zależności od nadawcy wiadomości
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["content"],
            isCurrentUser: isCurrentUser,
          ),
        ],
      ),
    );
  }

  // Budowanie pola do wprowadzania wiadomości
  Widget _buildUserInput() {
    return Column(
      children: [
        // Biała linia od góry oddzielająca
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Divider(
            color: Colors.white,
            thickness: 1.0,
            height: 1.0,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            children: [
              // Pole tekstowe
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: TextField(
                    controller: _messageController,
                    cursorColor: Colors.black, // Kolor kursora na czarny
                    style: TextStyle(
                        color: Colors.black), // Kolor tekstu na czarny
                    decoration: InputDecoration(
                      hintText: "Napisz wiadomość",
                      hintStyle: TextStyle(
                          color: Colors
                              .grey), // Kolor tekstu podpowiedzi na czarny
                      filled: true,
                      fillColor: Colors.white, // Białe tło
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // Zaokrąglone rogi
                        borderSide:
                            BorderSide.none, // Brak zewnętrznej krawędzi
                      ),
                    ),
                  ),
                ),
              ),

              // Przycisk do wysyłania wiadomości
              Container(
                decoration: const BoxDecoration(
                    color: AppTheme.TurquoiseLagoon, shape: BoxShape.circle),
                margin: const EdgeInsets.symmetric(horizontal: 10),
                child: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.arrow_upward),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
