import 'package:flutter/material.dart';
import 'package:time_boxer_v01/src/Users/Screens/timer_screen.dart';


class SessionScreen extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sessions'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Basic Timer'),
              Tab(text: 'Start Session'),
              Tab(text: 'Create Session'),
              Tab(text: 'Past Sessions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TimerScreen(),
            Text('Start Sessions'),
            Text('Create Session'),
            Text('Past Session'),
          ],
        ),
      ),
    );
  }
}