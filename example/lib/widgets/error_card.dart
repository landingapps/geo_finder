import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget {
  final String error;

  const ErrorCard({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          error,
          style: TextStyle(color: Colors.red.shade900),
        ),
      ),
    );
  }
}
