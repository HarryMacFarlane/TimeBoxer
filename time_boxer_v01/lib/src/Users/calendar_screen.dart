// Package Imports
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';


class CalendarSwitcher extends StatefulWidget {
  @override
  _CalendarSwitcherState createState() => _CalendarSwitcherState();
}

class _CalendarSwitcherState extends State<CalendarSwitcher> {
  // Current selected date
  DateTime _selectedDate = DateTime.now();
  // The current view type (monthly or weekly)
  bool _isWeeklyView = false;

  // Initialize the calendar's focused date
  CalendarFormat _calendarFormat = CalendarFormat.month;

  // Toggle between monthly and weekly view
  void _toggleView() {
    setState(() {
      _isWeeklyView = !_isWeeklyView;
      // Update the format for monthly or weekly
      _calendarFormat = _isWeeklyView ? CalendarFormat.week : CalendarFormat.month;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        actions: [
          IconButton(
            icon: Icon(_isWeeklyView ? Icons.calendar_month : Icons.calendar_today),
            onPressed: _toggleView,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _selectedDate,
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                  // Update the focusedDay as well
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Selected Date: ${_selectedDate.toLocal()}',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
