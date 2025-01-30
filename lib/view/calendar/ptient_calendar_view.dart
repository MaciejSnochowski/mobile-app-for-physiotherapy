import 'package:flutter/material.dart';
import 'package:physiotherapy/model/time_segment.dart';
import 'package:physiotherapy/viewmodel/calendar/patient_calendar_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class PatientCalendarView extends StatefulWidget {
  @override
  _PatientCalendarViewState createState() => _PatientCalendarViewState();
}

class _PatientCalendarViewState extends State<PatientCalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PatientCalendarViewModel(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            color: Colors.white,
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
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
        ),
        body: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Consumer<PatientCalendarViewModel>(
            builder: (context, viewModel, child) {
              return Column(
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
                    selectedDayPredicate: (day) =>
                        isSameDay(day, viewModel.selectedDay),
                    focusedDay: _focusedDay,
                    firstDay: DateTime.now(),
                    lastDay: DateTime(
                      DateTime.now().year,
                      DateTime.now().month + 1,
                      DateTime.now().day,
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
                    onDaySelected: (selectedDay, focusedDay) {
                      // Sprawdzenie, czy dzień to sobota lub niedziela
                      if (selectedDay.weekday == DateTime.saturday ||
                          selectedDay.weekday == DateTime.sunday) {
                        // Jeśli to weekend, wyświetl komunikat i zablokuj wybór
                        // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        //   content: Text(
                        //       'Nie można wybrać weekendów (soboty i niedzieli).'),
                        // ));
                        return; // Zablokuj wybór
                      }

                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                      viewModel.onDaySelected(selectedDay, focusedDay);
                    },
                    onFormatChanged: viewModel.onFormatChanged,
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                      viewModel.onPageChanged(focusedDay);
                    },
                  ),
                  SizedBox(height: 10.0),
                  Divider(color: Colors.white),
                  Expanded(
                    child: FutureBuilder<List<TimeSegment>?>(
                      future: viewModel.segmentsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Błąd podczas ładowania segmentów',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(
                            child: Text(
                              'Nie masz żadnych wizyt w tym dniu.',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          );
                        } else {
                          final segments = snapshot.data!;
                          return ListView.builder(
                            itemCount: segments.length,
                            itemBuilder: (context, index) {
                              final segment = segments[index];
                              final localizations =
                                  MaterialLocalizations.of(context);
                              final startTime = localizations.formatTimeOfDay(
                                  segment.startTime,
                                  alwaysUse24HourFormat: true);
                              final endTime = localizations.formatTimeOfDay(
                                  segment.endTime,
                                  alwaysUse24HourFormat: true);
                              final fullName = segment.specialistName;

                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                padding: const EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    Text(
                                      fullName!, // Dodanie pełnej nazwy fizjoterapeuty
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
