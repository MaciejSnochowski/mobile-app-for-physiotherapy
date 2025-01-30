import 'package:flutter/material.dart';
import 'package:physiotherapy/core/theme/theme.dart';
import 'package:physiotherapy/view/calendar/calendar_for_user.dart';
import 'package:physiotherapy/viewmodel/chat/chat_viewmodel.dart';
import 'package:physiotherapy/viewmodel/physiotherapists_list/physiotherapists_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart'; // Importuj ten moduł do obsługi kliknięć

class PhysiotherapistsListView extends StatefulWidget {
  @override
  _PhysiotherapistsListViewState createState() =>
      _PhysiotherapistsListViewState();
}

class _PhysiotherapistsListViewState extends State<PhysiotherapistsListView> {
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    // Wywołanie fetchPhysiotherapists tylko raz i zapisanie Future
    final physiotherapistsViewModel =
        Provider.of<PhysiotherapistsViewModel>(context, listen: false);
    _fetchFuture = physiotherapistsViewModel.fetchPhysiotherapists();
  }

  @override
  Widget build(BuildContext context) {
    final physiotherapistsViewModel =
        Provider.of<PhysiotherapistsViewModel>(context);
    final _chatViewModel = Provider.of<ChatRoomViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
        backgroundColor: Colors.black38,
        title: Text("Lista fizjoterapeutów"),
      ),
      body: FutureBuilder(
        future: _fetchFuture, // Użycie przechowywanego Future
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text("Wystąpił błąd podczas ładowania danych."));
          }

          return ListView.builder(
            itemCount: physiotherapistsViewModel.physiotherapists.length,
            itemBuilder: (context, index) {
              final physio = physiotherapistsViewModel.physiotherapists[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(physio.profilePictureUrl),
                    ),
                    SizedBox(width: 16.0), // Odstęp między zdjęciem a tekstem
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${physio.name} ${physio.lastName}',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.0), // Odstęp między nazwą a bio
                          _buildShortBio(
                              physio.bio), // Użycie metody do budowy bio
                          SizedBox(
                              height: 8.0), // Odstęp między bio a przyciskiem
                          ElevatedButton(
                            onPressed: () {
                              //rejestruje w providerze physio
                              //potem wyciagam go w nowym w
                              physiotherapistsViewModel
                                  .physiotherapistFromTheList = physio;
                              _chatViewModel.reciverFirstName = physio.name;
                              _chatViewModel.reciverLastName = physio.lastName;
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => UserCalendarView(),
                                ),
                              );
                            },
                            child: Text("Zobacz kalendarz"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildShortBio(String bio) {
    List<String> words = bio.split(' ');
    if (words.length <= 10) {
      return Text(bio);
    } else {
      return RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black),
          children: [
            TextSpan(text: words.sublist(0, 8).join(' ') + '... '),
            TextSpan(
              text: 'zobacz więcej',
              style: TextStyle(color: AppTheme.TurquoiseLagoon),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _showBioDialog(context, bio); // Wyświetl pełne bio
                },
            ),
          ],
        ),
      );
    }
  }

  void _showBioDialog(BuildContext context, String bio) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Pełne bio"),
          content: Text(bio),
          actions: [
            TextButton(
              child: Text("Zamknij"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
