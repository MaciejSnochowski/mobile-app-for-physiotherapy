import 'package:flutter/material.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/model/user.dart';
import 'package:physiotherapy/viewmodel/chat/chat_viewmodel.dart';
import 'package:physiotherapy/viewmodel/chat/history_chat_viewmodel.dart';
import 'package:provider/provider.dart';

class HistoryChatView extends StatelessWidget {
  // Kontroler do pola tekstowego

  // Metoda do wysyłania wiadomości
  @override
  Widget build(BuildContext context) {
    // Inicjalizacja ViewModelu
    final _historyChatView = Provider.of<HistoryChatViewModel>(context);
    final _chatViewModel = Provider.of<ChatRoomViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Historia rozmów"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            color: Colors.white,
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            }),
        backgroundColor: Colors.black38,
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _historyChatView.getListOfUsersFromTheChat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Wystąpił błąd.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Brak rozmów w historii'));
          }

          final users = snapshot.data!;
          //_historyChatView.findName();

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              logger.e("$user user datafrom view");

              return GestureDetector(
                onTap: () {
                  _chatViewModel.reciverUser = user.id;
                  _chatViewModel.reciverFirstName = user.firstName;
                  _chatViewModel.reciverLastName = user.lastName!;
                  Navigator.pushNamed(context, '/chat');
                },
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Rozmowa z ${user.firstName} ${user.lastName} ',
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
