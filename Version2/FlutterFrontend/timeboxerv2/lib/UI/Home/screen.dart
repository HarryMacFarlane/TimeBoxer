import 'package:flutter/material.dart';
import 'package:timeboxerv2/UI/Home/Profile/screen.dart';
import 'sidebar.dart'; // Import the sidebar widget
import '../../Providers/user_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final UserProvider user;
  final Function(UserProvider?) onSignOut;

  const HomeScreen({Key? key, required this.user, required this.onSignOut}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _updateContent(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    // Implement logic to make sure the user has been logged out!
    try {
      widget.user.logout();
    }
    catch (e)
    {
      // Implement a message to be shown if FOR ANY REASON, user can't signout!
    }
    widget.onSignOut(null);
  } 

  @override
  Widget build(BuildContext context) {
    return Provider<UserProvider>(
      create: (context) => widget.user, 
      child: 
        Scaffold(
          appBar: AppBar(
            title: const Text('TimeBoxer'),
            leading: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              }
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white),
                onPressed: _logout, // Calls sign-out function
              ),
            ],
          ),
          body: 
            Builder(
              builder: (context) => _getScreenContent(),
            ),
          drawer: 
            Sidebar(onItemSelected: _updateContent),
        )
    );
  }
  // I need to ensure each of these screens are wrapped as consumers that must reload once the user provider has been used to modify something in the db!
  Widget _getScreenContent() {
    switch (_selectedIndex) {
      case 1:
        return ProfileScreen();
      case 2:
        return Center(child: Text("Workblocks Screen"));
      case 3:
        return Center(child: Text("Calendar Screen"));
      case 4:
        return Center(child: Text("Settings Screen"));
      case 5:
        return Center(child: Text("About Screen"));
      default:
        return Center(child: Text("Home Page"));
    }
  }
}
