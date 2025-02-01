import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:time_boxer_v01/src/Providers/master_provider.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('TimeBoxer'),
      ),
      body: Center(
        child: Column(
          children: [
            Text('Welcome to the Home Page'),
          ],
        ),
      ),
    );
  }
}