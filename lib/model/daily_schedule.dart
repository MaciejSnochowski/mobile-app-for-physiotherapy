// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/model/duration_time.dart';
import 'package:physiotherapy/model/time_segment.dart';

class DailySchedule {
  DurationTime timeDuration;
  DateTime date;
  TimeOfDay startTime;
  TimeOfDay endTime;
  List<TimeSegment> segments = [];

  DailySchedule({
    this.timeDuration = DurationTime.minutes30,
    required this.date,
    required this.startTime,
    required this.endTime,
  }) {
    int spreadTime = 0;

    if (timeDuration == DurationTime.minutes15) {
      spreadTime = 15;
    } else if (timeDuration == DurationTime.minutes30) {
      spreadTime = 30;
    } else if (timeDuration == DurationTime.minutes60) {
      spreadTime = 60;
    }

    TimeOfDay currentStartTime = startTime;

    while (isBeforeOrEqual(currentStartTime, endTime)) {
      TimeOfDay currentEndTime =
          addMinutesToTimeOfDay(currentStartTime, spreadTime);
      if (isBeforeOrEqual(currentEndTime, endTime)) {
        segments.add(TimeSegment(
          startTime: currentStartTime,
          endTime: currentEndTime,
        ));
      } else {
        logger.i(segments.length);
      }
      currentStartTime = currentEndTime;
    }
  }

  TimeOfDay addMinutesToTimeOfDay(TimeOfDay time, int minutesToAdd) {
    int totalMinutes = time.hour * 60 + time.minute + minutesToAdd;
    totalMinutes = totalMinutes % 1440;
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;
    return TimeOfDay(hour: hours, minute: minutes);
  }

  bool isBeforeOrEqual(TimeOfDay t1, TimeOfDay t2) {
    return t1.hour < t2.hour || (t1.hour == t2.hour && t1.minute <= t2.minute);
  }

  Map<String, dynamic> toMapSegments() {
    return {
      // 'time': timeDuration.toString().split('.').last,
      //  'date': date.toIso8601String(),
      // 'startTime':
      //     '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
      // 'endTime':
      //     '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
      'segments': segments.map((segment) => segment.toMap()).toList(),
    };
  }

//  static DailySchedule fromMap(Map<String, dynamic> data) {}
}
