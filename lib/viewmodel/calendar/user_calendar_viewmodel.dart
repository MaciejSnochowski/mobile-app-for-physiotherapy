import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/model/physiotherapist.dart';
import 'package:physiotherapy/model/time_segment.dart';
import 'package:physiotherapy/services/session/user_session_service.dart';

class UserCalendarViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _session = UserSessionService();

  Future<List<TimeSegment>?> getDailySchedule(
      String documentId, Physiotherapist physiotherapist) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore
          .collection('Users')
          .doc(physiotherapist.id)
          .collection('schedules')
          .doc(documentId)
          .get();

      if (docSnapshot.exists) {
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

      return null;
    } catch (e) {
      print('Failed to retrieve schedule: $e');
      return null;
    }
  }

  Future<void> changeCalendarMyPhysio(String documentId,
      Physiotherapist physiotherapist, TimeSegment segmentToToggle) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore
          .collection('Users')
          .doc(physiotherapist.id)
          .collection('schedules')
          .doc(documentId)
          .get();
      if (docSnapshot.exists) {
        List<dynamic> segments = docSnapshot.data()?['segments'] ?? [];

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
            segment['occupied'] = !segment['occupied'];
            break;
          }
        }
        await _firestore
            .collection('Users')
            .doc(physiotherapist.id)
            .collection('schedules')
            .doc(documentId)
            .update({'segments': segments});

        await bookTimeSegmenForUser(
            documentId, physiotherapist, segmentToToggle);

        logger.i('Segmentation status changed');
      } else {
        logger.i('Document not found');
      }
    } catch (e) {
      logger.e('Error message: $e');
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

  Future<void> bookTimeSegmenForUser(String documentId,
      Physiotherapist physiotherapist, TimeSegment segmentTime) async {
    try {
      // Konwersja segmentu na mapę z danymi fizjoterapeuty
      Map<String, dynamic> newSegment =
          segmentTime.toMapWithPhysiotherapistData(physiotherapist);

      // Pobieranie istniejącego dokumentu
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore
          .collection('Users')
          .doc(_session.userId)
          .collection('myCalendar')
          .doc(documentId) // data rezerwacji
          .get();

      if (docSnapshot.exists) {
        // Jeśli dokument istnieje, pobierz istniejące segmenty i dodaj nowy segment
        List<dynamic> existingSegments = docSnapshot.data()?['segments'] ?? [];
        existingSegments.add(newSegment);

        await _firestore
            .collection('Users')
            .doc(_session.userId)
            .collection('myCalendar')
            .doc(documentId) // data rezerwacji
            .update({
          'segments': existingSegments
        }); // Aktualizacja istniejącego dokumentu
      } else {
        // Jeśli dokument nie istnieje, utwórz nowy dokument z segmentem
        await _firestore
            .collection('Users')
            .doc(_session.userId)
            .collection('myCalendar')
            .doc(documentId) // data rezerwacji
            .set({
          'segments': [newSegment]
        }); // Utworzenie nowego dokumentu z tablicą segmentów
      }

      logger.i('Segment booked successfully!');
    } catch (e) {
      logger.e('Error while booking time: $e');
    }
  }
}
