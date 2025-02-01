

import 'package:flutter/material.dart';

class SessionPage extends StatefulWidget{
  @override
  _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session Page'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Welcome to the Session Page'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}