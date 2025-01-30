import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:physiotherapy/model/time_segment.dart';
import 'package:physiotherapy/services/session/user_session_service.dart';
import 'package:table_calendar/table_calendar.dart';

class PatientCalendarViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _sessionService = UserSessionService();

  DateTime? _selectedDay;
  DateTime? get selectedDay => _selectedDay;

  DateTime _focusedDay = DateTime.now();
  DateTime get focusedDay => _focusedDay;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  CalendarFormat get calendarFormat => _calendarFormat;

  Future<List<TimeSegment>?>? _segmentsFuture;
  Future<List<TimeSegment>?>? get segmentsFuture => _segmentsFuture;

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    _segmentsFuture = fetchSegmentsForDay(selectedDay);
    notifyListeners();
  }

  void onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      _calendarFormat = format;
      notifyListeners();
    }
  }

  void onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    notifyListeners();
  }

  Future<List<TimeSegment>?> fetchSegmentsForDay(DateTime day) async {
    String dayToFetch = day.toIso8601String();
    DocumentSnapshot<Map<String, dynamic>> docSnapshot = await _firestore
        .collection('Users')
        .doc(_sessionService.currentUser.id)
        .collection('myCalendar')
        .doc(dayToFetch)
        .get();

    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      if (data != null && data.containsKey('segments')) {
        List<dynamic> segmentsData = data['segments'];
        List<TimeSegment> segments = segmentsData
            .map((segmentData) => TimeSegment.fromMapWithPhysio(segmentData))
            .toList();
        return segments;
      }
    }
    return []; // Zwraca pustą listę, jeśli brak segmentów
  }
}
