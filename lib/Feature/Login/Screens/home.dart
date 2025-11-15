import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:refrr_admin/Core/common/global%20variables.dart';
import 'package:refrr_admin/Feature/Services/Screens/service-home.dart';
import 'package:refrr_admin/models/leads_model.dart';
import 'package:refrr_admin/Feature/Account/screens/account-home.dart';
import 'package:refrr_admin/Feature/Funnel/Screens/funnel-home.dart';
import 'package:refrr_admin/Feature/Funnel/Screens/Services-home-funnel.dart';
import 'package:refrr_admin/Feature/Team/screens/team-home.dart';

class HomeScreen extends StatefulWidget {
  final LeadsModel? lead;
  final int? index;
  const HomeScreen({super.key, this.lead,  this.index});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
@override
  void initState() {
  _currentIndex = widget.index ?? 0;
      super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      FunnelHome(currentFirm: widget.lead),
      ServiceListScreenHome(currentFirm: widget.lead),
      TeamHome(currentFirm: widget.lead),
      AccountHome(currentFirm: widget.lead),
    ];

    return Scaffold(
      body: screens[_currentIndex],
        bottomNavigationBar: SizedBox(
          height: 60, // 👈 set your custom height here
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.black,
              selectedFontSize: width*.03,
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(
                height: 1.0, // 👈 reduces space below icon
              ),
              unselectedLabelStyle: const TextStyle(
                height: 1.0,
              ),
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    _currentIndex == 0
                        ? 'assets/svg/home-fill.svg'
                        : 'assets/svg/home-unfill.svg',
                    height: 35,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    _currentIndex == 1
                        ? 'assets/svg/dashboard-fill.svg'
                        : 'assets/svg/dashboard-unfill.svg',
                    height: 34,
                  ),
                  label: 'Service',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    _currentIndex == 2
                        ? 'assets/svg/person-fill.svg'
                        : 'assets/svg/person-unfill.svg',
                    height: 35,
                  ),
                  label: 'Team',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    _currentIndex == 3
                        ? 'assets/svg/wallet-fill.svg'
                        : 'assets/svg/wallet-unfill.svg',
                    height: 35,
                  ),
                  label: 'Account',
                ),
              ],
            ),
          ),
        ),

    );
  }
}