import 'package:flutter/material.dart';
import 'UI/Authentication/screen.dart';
import 'UI/Home/screen.dart';
import 'Providers/user_provider.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  final UserProvider? user; // User object passed from login/register

  const AuthWrapper({Key? key, this.user}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  UserProvider? _currentUser; // Store the user locally

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
  }

  void updateUser(UserProvider? newUser) {
    setState(() {
      _currentUser = newUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _currentUser == null
        ? AuthScreen(onLogin: updateUser) // Pass callback to update user
        : HomeScreen(user: _currentUser!, onSignOut: updateUser);
  }
}