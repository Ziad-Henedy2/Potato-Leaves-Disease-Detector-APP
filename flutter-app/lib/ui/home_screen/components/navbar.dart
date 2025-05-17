import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, color: selectedIndex == 0 ? Colors.black : Colors.green[700]),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info, color: selectedIndex == 1 ? Colors.black : Colors.green[700]),
          label: 'About',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt, color: selectedIndex == 2 ? Colors.black : Colors.green[700]),
          label: 'Classify',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, color: selectedIndex == 3 ? Colors.black : Colors.green[700]),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.green[700],
      onTap: onItemTapped,
    );
  }
}