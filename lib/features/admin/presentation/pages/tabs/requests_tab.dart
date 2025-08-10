import 'dart:math';
import 'package:bookedin_app/features/admin/presentation/widgets/request_card.dart';
import 'package:flutter/material.dart';

class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});

  static final _emails = ['bavly.ramy@gmail.com', 'nouran@gmail.com'];

  static final _requestedTimes = [
    '2 hours ago',
    '5 minutes ago',
    'Yesterday',
    '30 minutes ago',
  ];

  static final _dateTimes = [
    'Aug 10, 09:00–12:00',
    'Aug 11, 14:00–16:00',
    'Aug 12, 08:00–10:00',
    'Aug 13, 15:00–18:00',
  ];

  static final _durations = ['1 hour', '2 hours', '3 hours', '4 hours'];

  static final _rooms = ['Room 1', 'Room 2'];

  String _randomFrom(List<String> list) {
    final random = Random();
    return list[random.nextInt(list.length)];
  }

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return RequestCard(
          email: _emails[index],
          requestedTime: _randomFrom(_requestedTimes),
          dateTime: _randomFrom(_dateTimes),
          duration: _randomFrom(_durations),
          room: _randomFrom(_rooms),
          onApprove: () {},
          onReject: () {},
        );
      },
    );
  }
}
