import 'package:flutter/material.dart';
import '../../core/app_export.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'Reports coming soon',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}
