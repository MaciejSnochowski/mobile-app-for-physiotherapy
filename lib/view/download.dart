import 'package:flutter/material.dart';
import 'package:physiotherapy/viewmodel/download.dart';
import 'package:provider/provider.dart';

class FirestoreBackupView extends StatelessWidget {
  final TextEditingController collectionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Backup Firestore Collection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Pole tekstowe do wprowadzenia nazwy kolekcji
            TextField(
              controller: collectionController,
              decoration: InputDecoration(
                labelText: 'Nazwa kolekcji',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Przycisk do wykonania backupu
            ElevatedButton(
              onPressed: () {
                String collectionName = collectionController.text.trim();

                if (collectionName.isNotEmpty) {
                  // Wywołanie funkcji ViewModelu do pobrania danych i zapisania w Firebase Storage
                  Provider.of<FirestoreToStorageViewModel>(context,
                          listen: false)
                      .fetchCollectionToStorage(context, collectionName);
                } else {
                  // Jeśli pole tekstowe jest puste, wyświetlamy błąd
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Błąd'),
                      content: Text('Proszę wprowadzić nazwę kolekcji.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Utwórz Backup'),
            ),
          ],
        ),
      ),
    );
  }
}
