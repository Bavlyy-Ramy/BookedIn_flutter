// lib/rooms_tab.dart
import 'package:flutter/material.dart';

class RoomsTab extends StatefulWidget {
  @override
  _RoomsTabState createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  DateTime _selectedDate = DateTime(2025, 8, 5);

  Map<String, Map<String, RoomStatus>> _roomBookings = {
    '09:00': {'Room 1': RoomStatus.available, 'Room 2': RoomStatus.booked},
    '09:30': {'Room 1': RoomStatus.pending, 'Room 2': RoomStatus.available},
    '10:00': {'Room 1': RoomStatus.booked, 'Room 2': RoomStatus.booked},
    '10:30': {'Room 1': RoomStatus.available, 'Room 2': RoomStatus.pending},
    '11:00': {'Room 1': RoomStatus.pending, 'Room 2': RoomStatus.available},
    '11:30': {'Room 1': RoomStatus.booked, 'Room 2': RoomStatus.booked},
  };

  void _showCancelBookingDialog(String time, String room) {
    if (_roomBookings[time]![room] != RoomStatus.booked) {
      return; // Only allow canceling booked slots
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Booking'),
          content: Text('Are you sure you want to cancel this booking?'),
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
                  _roomBookings[time]![room] = RoomStatus.available;
                });
                Navigator.of(context).pop();
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getFormattedDate() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${_selectedDate.day} ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
  }

  Widget _buildRoomSlot(String time, String room, RoomStatus status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status) {
      case RoomStatus.available:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        statusText = 'Available';
        break;
      case RoomStatus.pending:
        backgroundColor = Color(0xFFF59E0B);
        textColor = Colors.white;
        statusText = 'Pending';
        break;
      case RoomStatus.booked:
        backgroundColor = Color(0xFF11ba82);
        textColor = Colors.white;
        statusText = 'Booked';
        break;
    }

    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      room,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      statusText,
                      style: TextStyle(color: textColor, fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),
            if (status == RoomStatus.booked)
              Positioned(
                top: -6,
                right: -6,
                child: GestureDetector(
                  onTap: () {
                    _showCancelBookingDialog(time, room);
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String time) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 60,
            child: Text(
              time,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(width: 16),
          _buildRoomSlot(time, 'Room 1', _roomBookings[time]!['Room 1']!),
          SizedBox(width: 8),
          _buildRoomSlot(time, 'Room 2', _roomBookings[time]!['Room 2']!),
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
          // Date Selection Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Date',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        _getFormattedDate(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A6CF7),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Room Availability Card
          Expanded(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room Availability - ${_getFormattedDate()}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Time Slots List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(
                        top: 8,
                        left: 4,
                        right: 2,
                        bottom: 0,
                      ),
                      children: _roomBookings.keys.map((time) {
                        return _buildTimeSlot(time);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum RoomStatus { available, pending, booked }
