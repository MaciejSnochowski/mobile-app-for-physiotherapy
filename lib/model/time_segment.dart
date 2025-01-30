import 'package:flutter/material.dart';
import 'package:physiotherapy/model/physiotherapist.dart';

class TimeSegment {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  bool? occupied;
  String? specialistName;

  TimeSegment(
      {required this.startTime,
      required this.endTime,
      this.occupied = false,
      this.specialistName});

  Map<String, dynamic> toMap() {
    return {
      'startTime':
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime':
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'occupied': occupied,
    };
  }

  Map<String, dynamic> toMapWithPhysiotherapistData(
      Physiotherapist physiotherapist) {
    return {
      'startTime':
          '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      'endTime':
          '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'occupied': occupied,
      'fullName':
          '${physiotherapist.name} ${physiotherapist.lastName}', // Dodanie pełnego imienia i nazwiska fizjoterapeuty
    };
  }

  // Konwersja mapy na obiekt
  factory TimeSegment.fromMap(Map<String, dynamic> map) {
    final startTimeParts = map['startTime'].split(':');
    final endTimeParts = map['endTime'].split(':');
    return TimeSegment(
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      occupied: map['occupied'],
    );
  }

  factory TimeSegment.fromMapWithPhysio(Map<String, dynamic> map) {
    final startTimeParts = map['startTime'].split(':');
    final endTimeParts = map['endTime'].split(':');
    final specialistName = map['fullName'].split(':');
    return TimeSegment(
      startTime: TimeOfDay(
        hour: int.parse(startTimeParts[0]),
        minute: int.parse(startTimeParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endTimeParts[0]),
        minute: int.parse(endTimeParts[1]),
      ),
      specialistName: map['fullName'],
    );
  }
}

// Funkcja doMapWithPhysiotherapistData dla listy segmentów
Map<String, dynamic> segmentsToMapWithPhysiotherapistData(
    List<TimeSegment> segments, Physiotherapist physiotherapist) {
  return {
    'segments': segments
        .map((segment) => segment.toMapWithPhysiotherapistData(physiotherapist))
        .toList(),
  };
}
