import 'package:bookedin_app/features/auth/presentation/pages/login_page.dart';
import 'package:bookedin_app/features/staff%20user/presentation/pages/book_room.dart';
     
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class StaffPortal extends StatefulWidget {
  const StaffPortal({super.key});

  static const route = '/staff_portal';

  @override
  State<StaffPortal> createState() => _StaffPortalState();
}

class _StaffPortalState extends State<StaffPortal> {
  DateTime today = DateTime.now();
  DateTime lastDay = DateTime.now().add(const Duration(days: 30));

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    // Only allow navigation for enabled days (not weekends)
    if (day.weekday != DateTime.friday && day.weekday != DateTime.saturday) {
      Navigator.pushNamed(context, BookRoom.route, arguments: day);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            _buildTableCalendar(),
            SizedBox(height: 15),
            _buildInfoBox(),
          ],
        ),
      ),
    );
  }

  Row _buildInfoBox() {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Color(0xFF3b82f6),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: Text("Selected"),
        ),
        SizedBox(width: 16),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Color(0xFFedf0f2),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: Text("Unavailable"),
        ),
        SizedBox(width: 16),
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 2.0),
          child: Text("Available"),
        ),
      ],
    );
  }

  LayoutBuilder _buildTableCalendar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = (constraints.maxWidth - 15) / 7; // 7 days

        return TableCalendar(
          focusedDay: today,
          firstDay: today,
          lastDay: lastDay,
          onDaySelected: _onDaySelected,
          selectedDayPredicate: (day) => isSameDay(day, today),
          
          // This makes weekends non-selectable
          enabledDayPredicate: (day) {
            return day.weekday != DateTime.friday && day.weekday != DateTime.saturday;
          },
          
          availableGestures: AvailableGestures.all,
          calendarFormat: CalendarFormat.month,
          rowHeight: cellWidth,
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            headerMargin: const EdgeInsets.only(bottom: 15),
            titleTextStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            leftChevronIcon: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.chevron_left,
                color: Colors.white,
                size: 20,
              ),
            ),
            rightChevronIcon: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 20,
              ),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF2258e0),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            weekendStyle: TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          calendarStyle: CalendarStyle(
            cellMargin: const EdgeInsets.all(2),
            cellAlignment: Alignment.center,
            defaultDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            weekendDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            outsideDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
            
            // Style for disabled days (weekends)
            disabledDecoration: BoxDecoration(
              color: const Color(0xFFedf0f2), // Gray background for disabled days
              borderRadius: BorderRadius.circular(6),
            ),
            
            selectedDecoration: BoxDecoration(
              color: const Color(0xFF2258e0),
              borderRadius: BorderRadius.circular(6),
            ),
            todayDecoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2258e0), width: 2),
              borderRadius: BorderRadius.circular(6),
            ),
            selectedTextStyle: const TextStyle(color: Colors.white),
            outsideTextStyle: const TextStyle(color: Colors.grey),
            todayTextStyle: const TextStyle(color: Colors.black),
            
            // Style for disabled text (weekends)
            disabledTextStyle: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        "Staff Portal",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      backgroundColor: const Color(0xFF2258e0),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4b73e3),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pushNamed(context, LoginPage.route);
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}