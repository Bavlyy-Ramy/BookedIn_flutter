import 'package:bookedin_app/features/admin/presentation/widgets/request_card.dart';
import 'package:flutter/material.dart';

class RequestsTab extends StatelessWidget {
  const RequestsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) {
        return RequestCard(
          email: 'john.doe@company.com',
          requestedTime: '2 hours ago',
          dateTime: 'Aug 10, 09:00–12:00',
          duration: '3 hours',
          room: 'Room 1',
          onApprove: () {},
          onReject: () {},
        );
      },
    );
  }
}
