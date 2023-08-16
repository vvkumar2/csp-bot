import 'package:flutter/material.dart';
import 'package:frontend/screens/learning.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/screens/dashboard.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';

class NavbarScreen extends StatefulWidget {
  const NavbarScreen({super.key});

  @override
  State<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends State<NavbarScreen> {
  int _selectedTabIndex = 0;
  String _activeTabName = 'Dashboard';

  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeTab = const DashboardScreen();

    switch (_selectedTabIndex) {
      case 0:
        activeTab = const LearningScreen();
        _activeTabName = 'Home';
        break;
      case 1:
        activeTab = const DashboardScreen();
        _activeTabName = 'Stocks';
        break;
      case 2:
        activeTab = const LearningScreen();
        _activeTabName = 'Learning';
        break;
      case 3:
        activeTab = const ProfileScreen();
        _activeTabName = 'Profile';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 8, 8, 8),
        title: Text(_activeTabName,
            style: const TextStyle(fontSize: 22, color: Colors.white)),
      ),
      body: activeTab,
      bottomNavigationBar: SalomonBottomBar(
        margin: const EdgeInsets.all(40),
        currentIndex: _selectedTabIndex,
        onTap: (index) => _selectTab(index),
        items: [
          SalomonBottomBarItem(
            icon: const Icon(EvaIcons.homeOutline),
            title: const Text('Home'),
            unselectedColor: Colors.white,
            selectedColor: const Color.fromARGB(255, 191, 33, 205),
          ),
          SalomonBottomBarItem(
            icon: const Icon(EvaIcons.briefcaseOutline),
            title: const Text('Stocks'),
            unselectedColor: Colors.white,
            selectedColor: const Color.fromARGB(255, 241, 49, 183),
          ),
          SalomonBottomBarItem(
            icon: const Icon(EvaIcons.bookOutline),
            title: const Text('Learning'),
            unselectedColor: Colors.white,
            selectedColor: const Color.fromARGB(255, 221, 34, 53),
          ),
          SalomonBottomBarItem(
            icon: const Icon(EvaIcons.personOutline),
            title: const Text('Profile'),
            unselectedColor: Colors.white,
            selectedColor: const Color.fromARGB(255, 235, 126, 53),
          ),
        ],
      ),
    );
  }
}
