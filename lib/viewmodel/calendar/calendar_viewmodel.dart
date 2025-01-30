import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/model/daily_schedule.dart';
import 'package:physiotherapy/model/duration_time.dart';
import 'package:physiotherapy/model/time_segment.dart';
import 'package:physiotherapy/services/session/user_session_service.dart';

class CalendarViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TimeOfDay? selectedStartTime;
  TimeOfDay? selectedEndTime;
  DurationTime? selectedDurationTime;
  DateTime? selectedDateTime;
  final _sessionService = UserSessionService();

  Future<void> toggleSegmentOccupiedStatus(
      String documentId, TimeSegment segmentToToggle) async {
    try {
      // Pobranie dokumentu z Firestore
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore
          .collection('Users') // Kolekcja z fizjoterapeutami
          .doc(_sessionService
              .currentUser.id) // Dokument odpowiadający danemu fizjoterapeucie
          .collection('schedules') // Podkolekcja `schedules`
          .doc(documentId) // Użycie `documentId` jako nazwy dokumentu
          .get();

      if (docSnapshot.exists) {
        // Pobranie aktualnej listy segmentów
        List<dynamic> segments = docSnapshot.data()?['segments'] ?? [];

        // Znalezienie segmentu do zmiany
        for (var segment in segments) {
          final String startTimeStr =
              segmentToToggle.startTime.hour.toString().padLeft(2, '0') +
                  ':' +
                  segmentToToggle.startTime.minute.toString().padLeft(2, '0');
          final String endTimeStr =
              segmentToToggle.endTime.hour.toString().padLeft(2, '0') +
                  ':' +
                  segmentToToggle.endTime.minute.toString().padLeft(2, '0');

          if (segment['startTime'] == startTimeStr &&
              segment['endTime'] == endTimeStr) {
            // Zmieniamy wartość occupied na przeciwną
            segment['occupied'] = !segment['occupied'];
            break;
          }
        }

        // Zapisanie zaktualizowanej listy segmentów z powrotem do Firestore
        await _firestore
            .collection('Users')
            .doc(_sessionService.currentUser.id)
            .collection('schedules')
            .doc(documentId)
            .update({'segments': segments});

        logger.i('Status segmentu zmieniony pomyślnie');
      } else {
        logger.i('Dokument nie istnieje');
      }
    } catch (e) {
      logger.e('Błąd podczas zmiany statusu segmentu: $e');
    }
  }

  Future<void> removeSegmentFromDocument(
      String documentId, TimeSegment segmentToRemove) async {
    try {
      // Pobranie dokumentu z Firestore
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore
          .collection('Users') // Kolekcja z fizjoterapeutami
          .doc(_sessionService
              .currentUser.id) // Dokument odpowiadający danemu fizjoterapeucie
          .collection('schedules') // Podkolekcja `schedules`
          .doc(documentId) // Użycie `documentId` jako nazwy dokumentu
          .get();

      if (docSnapshot.exists) {
        // Pobranie aktualnej listy segmentów
        List<dynamic> segments = docSnapshot.data()?['segments'] ?? [];

        // Usunięcie obiektu z listy
        segments.removeWhere((segment) {
          final String startTimeStr =
              segmentToRemove.startTime.hour.toString().padLeft(2, '0') +
                  ':' +
                  segmentToRemove.startTime.minute.toString().padLeft(2, '0');
          final String endTimeStr =
              segmentToRemove.endTime.hour.toString().padLeft(2, '0') +
                  ':' +
                  segmentToRemove.endTime.minute.toString().padLeft(2, '0');

          return segment['startTime'] == startTimeStr &&
              segment['endTime'] == endTimeStr &&
              segment['occupied'] == segmentToRemove.occupied;
        });

        // Zapisanie zaktualizowanej listy segmentów z powrotem do Firestore
        await _firestore
            .collection('Users')
            .doc(_sessionService.currentUser.id)
            .collection('schedules')
            .doc(documentId)
            .update({'segments': segments});

        logger.i('Segment usunięty pomyślnie');
      } else {
        logger.i('Dokument nie istnieje');
      }
    } catch (e) {
      logger.e('Błąd podczas usuwania segmentu: $e');
    }
  }

  List<TimeSegment> convertMapToTimeSegments(Map<String, dynamic> map) {
    if (map['segments'] != null) {
      // Pobieramy listę segmentów jako List<dynamic> i mapujemy na List<TimeSegment>
      List<dynamic> segmentsMap = map['segments'];
      return segmentsMap
          .map((segmentMap) => TimeSegment.fromMap(segmentMap))
          .toList();
    } else {
      return []; // Jeśli nie ma segmentów, zwracamy pustą listę
    }
  }

  Future<List<TimeSegment>?> getDailySchedule(String documentId) async {
    try {
      // Pobieranie dokumentu z Firestore
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore
          .collection('Users') // Kolekcja z fizjoterapeutami
          .doc(_sessionService
              .currentUser.id) // Dokument odpowiadający danemu fizjoterapeucie
          .collection('schedules') // Podkolekcja `schedules`
          .doc(documentId) // Użycie `documentId` jako nazwy dokumentu
          .get();

      if (docSnapshot.exists) {
        // Jeśli dokument istnieje, mapujemy dane na obiekt DailySchedule
        Map<String, dynamic>? data = docSnapshot.data();

        if (data != null) {
          List<TimeSegment> segments = convertMapToTimeSegments(data);
          for (var segment in segments) {
            logger.i(
                'Start: ${segment.startTime}, End: ${segment.endTime}, Occupied: ${segment.occupied}');
          }
          return segments;
        }
      }

      // Jeśli dokument nie istnieje, zwróć null
      return null;
    } catch (e) {
      print('Failed to retrieve schedule: $e');
      return null;
    }
  }

  Future<void> createDailySchedule(DateTime dateTime, TimeOfDay startTime,
      TimeOfDay endTime, DurationTime durationTime) async {
    try {
      // Tworzenie obiektu DailySchedule
      DailySchedule day = DailySchedule(
        timeDuration: durationTime,
        date: dateTime,
        startTime: startTime,
        endTime: endTime,
      );

      // Mapowanie obiektu DailySchedule do formatu Map
      Map<String, dynamic> segments = day.toMapSegments();

      // Generowanie unikalnego identyfikatora na podstawie `dateTime`
      String documentId = dateTime.toIso8601String();

      // Zapisywanie dokumentu w kolekcji `schedules` pod ID danego fizjoterapeuty
      await _firestore
          .collection('Users') // Kolekcja z fizjoterapeutami
          .doc(_sessionService
              .currentUser.id) // Dokument odpowiadający danemu fizjoterapeucie
          .collection('schedules') // Podkolekcja `schedules`
          .doc(documentId) // Użycie `documentId` jako nazwy dokumentu
          .set(segments); // Ustawienie dokumentu z mapą danych

      logger.i('Schedule saved successfully!');
    } catch (e) {
      logger.e('Failed to save schedule: $e');
    }
  }

  void updateSelectedTimes(DateTime dateTime, TimeOfDay startTime,
      TimeOfDay endTime, DurationTime durationTime) {
    selectedStartTime = startTime;
    selectedEndTime = endTime;
    selectedDurationTime = durationTime;
    selectedDateTime = dateTime;
    notifyListeners();
  }
}
