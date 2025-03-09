import 'package:flutter/material.dart';
import 'Subjects/screen.dart';
import 'Tags/screen.dart';
import 'Tasks/screen.dart';

class ProfileScreen extends StatefulWidget {

  ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        Builder(
          builder: (context) => _getScreenContent(),
        ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Subjects'),
          BottomNavigationBarItem(icon: Icon(Icons.label), label: 'Tags'),
          BottomNavigationBarItem(icon: Icon(Icons.check), label: 'Tasks'),
        ],
      ),
    );
  }

  Widget _getScreenContent() {
    switch (_selectedIndex) {
      case 0:
        return SubjectScreen();
      case 1:
        return TagScreen();
      case 2:
        return TaskScreen();
      default:
        return Center(child: Text('Error: Screen not found!', style: TextStyle(fontSize: 24)));
    }
  }
}