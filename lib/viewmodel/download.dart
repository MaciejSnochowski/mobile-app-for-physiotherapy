import 'dart:convert'; // Do konwersji na JSON
import 'dart:io'; // Do pracy z plikami
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart'; // Do zapisu pliku lokalnie

class FirestoreToStorageViewModel extends ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Funkcja pobierająca zadaną kolekcję i zapisująca ją do Firebase Storage
  Future<void> fetchCollectionToStorage(
      BuildContext context, String collectionName) async {
    try {
      collectionName = "Users";
      // Lista map do przechowywania danych dokumentów
      List<Map<String, dynamic>> allData = [];

      // Pobieranie dokumentów z kolekcji o podanej nazwie
      final CollectionReference collection =
          _firestore.collection(collectionName);
      final QuerySnapshot querySnapshot = await collection.get();

      List<Map<String, dynamic>> documents = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'data': doc.data(),
              })
          .toList();

      allData.add({
        'collection': collection.id,
        'documents': documents,
      });

      // Konwertowanie danych na format JSON
      String jsonData = jsonEncode(allData);

      // Zapis pliku lokalnie (tymczasowo)
      Directory tempDir = await getTemporaryDirectory();
      File jsonFile =
          File('${tempDir.path}/firestoreBackup_$collectionName.json');
      await jsonFile.writeAsString(jsonData);

      // Przesyłanie pliku JSON do Firebase Storage
      await _uploadFileToStorage(
          jsonFile, 'backups/firestoreBackup_$collectionName.json');

      // Wyświetlanie komunikatu o sukcesie
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Sukces'),
          content: Text(
              'Dane kolekcji "$collectionName" zostały pomyślnie przesłane do Firebase Storage.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Obsługa błędów
      print("Błąd podczas przesyłania danych do Firebase Storage: $e");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Błąd'),
          content: Text(
              'Wystąpił błąd podczas przesyłania danych dla kolekcji "$collectionName".'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Funkcja do przesyłania pliku do Firebase Storage
  Future<void> _uploadFileToStorage(File file, String path) async {
    try {
      Reference storageRef = _storage.ref().child(path);
      await storageRef.putFile(file);
      print("Plik został pomyślnie przesłany do Firebase Storage.");
    } catch (e) {
      print("Błąd podczas przesyłania pliku: $e");
      throw e;
    }
  }
}
