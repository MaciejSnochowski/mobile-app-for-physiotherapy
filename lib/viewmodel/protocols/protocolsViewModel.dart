import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:physiotherapy/main.dart';

class ProtocolsViewModel extends ChangeNotifier {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  List<Reference> _protocols = [];

  List<Reference> get protocols => _protocols;
  Future<void> fetchProtocols() async {
    try {
      final ListResult result = await _storage.ref('/protocols').listAll();

      _protocols = result.items;
      logger.i("downloded");
      notifyListeners();
    } catch (e) {
      logger.e("Error fetching protocols: $e");
    }
  }

  Future<void> downloadFile(Reference ref) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      try {
        final Directory downloadsDir =
            Directory('/storage/emulated/0/Download');
        final String filePath = '${downloadsDir.path}/${ref.name}';
        final File file = File(filePath);

        await ref.writeToFile(file);

        if (await file.exists()) {
          logger.i('File successfully saved at $filePath');
        } else {
          logger.i('File not found at $filePath');
        }
        logger.i('Downloading file and saving in: $filePath');
      } catch (e) {
        logger.e('Error downloading file: $e');
      }
    } else {
      logger.e('Storage permission not granted');
    }
  }
}
