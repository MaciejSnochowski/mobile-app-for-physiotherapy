import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/model/physiotherapist.dart';

class PhysiotherapistsViewModel extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Physiotherapist> _physiotherapists = [];

  List<Physiotherapist> get physiotherapists => _physiotherapists;

  Physiotherapist? _physiotherapistFromTheList;
  Physiotherapist get physiotherapistFromTheList =>
      _physiotherapistFromTheList!;

  set physiotherapistFromTheList(Physiotherapist physiotherapists) {
    _physiotherapistFromTheList = physiotherapists;
  }

  Future<void> fetchPhysiotherapists() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Physiotherapists').get();
      _physiotherapists = querySnapshot.docs
          .map((doc) => Physiotherapist.fromMap(
              doc.id.trim(), doc.data() as Map<String, dynamic>))
          .toList();
      try {
        await updateProfileImageUrl();
      } catch (e) {
        logger.e("Problem with updating image profile: ${e}");
      }

      notifyListeners();
    } catch (e) {
      logger.e("Failed to fetch physiotherapists: $e");
    }
  }

  Future<String> getDownloadUrl(String imageName) async {
    try {
      final ref = _storage.ref().child("${imageName}.jpg");

      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      logger.e("Error getting download URL: $e");
      return '';
    }
  }

  Future<void> updateProfileImageUrl() async {
    for (var physio in _physiotherapists) {
      physio.profilePictureUrl = await getDownloadUrl(physio.id);
    }
  }
}
