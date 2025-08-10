// lib/people_tab.dart
import 'package:flutter/material.dart';

class PeopleTab extends StatefulWidget {
  //  final VoidCallback onSuccessMessage;

  const PeopleTab({Key? key}) : super(key: key);

  @override
  _PeopleTabState createState() => _PeopleTabState();
}

class _PeopleTabState extends State<PeopleTab> {
  // Staff members data
  List<StaffMember> _staffMembers = [
    StaffMember(email: 'john.doe@company.com', status: StaffStatus.active),
    StaffMember(email: 'jane.smith@company.com', status: StaffStatus.pending),
    StaffMember(email: 'mike.wilson@company.com', status: StaffStatus.active),
  ];

  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sort by email ascending by default
    _staffMembers.sort((a, b) => a.email.compareTo(b.email));
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _staffMembers.removeAt(index);
                });
                Navigator.of(context).pop();
                // Log out the deleted user (implementation would depend on your auth system)
                _logoutDeletedUser();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _logoutDeletedUser() {
    // Implementation to logout the deleted user
    print('User logged out from system');
  }

  void _showAddUserDialog() {
    _emailController.clear();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isValidEmail = _isValidEmail(_emailController.text);

            return AlertDialog(
              title: Text('Add New User'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter email address',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isValidEmail
                      ? () {
                          _addNewUser(_emailController.text);
                          Navigator.of(context).pop();
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isValidEmail
                        ? Color(0xFF4A6CF7)
                        : Colors.grey,
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isValidEmail(String email) {
    if (email.length < 3 || email.length > 20) return false;

    // Check if email contains only allowed characters: English letters, numbers, ".", "-", "@"
    RegExp allowedChars = RegExp(r'^[a-zA-Z0-9.\-@]+$');
    if (!allowedChars.hasMatch(email)) return false;

    // Basic email validation
    return RegExp(r'^[a-zA-Z0-9.\-]+@[a-zA-Z0-9.\-]+$').hasMatch(email);
  }

  void _addNewUser(String email) {
    setState(() {
      _staffMembers.add(StaffMember(email: email, status: StaffStatus.pending));
      _staffMembers.sort((a, b) => a.email.compareTo(b.email));
    });

    // Send email to user (mock implementation)
    _sendPasswordSetupEmail(email);

    // Show success message
    //    widget.onSuccessMessage();
  }

  void _sendPasswordSetupEmail(String email) {
    // Mock email sending
    print('Sending email to: $email');
    print('Subject: Complete Your Portal Access – Set Your Password');
    print('Email sent with password setup link');
  }

  Widget _buildStaffMemberItem(StaffMember member, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.email,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  member.status == StaffStatus.active ? 'Active' : 'Pending',
                  style: TextStyle(
                    fontSize: 14,
                    color: member.status == StaffStatus.active
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showDeleteDialog(index),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Staff Members',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),

          // Staff Members List
          Expanded(
            child: ListView.builder(
              itemCount: _staffMembers.length,
              itemBuilder: (context, index) {
                return _buildStaffMemberItem(_staffMembers[index], index);
              },
            ),
          ),

          // Add New User Button
          _buildAddNewUserBtn(context),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAddNewUserBtn(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2 + 25,
        child: ElevatedButton.icon(
          onPressed: _showAddUserDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A6CF7),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.add, size: 20),
          label: const Text(
            'Add New User',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

enum StaffStatus { active, pending }

class StaffMember {
  final String email;
  final StaffStatus status;

  StaffMember({required this.email, required this.status});
}
