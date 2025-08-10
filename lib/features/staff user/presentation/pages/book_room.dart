import 'package:flutter/material.dart';

class BookRoom extends StatefulWidget {
  const BookRoom({super.key});
  static const route = '/book_room';

  @override
  _BookRoomState createState() => _BookRoomState();
}

class _BookRoomState extends State<BookRoom> {
  DateTime _selectedDate = DateTime(2025, 8, 12);
  bool _showPendingMessage = false;

  late Map<String, Map<String, UserBookingStatus>> _roomBookings;

  @override
  void initState() {
    super.initState();
    _generateTimeSlots();
  }

  void _generateTimeSlots() {
    _roomBookings = {};
    DateTime startTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      8,
      0,
    );
    DateTime endTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      20,
      0,
    );

    while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) {
      String timeLabel =
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
      _roomBookings[timeLabel] = {
        'Room 1': UserBookingStatus.available,
        'Room 2': UserBookingStatus.available,
      };
      startTime = startTime.add(Duration(minutes: 30));
    }
  }

  void _showPendingMessageTemporary() {
    setState(() {
      _showPendingMessage = true;
    });
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showPendingMessage = false;
        });
      }
    });
  }

  void _confirmBooking(String time, String room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Booking"),
        content: Text("Do you want to request booking for $room at $time?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: Text("Confirm"),
            onPressed: () {
              Navigator.pop(ctx);
              _bookTimeSlot(time, room);
            },
          ),
        ],
      ),
    );
  }

  void _bookTimeSlot(String time, String room) {
    if (_roomBookings[time]![room] == UserBookingStatus.available) {
      setState(() {
        _roomBookings[time]![room] = UserBookingStatus.pending;
      });
      _sendRequestToAdmin(room, 'single_slot');
      _showPendingMessageTemporary();
    }
  }

  void _confirmCancel(String time, String room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Cancel Booking"),
        content: Text(
          "Are you sure you want to cancel booking for $room at $time?",
        ),
        actions: [
          TextButton(child: Text("No"), onPressed: () => Navigator.pop(ctx)),
          ElevatedButton(
            child: Text("Yes"),
            onPressed: () {
              Navigator.pop(ctx);
              _cancelTimeSlot(time, room);
            },
          ),
        ],
      ),
    );
  }

  void _cancelTimeSlot(String time, String room) {
    if (_roomBookings[time]![room] == UserBookingStatus.bookedByUser ||
        _roomBookings[time]![room] == UserBookingStatus.pending) {
      setState(() {
        _roomBookings[time]![room] = UserBookingStatus.available;
      });
    }
  }

  // Book Full Day
  void _confirmBookFullDay(String room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Booking"),
        content: Text(
          "Do you want to request booking for the full day in $room?",
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: Text("Confirm"),
            onPressed: () {
              Navigator.pop(ctx);
              _bookFullDay(room);
            },
          ),
        ],
      ),
    );
  }

  void _bookFullDay(String room) {
    _sendRequestToAdmin(room, 'full_day');
    _showPendingMessageTemporary();
    setState(() {
      for (String time in _roomBookings.keys) {
        if (_roomBookings[time]![room] != UserBookingStatus.booked) {
          _roomBookings[time]![room] = UserBookingStatus.pending;
        }
      }
    });
  }

  // Cancel All
  void _confirmCancelAll(String room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Cancel All Bookings"),
        content: Text(
          "Are you sure you want to cancel all bookings for $room?",
        ),
        actions: [
          TextButton(child: Text("No"), onPressed: () => Navigator.pop(ctx)),
          ElevatedButton(
            child: Text("Yes"),
            onPressed: () {
              Navigator.pop(ctx);
              _cancelAllBookings(room);
            },
          ),
        ],
      ),
    );
  }

  void _cancelAllBookings(String room) {
    setState(() {
      for (String time in _roomBookings.keys) {
        if (_roomBookings[time]![room] == UserBookingStatus.bookedByUser ||
            _roomBookings[time]![room] == UserBookingStatus.pending) {
          _roomBookings[time]![room] = UserBookingStatus.available;
        }
      }
    });
  }

  void _sendRequestToAdmin(String room, String type) {
    print('Request sent to admin for $room - $type');
  }

  //////////////////////////////////////////// for future logic
  void _adminConfirmBooking(String time, String room) {
    if (_roomBookings[time]![room] == UserBookingStatus.pending) {
      setState(() {
        _roomBookings[time]![room] = UserBookingStatus.bookedByUser;
      });
    }
  }

  Widget _buildRoomSlot(String time, String room, UserBookingStatus status) {
    Color backgroundColor;
    Color textColor;
    String statusText;
    bool showCancelButton = false;
    bool isClickable = false;

    switch (status) {
      case UserBookingStatus.available:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[600]!;
        statusText = 'Available';
        isClickable = true;
        break;
      case UserBookingStatus.bookedByUser:
        backgroundColor = Color(0xFF10B981);
        textColor = Colors.white;
        statusText = 'Booked\nby you';
        showCancelButton = true;
        break;
      case UserBookingStatus.booked:
        backgroundColor = Color(0xFFE53E3E);
        textColor = Colors.white;
        statusText = 'Booked';
        break;
      case UserBookingStatus.pending:
        backgroundColor = Color(0xFFF59E0B);
        textColor = Colors.white;
        statusText = 'Pending';
        showCancelButton = true;
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: isClickable ? () => _confirmBooking(time, room) : null,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  statusText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              if (showCancelButton)
                Positioned(
                  top: -4,
                  right: -4,
                  child: GestureDetector(
                    onTap: () => _confirmCancel(time, room),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 14),
                    ),
                  ),
                ),
            ],
          ),
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

  Widget _buildRoomColumn(String roomName) {
    return Expanded(
      child: Column(
        children: [
          Text(
            roomName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _confirmBookFullDay(roomName),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Book Full Day'),
            ),
          ),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _confirmCancelAll(roomName),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6B7280),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text('Cancel All'),
            ),
          ),
        ],
      ),
    );
  }

  String _getFormattedDate() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
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
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back, size: 18),
              label: Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6B7FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            Text(
              'Book Room',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton(
              onPressed: () {
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
          if (_showPendingMessage)
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    color: Color(0xFFA16207),
                    size: 24,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request sent to admin.',
                          style: TextStyle(
                            color: Color(0xFFA16207),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Pending approval for booking',
                          style: TextStyle(
                            color: Color(0xFFA16207),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFormattedDate(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: _roomBookings.keys.map((time) {
                        return _buildTimeSlot(time);
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    children: [
                      _buildRoomColumn('Room 1'),
                      SizedBox(width: 16),
                      _buildRoomColumn('Room 2'),
                    ],
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

enum UserBookingStatus { available, bookedByUser, booked, pending }
