import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

// Local Imports
import 'Screens/task_screen.dart';
import 'Screens/HomeScreen.dart';
import 'Screens/SessionScreen.dart';
import 'calendar_screen.dart';


// Sidebar (Drawer) for Navigation
class Sidebar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'TimeBoxer',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SidebarScaffold(body: HomeScreen())));
            },
          ),
          ListTile(
            title: Text('Calendar'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SidebarScaffold(body: CalendarSwitcher())));
            },
          ),
          ListTile(
            title: Text('Sessions'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SidebarScaffold(body: SessionScreen())));
            },
          ),
          ListTile(
            title: Text('Tasks'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SidebarScaffold(body: TaskScreen())));
            },
          ),
        ],
      ),
    );
  }
}

class SidebarScaffold extends StatelessWidget {
  final Widget body;

  SidebarScaffold({required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar:AppBar(
          title: const Text('TimeBoxer'),
          leading: Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
      actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<ProfileScreen>(
                  builder: (context) => ProfileScreen(
                    appBar: AppBar(
                      title: const Text('User Profile'),
                    ),
                    actions: [
                      SignedOutAction((context) {
                        Navigator.of(context).pop();
                      })
                    ],
                  ),
                ),
              );
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
     body: body,
     drawer: Sidebar(),
    );
  }
}