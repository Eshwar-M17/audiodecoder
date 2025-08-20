import 'package:flutter/material.dart';

class StatusWidget extends StatelessWidget {
  final String status;
  final bool isLoading;
  const StatusWidget({super.key, required this.status, required this.isLoading});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('Status: $status')),
        if (isLoading) const SizedBox(width: 12),
        if (isLoading) const CircularProgressIndicator(),
      ],
    );
  }
}
