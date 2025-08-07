import 'package:bookedin_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.blue.shade700,
          title: const Text(
            'Admin Portal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 30,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4c77e6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, LoginPage.route);
                },
                child: const Text('Logout'),
              ),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.people), text: 'People'),
              Tab(icon: Icon(Icons.apartment), text: 'Rooms'),
              Tab(icon: Icon(Icons.request_page), text: 'Requests'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [PeopleTab(), RoomsTab(), RequestsTab()],
        ),
      ),
    );
  }
}
