import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physiotherapy/services/session/user_session_service.dart';

class HomeViewmodel extends ChangeNotifier {
  final _sessionService = UserSessionService();

  String get id => _sessionService.currentUser.id;
  String getName() {
    return _sessionService.userName;
  }

  bool? getPhysio() {
    return _sessionService.isPhysiotherapist;
  }

  String getFormattedDate() {
    // Pobiera dzisiejszą datę
    final now = DateTime.now();
    //(2024, 6, 3);
    // Formatuje datę
    final formatter = DateFormat('dd MMM, yyyy', 'pl_PL');
    return formatter.format(now);
  }
}
