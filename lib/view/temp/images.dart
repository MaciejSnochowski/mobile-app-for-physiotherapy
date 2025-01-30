import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Images extends StatefulWidget {
  const Images({super.key});
  @override
  State<Images> createState() => _ImagesState();
}

class _ImagesState extends State<Images> {
  String? imageUrl;
  final storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    getImageUrl();
  }

  Future<void> getImageUrl() async {
    try {
      final ref = storage.ref().child('profile1.jpg');
      final url = await ref.getDownloadURL();
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print('Error getting image URL: $e');
      setState(() {
        imageUrl = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Images from Firebase Storage"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  ),
          ),
        ],
      ),
    );
  }
}
