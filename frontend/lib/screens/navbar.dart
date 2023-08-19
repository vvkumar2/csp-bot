import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/stock_filters_provider.dart';
import 'package:frontend/screens/learning.dart';
import 'package:frontend/screens/profile.dart';
import 'package:frontend/screens/dashboard.dart';
import 'package:frontend/screens/stocks.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/providers/stock_filters_provider.dart';

class NavbarScreen extends ConsumerStatefulWidget {
  const NavbarScreen({super.key});

  @override
  ConsumerState<NavbarScreen> createState() => _NavbarScreenState();
}

class _NavbarScreenState extends ConsumerState<NavbarScreen> {
  int _selectedTabIndex = 0;
  String _activeTabName = 'Dashboard';
  FocusNode _searchFocusNode = FocusNode();
  TextEditingController _searchController = TextEditingController();
  Widget _customTitle = const Text(
    'Stocks',
    style: TextStyle(
      color: Colors.white,
      fontSize: 22,
    ),
  );
  Icon _customIcon = const Icon(
    EvaIcons.searchOutline,
    color: Colors.purple,
  );

  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(filtersProvider);
    Widget activeTab = const DashboardScreen();

    switch (_selectedTabIndex) {
      case 0:
        activeTab = const DashboardScreen();
        _activeTabName = 'Home';
        break;
      case 1:
        activeTab = const StockScreen();
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
      appBar: _activeTabName == 'Profile'
          ? buildProfileAppBar()
          : _activeTabName == 'Stocks'
              ? buildStocksAppBar()
              : null,
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

  PreferredSizeWidget? buildProfileAppBar() {
    return AppBar(
      centerTitle: false,
      backgroundColor: const Color.fromARGB(255, 8, 8, 8),
      title: const Text("My Profile",
          style: TextStyle(fontSize: 22, color: Colors.white)),
      actions: [
        IconButton(
            onPressed: () async {
              try {
                // Sign out from Firebase Auth
                await FirebaseAuth.instance.signOut();
              } catch (error) {
                // Provide feedback to the user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error signing out: $error')),
                );
              }
            },
            icon: Icon(
              EvaIcons.logOutOutline,
              color: Theme.of(context).colorScheme.primary,
            ))
      ],
    );
  }

  PreferredSizeWidget? buildStocksAppBar() {
    return AppBar(
      centerTitle: false,
      backgroundColor: const Color.fromARGB(255, 8, 8, 8),
      title: _customTitle,
      actions: [
        IconButton(
            onPressed: () {
              setState(() {
                if (_customIcon.icon == EvaIcons.searchOutline) {
                  _searchFocusNode.requestFocus();
                  _customTitle = TextField(
                    focusNode: _searchFocusNode,
                    controller: _searchController,
                    onChanged: (value) {
                      ref
                          .read(filtersProvider.notifier)
                          .setFilter(Filter.search, value);
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search Ticker',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                        color: Color(0x4F2E3334),
                      )),
                      hintStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0x4F2E3334),
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  );
                  _customIcon = Icon(
                    EvaIcons.closeCircleOutline,
                    color: Theme.of(context).colorScheme.primary,
                  );
                } else {
                  _customTitle = const Text(
                    'Stocks',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  );
                  _customIcon = Icon(
                    EvaIcons.searchOutline,
                    color: Theme.of(context).colorScheme.primary,
                  );
                  // Clear the TextField and reset the filters
                  _searchController.clear();
                  ref.read(filtersProvider.notifier).resetFilters();
                }
              });
            },
            icon: _customIcon)
      ],
    );
  }
}
