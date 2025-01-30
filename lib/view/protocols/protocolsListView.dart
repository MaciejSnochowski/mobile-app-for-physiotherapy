import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:physiotherapy/viewmodel/protocols/protocolsViewModel.dart';
import 'package:provider/provider.dart';

class ProtocolsListView extends StatefulWidget {
  @override
  _ProtocolsListViewState createState() => _ProtocolsListViewState();
}

class _ProtocolsListViewState extends State<ProtocolsListView> {
  @override
  void initState() {
    super.initState();
    // Inicjalizacja danych w initState, aby załadować protokoły tylko raz
    Provider.of<ProtocolsViewModel>(context, listen: false).fetchProtocols();
  }

  void _goBack() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
          onPressed: _goBack,
        ),
        backgroundColor: Colors.black38,
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Lista protokołów',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
      body: Consumer<ProtocolsViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.protocols.isEmpty) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: viewModel.protocols.length,
            itemBuilder: (context, index) {
              Reference ref = viewModel.protocols[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Białe tło
                    borderRadius: BorderRadius.circular(12), // Zaokrąglone rogi
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26, // Lekki cień
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text(
                      ref.name,
                      style: TextStyle(
                        color: Colors.black, // Czarny tekst
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: IconButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll<Color>(Colors.black),
                      ),
                      icon: Icon(Icons.downloading_outlined),
                      onPressed: () async {
                        // Tutaj możesz zaimplementować logikę pobierania pliku
                        await viewModel.downloadFile(await ref);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Pobieranie protokołu ${ref.name}')));
                      },
                    ),
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
