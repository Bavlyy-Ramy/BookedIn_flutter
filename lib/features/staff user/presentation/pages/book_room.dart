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

  // timeLabel -> { roomName: status }
  late Map<String, Map<String, UserBookingStatus>> _roomBookings;

  @override
  void initState() {
    super.initState();
    _generateTimeSlots(); // create slots from 8:00 to 20:00 every 30 minutes
  }

  void _generateTimeSlots() {
    _roomBookings = {};
    DateTime startTime =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 8, 0);
    DateTime endTime =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, 20, 0);

    while (startTime.isBefore(endTime) || startTime.isAtSameMomentAs(endTime)) {
      String timeLabel =
          "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
      _roomBookings[timeLabel] = {
        'Room 1': UserBookingStatus.available,
        'Room 2': UserBookingStatus.available,
      };
      startTime = startTime.add(const Duration(minutes: 30));
    }
  }

  void _showPendingMessageTemporary() {
    setState(() {
      _showPendingMessage = true;
    });
    Future.delayed(const Duration(seconds: 4), () {
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
        title: const Text("Confirm Booking"),
        content: Text("Do you want to book $room at $time?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(ctx)),
          ElevatedButton(
            child: const Text("Confirm"),
            onPressed: () {
              Navigator.pop(ctx);
              _handleBookingLogic(time, room);
            },
          ),
        ],
      ),
    );
  }

  // Book only the clicked slot, then check contiguous blocks to convert to pending
  void _handleBookingLogic(String time, String room) {
    if (_roomBookings[time]![room] != UserBookingStatus.available) return;

    setState(() {
      _roomBookings[time]![room] = UserBookingStatus.bookedByUser;
    });

    // optional: notify admin about a single slot (you can remove if not needed)
    _sendRequestToAdmin(room, 'single_slot');

    // After booking, convert any contiguous bookedByUser blocks (length >= 4) to pending
    _convertBookedSequencesToPending(room);
  }

  // Find contiguous sequences of bookedByUser and convert to pending if length >= 4
  void _convertBookedSequencesToPending(String room) {
    final times = _roomBookings.keys.toList();
    List<int> indicesToConvert = [];

    int i = 0;
    while (i < times.length) {
      if (_roomBookings[times[i]]![room] == UserBookingStatus.bookedByUser) {
        int j = i;
        while (j < times.length && _roomBookings[times[j]]![room] == UserBookingStatus.bookedByUser) {
          j++;
        }
        final len = j - i;
        if (len >= 4) {
          for (int k = i; k < j; k++) indicesToConvert.add(k);
        }
        i = j;
      } else {
        i++;
      }
    }

    if (indicesToConvert.isNotEmpty) {
      setState(() {
        for (final idx in indicesToConvert) {
          final t = times[idx];
          // Only convert bookedByUser -> pending (don't touch booked/pending)
          if (_roomBookings[t]![room] == UserBookingStatus.bookedByUser) {
            _roomBookings[t]![room] = UserBookingStatus.pending;
          }
        }
      });
      // notify admin about multi-hour pending request
      _sendRequestToAdmin(room, 'multi_hour_pending');
      _showPendingMessageTemporary();
    }
  }

  void _confirmCancel(String time, String room) {
    // only bookedByUser slots show cancel button
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: Text("Are you sure you want to cancel booking for $room at $time?"),
        actions: [
          TextButton(child: const Text("No"), onPressed: () => Navigator.pop(ctx)),
          ElevatedButton(
            child: const Text("Yes"),
            onPressed: () {
              Navigator.pop(ctx);
              _cancelTimeSlot(time, room);
            },
          ),
        ],
      ),
    );
  }

  // Individual cancellation allowed only for bookedByUser
  void _cancelTimeSlot(String time, String room) {
    if (_roomBookings[time]![room] == UserBookingStatus.bookedByUser) {
      setState(() {
        _roomBookings[time]![room] = UserBookingStatus.available;
      });
      // After cancelling a bookedByUser slot, no automatic conversion from pending happens
      // (pending remains until admin or Cancel All pending)
    }
  }

  void _confirmBookFullDay(String room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: Text("Do you want to request booking for the full day in $room?"),
        actions: [
          TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(ctx)),
          ElevatedButton(
            child: const Text("Confirm"),
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
    List<String> times = _roomBookings.keys.toList();

    setState(() {
      for (final t in times) {
        if (_roomBookings[t]![room] != UserBookingStatus.booked) {
          _roomBookings[t]![room] = UserBookingStatus.pending;
        }
      }
    });
    _showPendingMessageTemporary();
  }

  void _confirmCancelAll(String room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel All"),
        content: Text("Are you sure you want to cancel all pending bookings for $room?"),
        actions: [
          TextButton(child: const Text("No"), onPressed: () => Navigator.pop(ctx)),
          ElevatedButton(
            child: const Text("Yes"),
            onPressed: () {
              Navigator.pop(ctx);
              _cancelAllPendingBookings(room);
            },
          ),
        ],
      ),
    );
  }

  // Cancel only pending slots
  void _cancelAllPendingBookings(String room) {
    setState(() {
      for (final time in _roomBookings.keys) {
        if (_roomBookings[time]![room] == UserBookingStatus.pending) {
          _roomBookings[time]![room] = UserBookingStatus.available;
        }
      }
    });
  }

  void _sendRequestToAdmin(String room, String type) {
    debugPrint('Request sent to admin for $room - $type');
  }

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
        textColor = Colors.grey[800]!;
        statusText = 'Available';
        isClickable = true;
        showCancelButton = false;
        break;
      case UserBookingStatus.bookedByUser:
        backgroundColor = const Color(0xFF10B981);
        textColor = Colors.white;
        statusText = 'Booked\nby you';
        showCancelButton = true; // user can cancel individually
        isClickable = false;
        break;
      case UserBookingStatus.booked:
        backgroundColor = const Color(0xFFE53E3E);
        textColor = Colors.white;
        statusText = 'Booked';
        showCancelButton = false;
        isClickable = false;
        break;
      case UserBookingStatus.pending:
        backgroundColor = const Color(0xFFF59E0B);
        textColor = Colors.white;
        statusText = 'Pending';
        showCancelButton = false; // pending cannot be canceled individually
        isClickable = false;
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: isClickable ? () => _confirmBooking(time, room) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            clipBehavior: Clip.none,
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
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => _confirmCancel(time, room),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 14,
                      ),
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
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildRoomSlot(time, 'Room 1', _roomBookings[time]!['Room 1']!),
          const SizedBox(width: 8),
          _buildRoomSlot(time, 'Room 2', _roomBookings[time]!['Room 2']!),
        ],
      ),
    );
  }

  Widget _buildRoomColumn(String roomName) {
    bool hasPending = _roomBookings.values.any((m) => m[roomName] == UserBookingStatus.pending);

    return Expanded(
      child: Column(
        children: [
          Text(
            roomName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _confirmBookFullDay(roomName),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Book Full Day'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasPending ? () => _confirmCancelAll(roomName) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasPending ? const Color(0xFF6B7280) : Colors.grey[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cancel All Pending'),
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
      'December'
    ];
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6CF7),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 18),
              label: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B7FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            const Text(
              'Book Room',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B7FFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_showPendingMessage)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hourglass_empty, color: Color(0xFFA16207), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Request sent to admin.',
                          style: TextStyle(color: Color(0xFFA16207), fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          'Pending approval for booking',
                          style: TextStyle(color: Color(0xFFA16207), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getFormattedDate(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: _roomBookings.keys.map((time) {
                        return _buildTimeSlot(time);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildRoomColumn('Room 1'),
                      const SizedBox(width: 12),
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
