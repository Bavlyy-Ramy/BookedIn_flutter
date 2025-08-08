// lib/admin_portal.dart
import 'package:bookedin_app/features/admin/presentation/pages/tabs/people_tab.dart';
import 'package:bookedin_app/features/admin/presentation/pages/tabs/rooms_tab.dart';
import 'package:flutter/material.dart';


class AdminPortal extends StatefulWidget {
  @override
  _AdminPortalState createState() => _AdminPortalState();
}

class _AdminPortalState extends State<AdminPortal> {
  int _selectedTabIndex = 0; // Default is People tab
  bool _showSuccessMessage = false;

  void _onSuccessMessage() {
    setState(() {
      _showSuccessMessage = true;
    });

    // Auto hide after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSuccessMessage = false;
        });
      }
    });
  }

  Widget _buildTabButton(String title, IconData icon, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Color(0xFF4A6CF7) : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Color(0xFF4A6CF7) : Colors.grey[600],
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Color(0xFF4A6CF7) : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestsTab() {
    return Center(
      child: Text(
        'Requests Tab',
        style: TextStyle(
          fontSize: 18,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedTabIndex) {
      case 0:
        return 'Admin Portal';
      case 1:
        return 'Manage Rooms';
      case 2:
        return 'Manage Requests';
      default:
        return 'Admin Portal';
    }
  }

  Widget _getCurrentTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return PeopleTab(onSuccessMessage: _onSuccessMessage);
      case 1:
        return RoomsTab();
      case 2:
        return _buildRequestsTab();
      default:
        return PeopleTab(onSuccessMessage: _onSuccessMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Color(0xFF4A6CF7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getAppBarTitle(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Logout functionality
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6B7FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: Text('Logout'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Tab Navigation
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _buildTabButton('People', Icons.people, 0),
                _buildTabButton('Rooms', Icons.apps, 1),
                _buildTabButton('Requests', Icons.assignment, 2),
              ],
            ),
          ),

          // Success Message (only show when adding user)
          if (_showSuccessMessage && _selectedTabIndex == 0)
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFD4F4DD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'User added successfully',
                    style: TextStyle(
                      color: Color(0xFF2F7D32),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          
          // Content based on selected tab
          Expanded(
            child: _getCurrentTabContent(),
          ),
        ],
      ),
    );
  }
}