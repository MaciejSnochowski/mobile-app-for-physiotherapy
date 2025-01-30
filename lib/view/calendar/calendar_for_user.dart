import 'package:flutter/material.dart';
import 'package:physiotherapy/core/theme/theme.dart';
import 'package:physiotherapy/main.dart';
import 'package:physiotherapy/model/physiotherapist.dart';
import 'package:physiotherapy/model/time_segment.dart';
import 'package:physiotherapy/viewmodel/calendar/user_calendar_viewmodel.dart';
import 'package:physiotherapy/viewmodel/chat/chat_viewmodel.dart';
import 'package:physiotherapy/viewmodel/physiotherapists_list/physiotherapists_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class UserCalendarView extends StatefulWidget {
  @override
  _UserCalendarViewState createState() => _UserCalendarViewState();
}

class _UserCalendarViewState extends State<UserCalendarView> {
  DateTime today = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  late Physiotherapist physiotherapist;

  late Future<List<TimeSegment>?> _segmentsFuture;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _segmentsFuture = Future.value(
        null); // Domyślnie, gdy ekran się ładuje, ustawiamy `_segmentsFuture` na null
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
      final physiotherapistsViewModel =
          Provider.of<PhysiotherapistsViewModel>(context, listen: false);

      physiotherapist = physiotherapistsViewModel.physiotherapistFromTheList;
      final userCalendarViewModel =
          Provider.of<UserCalendarViewModel>(context, listen: false);
      _segmentsFuture = userCalendarViewModel.getDailySchedule(
          _selectedDay!.toIso8601String(), physiotherapist);
    });
  }

  void _goBack() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _showBookingDialog(BuildContext context, DateTime date,
      UserCalendarViewModel userCalendarViewModel, TimeSegment segment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Umówienie wizyty'),
          content: Text(
              'Czy chcesz umówić wizytę na ${date.toLocal().toString().split(' ')[0]}?'),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(AppTheme.TurquoiseLagoon),
              ),
              child: Text('Zamknij', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij popup
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(AppTheme.TurquoiseLagoon),
              ),
              child: Text('Potwierdź', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                // Potwierdź umówienie wizyty
                await userCalendarViewModel.changeCalendarMyPhysio(
                    _selectedDay!.toIso8601String(), physiotherapist, segment);
                // Zaktualizuj `_segmentsFuture` po zapisaniu zmian w bazie danych
                setState(() {
                  _segmentsFuture = userCalendarViewModel.getDailySchedule(
                      _selectedDay!.toIso8601String(), physiotherapist);
                });

                Navigator.of(context).pop(); // Zamknij popup
              },
            ),
          ],
        );
      },
    );
  }

  void _showOccupiedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Termin zajęty'),
          content: Text(
              'Nie możesz zarezerwować tego terminu, ponieważ jest już zajęty.'),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(AppTheme.TurquoiseLagoon),
              ),
              child: Text('Zamknij', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(); // Zamknij popup
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final _physiotherapistsViewModel =
        Provider.of<PhysiotherapistsViewModel>(context);

    final _chatRoomViewModel = Provider.of<ChatRoomViewModel>(context);
    final _userCalendarViewModel = Provider.of<UserCalendarViewModel>(context);
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
              '${_physiotherapistsViewModel.physiotherapistFromTheList.name} ${_physiotherapistsViewModel.physiotherapistFromTheList.lastName}  kalendarz',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.message),
            color: Colors.white,
            onPressed: () {
              logger.e(_physiotherapistsViewModel.physiotherapistFromTheList);
              _chatRoomViewModel.reciverUser =
                  _physiotherapistsViewModel.physiotherapistFromTheList.id;
              // _chatRoomViewModel.physiotherapist =
              //     _physiotherapistsViewModel.physiotherapistFromTheList;
              Navigator.pushNamed(context, '/chat');

              // implement your message action here
            },
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
                selectedDecoration: BoxDecoration(
                  color: AppTheme.TurquoiseLagoon,
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
                _focusedDay = focusedDay;
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
                        'Tego dnia fizjoterapeuta nie jest dostępny',
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
                                    color: Colors.white, fontSize: 16),
                              ),
                              IconButton(
                                icon: Icon(
                                  segment.occupied! ? Icons.lock : Icons.person,
                                  color: segment.occupied!
                                      ? Colors.red
                                      : Colors.green,
                                ),
                                onPressed: () {
                                  if (!segment.occupied!) {
                                    _showBookingDialog(context, _selectedDay!,
                                        _userCalendarViewModel, segment);
                                  } else {
                                    _showOccupiedDialog(
                                        context); // Wywołanie popupu informującego o zajętym terminie
                                  }
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
