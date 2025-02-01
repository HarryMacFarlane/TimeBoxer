import 'package:flutter/material.dart';
import 'dart:async';

class TimerScreen extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerScreen> {
  // Timer-related variables
  late Timer _timer;
  bool _isRunning = false;
  
  int _totalSeconds = 0;  // Total time in seconds for easier calculation

  int _seconds = 0;
  int _minutes = 0;
  int _hours = 0;

  // Method to start the timer
  void _startTimer() {
    // Convert hours, minutes, and seconds to total seconds
    _totalSeconds = _hours * 3600 + _minutes * 60 + _seconds;

    setState(() {
      _seconds = _totalSeconds;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        _timer.cancel(); // Stop the timer when it reaches 0
      }
    });
  }

  // Method to pause the timer
  void _pauseTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  // Method to reset the timer
  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _isRunning = false;
      _hours = 0;
      _minutes = 0;
      _seconds = 0;
    });
  }

  // Method to resume the timer
  void _resumeTimer() {
    _startTimer();
    setState(() {
      _isRunning = true;
    });
  }

  // Method to set a new timer duration
  void _setTimer() {
    showDialog(
      context: context,
      builder: (context) {
        // Default time values
        int inputHours = 0;
        int inputMinutes = 0;
        int inputSeconds = 0;

        return AlertDialog(
          title: Text("Set Timer"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hour input
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  inputHours = int.tryParse(value) ?? 0;
                },
                decoration: InputDecoration(hintText: "Enter hours"),
              ),
              // Minute input
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  inputMinutes = int.tryParse(value) ?? 0;
                },
                decoration: InputDecoration(hintText: "Enter minutes"),
              ),
              // Second input
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  inputSeconds = int.tryParse(value) ?? 0;
                },
                decoration: InputDecoration(hintText: "Enter seconds"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _hours = inputHours;
                  _minutes = inputMinutes;
                  _seconds = inputSeconds;
                });
                _startTimer();
                setState(() {
                  _isRunning = true;
                });
              },
              child: Text("Set Timer"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer.cancel();
    super.dispose();
  }

  // Format time as hh:mm:ss
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Timer with Hours, Minutes, Seconds"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Display the formatted time
            Text(
              _formatTime(_seconds),
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isRunning
                      ? null // Disable if the timer is running
                      : _setTimer, // Set a new timer if not running
                  child: Text("Set Timer"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _isRunning ? _pauseTimer : _resumeTimer,
                  child: Text(_isRunning ? "Pause" : "Resume"),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: Text("End Timer"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}