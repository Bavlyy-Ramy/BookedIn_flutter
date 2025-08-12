import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookRoom extends StatefulWidget {
  const BookRoom({super.key});
  static const route = '/book_room';

  @override
  _BookRoomState createState() => _BookRoomState();
}

class _BookRoomState extends State<BookRoom> {
  DateTime _selectedDate = DateTime(2025, 8, 12);
  bool _showPendingMessage = false;
  late DateTime selectedDay;

  // timeLabel -> { roomName: status }
  late Map<String, Map<String, UserBookingStatus>> _roomBookings;

  // Track if user already provided reason for this room today
  Set<String> _roomsWithReasonProvided = {};

  @override
  void initState() {
    super.initState();
    _generateTimeSlots(); // create slots from 8:00 to 20:00 every 30 minutes
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve passed argument safely
    selectedDay = ModalRoute.of(context)!.settings.arguments as DateTime;
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
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
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

  void _handleBookingLogic(String time, String room) {
    if (_roomBookings[time]![room] != UserBookingStatus.available) return;

    setState(() {
      _roomBookings[time]![room] = UserBookingStatus.bookedByUser;
    });

    _sendRequestToAdmin(room, 'single_slot');
    _convertBookedSequencesToPending(room);
  }

  void _convertBookedSequencesToPending(String room) {
    final times = _roomBookings.keys.toList();
    List<int> indicesToConvert = [];

    int i = 0;
    while (i < times.length) {
      if (_roomBookings[times[i]]![room] == UserBookingStatus.bookedByUser) {
        int j = i;
        while (j < times.length &&
            _roomBookings[times[j]]![room] == UserBookingStatus.bookedByUser) {
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

    // Also check for bookedByUser slots that are contiguous to existing pending slots
    List<int> contiguousToPendingIndices = [];
    for (int i = 0; i < times.length; i++) {
      if (_roomBookings[times[i]]![room] == UserBookingStatus.bookedByUser) {
        // Check if this bookedByUser slot is contiguous to any pending slot
        bool isContiguousToPending = false;

        // Check previous slot
        if (i > 0 &&
            _roomBookings[times[i - 1]]![room] == UserBookingStatus.pending) {
          isContiguousToPending = true;
        }

        // Check next slot
        if (i < times.length - 1 &&
            _roomBookings[times[i + 1]]![room] == UserBookingStatus.pending) {
          isContiguousToPending = true;
        }

        if (isContiguousToPending) {
          contiguousToPendingIndices.add(i);
        }
      }
    }

    // Combine both lists and remove duplicates
    Set<int> allIndicesToConvert = {
      ...indicesToConvert,
      ...contiguousToPendingIndices,
    };

    if (allIndicesToConvert.isNotEmpty) {
      // Check if we have new 4+ slot sequences that need reason dialog
      bool hasNewSequenceNeedingReason = false;
      if (indicesToConvert.length >= 4) {
        // Check if these 4+ slots are NOT contiguous to existing pending slots
        bool isNewSequence = true;
        for (final idx in indicesToConvert) {
          // Check if any of these slots is adjacent to existing pending slots
          if (idx > 0 &&
              _roomBookings[times[idx - 1]]![room] ==
                  UserBookingStatus.pending) {
            isNewSequence = false;
            break;
          }
          if (idx < times.length - 1 &&
              _roomBookings[times[idx + 1]]![room] ==
                  UserBookingStatus.pending) {
            isNewSequence = false;
            break;
          }
        }
        hasNewSequenceNeedingReason = isNewSequence;
      }

      if (hasNewSequenceNeedingReason) {
        _showReasonDialog(room, () {
          setState(() {
            for (final idx in allIndicesToConvert) {
              final t = times[idx];
              if (_roomBookings[t]![room] == UserBookingStatus.bookedByUser) {
                _roomBookings[t]![room] = UserBookingStatus.pending;
              }
            }
          });
          _sendRequestToAdmin(room, 'multi_hour_pending');
          _showPendingMessageTemporary();
        });
      } else {
        // No dialog needed - either extending existing pending or user already provided reason
        setState(() {
          for (final idx in allIndicesToConvert) {
            final t = times[idx];
            if (_roomBookings[t]![room] == UserBookingStatus.bookedByUser) {
              _roomBookings[t]![room] = UserBookingStatus.pending;
            }
          }
        });
        _sendRequestToAdmin(room, 'multi_hour_pending');
        _showPendingMessageTemporary();
      }
    }
  }

  void _showReasonDialog(String room, VoidCallback onConfirm) {
    String? selectedReason;
    String otherReason = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Booking Reason for $room"),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Please select a reason for your extended booking:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ...[
                  'DSM (Daily Stand-up)',
                  'Planning',
                  'Build plan',
                  'Grooming / Backlog Refinement',
                  'Sprint Review',
                ].map(
                  (reason) => RadioListTile<String>(
                    title: Text(reason),
                    value: reason,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedReason = value;
                      });
                    },
                  ),
                ),
                RadioListTile<String>(
                  title: const Text("Other"),
                  value: "Other",
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setDialogState(() {
                      selectedReason = value;
                    });
                  },
                ),
                if (selectedReason == "Other") ...[
                  const SizedBox(height: 8),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: "Please specify...",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      otherReason = value;
                    },
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(ctx);
                // Revert the booking
                _cancelBookingSequence(room);
              },
            ),
            ElevatedButton(
              child: const Text("Save"),
              onPressed: () {
                if (selectedReason != null &&
                    (selectedReason != "Other" || otherReason.isNotEmpty)) {
                  Navigator.pop(ctx);
                  _roomsWithReasonProvided.add(room);
                  final finalReason = selectedReason == "Other"
                      ? otherReason
                      : selectedReason!;
                  _sendBookingReasonToAdmin(room, finalReason);
                  onConfirm();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _cancelBookingSequence(String room) {
    setState(() {
      for (final time in _roomBookings.keys) {
        if (_roomBookings[time]![room] == UserBookingStatus.bookedByUser) {
          _roomBookings[time]![room] = UserBookingStatus.available;
        }
      }
    });
  }

  void _sendBookingReasonToAdmin(String room, String reason) {
    debugPrint('Booking reason sent to admin for $room: $reason');
  }

  void _confirmCancel(String time, String room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancel Booking"),
        content: Text(
          "Are you sure you want to cancel booking for $room at $time?",
        ),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.pop(ctx),
          ),
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

  void _cancelTimeSlot(String time, String room) {
    if (_roomBookings[time]![room] == UserBookingStatus.bookedByUser) {
      setState(() {
        _roomBookings[time]![room] = UserBookingStatus.available;
      });
    }
  }

  void _confirmBookFullDay(String room) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: Text(
          "Do you want to request booking for the full day in $room?",
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
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
    bool hasPending = _roomBookings.values.any(
      (m) => m[room] == UserBookingStatus.pending,
    );

    // If no pending bookings and user hasn't provided reason yet, show reason dialog
    if (!hasPending && !_roomsWithReasonProvided.contains(room)) {
      _showReasonDialog(room, () {
        _proceedWithFullDayBooking(room);
      });
    } else {
      _proceedWithFullDayBooking(room);
    }
  }

  void _proceedWithFullDayBooking(String room) {
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
        content: Text(
          "Are you sure you want to cancel all pending bookings for $room?",
        ),
        actions: [
          TextButton(
            child: const Text("No"),
            onPressed: () => Navigator.pop(ctx),
          ),
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

  void _cancelAllPendingBookings(String room) {
    setState(() {
      for (final time in _roomBookings.keys) {
        if (_roomBookings[time]![room] == UserBookingStatus.pending) {
          _roomBookings[time]![room] = UserBookingStatus.available;
        }
      }
    });
    // Reset reason provided flag when all pending are cancelled
    _roomsWithReasonProvided.remove(room);
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
        backgroundColor = const Color(0xFFF8F9FA);
        textColor = const Color(0xFF6C757D);
        statusText = 'Available';
        isClickable = true;
        showCancelButton = false;
        break;
      case UserBookingStatus.bookedByUser:
        backgroundColor = const Color(0xFF11ba82);
        textColor = Colors.white;
        statusText = 'Booked\nby you';
        showCancelButton = true;
        isClickable = false;
        break;
      case UserBookingStatus.booked:
        backgroundColor = const Color(0xFFef4444);
        textColor = Colors.white;
        statusText = 'Booked';
        showCancelButton = false;
        isClickable = false;
        break;
      case UserBookingStatus.pending:
        backgroundColor = const Color(0xFFf59f0a);
        textColor = Colors.white;
        statusText = 'Pending';
        showCancelButton = false;
        isClickable = false;
        break;
    }

    return Expanded(
      child: GestureDetector(
        onTap: isClickable ? () => _confirmBooking(time, room) : null,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: status == UserBookingStatus.available
                ? Border.all(color: const Color(0xFFDEE2E6), width: 1)
                : null,
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
                    fontSize: 20,
                  ),
                ),
              ),
              if (showCancelButton)
                Positioned(
                  top: -12,
                  right: -12,
                  child: GestureDetector(
                    onTap: () => _confirmCancel(time, room),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF495057),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildRoomSlot(time, 'Room 1', _roomBookings[time]!['Room 1']!),
          const SizedBox(width: 10),
          _buildRoomSlot(time, 'Room 2', _roomBookings[time]!['Room 2']!),
        ],
      ),
    );
  }

  Widget _buildRoomColumn(String roomName) {
    bool hasPending = _roomBookings.values.any(
      (m) => m[roomName] == UserBookingStatus.pending,
    );

    return Expanded(
      child: Column(
        children: [
          Text(
            roomName,
            style: const TextStyle(
              fontSize: 20,
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
              child: const Text(
                'Book Full Day',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasPending ? () => _confirmCancelAll(roomName) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasPending
                    ? const Color(0xFF6B7280)
                    : Colors.grey[300],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Cancel All', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Lighter background
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
            const Text(
              'Book Room',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
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
                  const Icon(
                    Icons.hourglass_empty,
                    color: Color(0xFFA16207),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Request sent to admin.',
                          style: TextStyle(
                            color: Color(0xFFA16207),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Pending approval for extended booking',
                          style: TextStyle(
                            color: Color(0xFFA16207),
                            fontSize: 17,
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE9ECEF), width: 1),
                      ),
                    ),
                    child: Text(
                      '${DateFormat('EEEE, d MMM yyyy').format(selectedDay)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const SizedBox(height: 0),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            spreadRadius: 0,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        children: _roomBookings.keys.map((time) {
                          return _buildTimeSlot(time);
                        }).toList(),
                      ),
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
