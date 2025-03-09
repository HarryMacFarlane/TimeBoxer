import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  final Function(int) onItemSelected; // Callback to update content

  const Sidebar({Key? key, required this.onItemSelected}) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int _selectedIndex = 0;

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildNavItem(Icons.home, "Home", 0),
                _buildNavItem(Icons.account_box_rounded, "Profile", 1),
                _buildNavItem(Icons.access_time_rounded, "Workblocks", 2),
                _buildNavItem(Icons.calendar_month_outlined, "Calendar", 3),
                _buildNavItem(Icons.settings, "Settings", 4),
                _buildNavItem(Icons.info, "About", 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(label, selectionColor: Colors.black),
      selected: _selectedIndex == index,
      onTap: () => _onItemTap(index),
    );
  }
}
