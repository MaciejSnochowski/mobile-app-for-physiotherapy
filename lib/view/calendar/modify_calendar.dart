import 'package:flutter/material.dart';
import 'package:physiotherapy/core/theme/theme.dart';
import 'package:physiotherapy/model/duration_time.dart';
import 'package:physiotherapy/model/time_segment.dart';
import 'package:physiotherapy/viewmodel/calendar/calendar_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime today = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  late Future<List<TimeSegment>?> _segmentsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _segmentsFuture = Future.value(null);
  }

  bool _isDaySelectable(DateTime day) {
    return day.isAfter(today.subtract(Duration(days: 1))) &&
        day.weekday != DateTime.saturday &&
        day.weekday != DateTime.sunday;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!_isDaySelectable(selectedDay)) {
      return;
    }

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;

      final calendarViewModel =
          Provider.of<CalendarViewModel>(context, listen: false);
      _segmentsFuture =
          calendarViewModel.getDailySchedule(_selectedDay!.toIso8601String());
    });
  }

  void _goBack() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _showSelectedDayPopup(CalendarViewModel calendarViewModel) {
    TimeOfDay? selectedStartTime = TimeOfDay(hour: 8, minute: 0);
    TimeOfDay? selectedEndTime = TimeOfDay(hour: 14, minute: 0);
    DurationTime? selectedDurationTime = DurationTime.minutes30;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                  'Zaznaczony dzień: ${_selectedDay?.toString().split(' ')[0]}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<TimeOfDay>(
                    value: selectedStartTime,
                    onChanged: (TimeOfDay? newValue) {
                      setState(() {
                        selectedStartTime = newValue;
                      });
                    },
                    items: List.generate(10, (index) {
                      final time = TimeOfDay(hour: index + 8, minute: 0);
                      return DropdownMenuItem<TimeOfDay>(
                        value: time,
                        child: Text(
                          MaterialLocalizations.of(context).formatTimeOfDay(
                              time,
                              alwaysUse24HourFormat: true),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<TimeOfDay>(
                    value: selectedEndTime,
                    onChanged: (TimeOfDay? newValue) {
                      setState(() {
                        selectedEndTime = newValue;
                      });
                    },
                    items: List.generate(10, (index) {
                      final time = TimeOfDay(hour: index + 8, minute: 0);
                      return DropdownMenuItem<TimeOfDay>(
                        value: time,
                        child: Text(
                          MaterialLocalizations.of(context).formatTimeOfDay(
                              time,
                              alwaysUse24HourFormat: true),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 10),
                  DropdownButton<DurationTime>(
                    value: selectedDurationTime,
                    onChanged: (DurationTime? newValue) {
                      setState(() {
                        selectedDurationTime = newValue!;
                      });
                    },
                    items: DurationTime.values.map((DurationTime duration) {
                      String formattedDuration;
                      switch (duration) {
                        case DurationTime.minutes15:
                          formattedDuration = '15 minut';
                          break;
                        case DurationTime.minutes30:
                          formattedDuration = '30 minut';
                          break;
                        case DurationTime.minutes60:
                          formattedDuration = '60 minut';
                          break;
                      }
                      return DropdownMenuItem<DurationTime>(
                        value: duration,
                        child: Text(formattedDuration),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (selectedStartTime != null &&
                        selectedEndTime != null &&
                        selectedDurationTime != null) {
                      int startMintutes = selectedStartTime!.hour * 60 +
                          selectedStartTime!.minute;
                      int endMintutes =
                          selectedEndTime!.hour * 60 + selectedEndTime!.minute;
                      if (startMintutes >= endMintutes) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Błąd'),
                                content: Text(
                                    'Godzina rozpoczęcia musi być wcześniejsza niż godzina zakończenia.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Zamknij'),
                                  ),
                                ],
                              );
                            });
                      } else {
                        await calendarViewModel
                            .createDailySchedule(
                          _selectedDay!,
                          selectedStartTime!,
                          selectedEndTime!,
                          selectedDurationTime!,
                        )
                            .then((_) {
                          setState(() {
                            _segmentsFuture =
                                calendarViewModel.getDailySchedule(
                              _selectedDay!.toIso8601String(),
                            );
                          });
                          Navigator.pushNamed(context, '/modify_calendar');
                        });
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.TurquoiseLagoon,
                  ),
                  child: Text('Zapisz'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.TurquoiseLagoon,
                  ),
                  child: Text('Zamknij'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calendarViewModel =
        Provider.of<CalendarViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          color: Colors.white,
          onPressed: _goBack,
        ),
        backgroundColor: Colors.black38,
        flexibleSpace: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              'Kalendarz',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            color: Colors.white,
            onPressed: () => _showSelectedDayPopup(calendarViewModel),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            TableCalendar(
              locale: 'pl_PL',
              rowHeight: 60,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Colors.white,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white),
                weekendStyle: TextStyle(color: Colors.red),
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
              availableGestures: AvailableGestures.all,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              focusedDay: _focusedDay,
              firstDay: today,
              lastDay: DateTime(
                today.year,
                today.month + 1,
                today.day,
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                disabledTextStyle: TextStyle(color: Colors.grey),
                weekendTextStyle: TextStyle(color: Colors.red),
                markerDecoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              onDaySelected: _onDaySelected,
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                // Zaktualizuj _focusedDay, aby umożliwić poprawną nawigację
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
            ),
            SizedBox(height: 10.0),
            Divider(color: Colors.white),
            Expanded(
              child: FutureBuilder<List<TimeSegment>?>(
                future: _segmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Błąd podczas ładowania segmentów',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Nie wybrano jeszcze grafiku dla tego dnia.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  } else {
                    final segments = snapshot.data!;
                    return ListView.builder(
                      itemCount: segments.length,
                      itemBuilder: (context, index) {
                        final segment = segments[index];
                        final localizations = MaterialLocalizations.of(context);
                        final startTime = localizations.formatTimeOfDay(
                            segment.startTime,
                            alwaysUse24HourFormat: true);
                        final endTime = localizations.formatTimeOfDay(
                            segment.endTime,
                            alwaysUse24HourFormat: true);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                startTime,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                endTime,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  segment.occupied! ? Icons.lock : Icons.person,
                                  color: segment.occupied!
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                onPressed: () {
                                  calendarViewModel
                                      .toggleSegmentOccupiedStatus(
                                    _selectedDay!.toIso8601String(),
                                    segment,
                                  )
                                      .then((_) {
                                    setState(() {
                                      _segmentsFuture =
                                          calendarViewModel.getDailySchedule(
                                              _selectedDay!.toIso8601String());
                                    });
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  calendarViewModel
                                      .removeSegmentFromDocument(
                                          _selectedDay!.toIso8601String(),
                                          segment)
                                      .then((_) {
                                    setState(() {
                                      _segmentsFuture =
                                          calendarViewModel.getDailySchedule(
                                              _selectedDay!.toIso8601String());
                                    });
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
