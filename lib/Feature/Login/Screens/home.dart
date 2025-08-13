import 'package:flutter/material.dart';
import '../../../Core/common/session-manager.dart';
import '../../../Model/admin-model.dart';
import '../../../Model/leads-model.dart';
import '../../Account/account-home.dart';
import '../../Funnel/Screens/funnel-home.dart';
import '../../Services/Screens/Services-home.dart';
import '../../Team/screens/team-home.dart';

class HomeScreen extends StatefulWidget {
  final AdminModel? admin;
  const HomeScreen({super.key, this.admin});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  LeadsModel? currentFirm;

  @override
  void initState() {
    super.initState();
    getCurrentFirm();
  }

  Future<void> getCurrentFirm() async {
    final lead = await SessionManager.getLoggedInLead();
    setState(() {
      currentFirm = lead;
    });
  }

  @override
  Widget build(BuildContext context) {
    // ⏳ Show loader until currentFirm is fetched
    if (currentFirm == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ✅ Pass lead to each screen
    final List<Widget> _screens = [
      FunnelHome(currentFirm: currentFirm!),
      ServiceHome(currentFirm: currentFirm!),
      TeamHome(currentFirm: currentFirm!),
      AccountHome(currentFirm: currentFirm!),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 0
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined),
              label: 'Funnel',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 1
                  ? Icons.miscellaneous_services
                  : Icons.miscellaneous_services_outlined),
              label: 'Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 2 ? Icons.groups : Icons.groups_outlined),
              label: 'Team',
            ),
            BottomNavigationBarItem(
              icon: Icon(_currentIndex == 3 ? Icons.apartment : Icons.apartment_outlined),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}