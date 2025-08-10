import 'package:bookedin_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'tabs/people_tab.dart';
import 'tabs/rooms_tab.dart';
import 'tabs/requests_tab.dart';

class AdminPortal extends StatelessWidget {
  const AdminPortal({super.key});
  static const route = '/admin_portal';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.blue.shade700,
            title: const Text(
              'Admin Portal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4c77e6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, LoginPage.route);
                  },
                  child: const Text('Logout', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ),
        ),

        // Tabs below AppBar
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black87,
                indicatorColor: Colors.blue,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                tabs: [
                  Tab(
                    icon: FaIcon(FontAwesomeIcons.userGroup, size: 20),
                    text: 'People',
                  ),
                  Tab(
                    icon: FaIcon(FontAwesomeIcons.building, size: 20),
                    text: 'Rooms',
                  ),
                  Tab(
                    icon: FaIcon(FontAwesomeIcons.clipboardList, size: 20),
                    text: 'Requests',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [PeopleTab(), RoomsTab(), RequestsTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
