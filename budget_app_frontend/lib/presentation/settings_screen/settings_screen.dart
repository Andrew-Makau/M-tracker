import 'package:flutter/material.dart';
import '../../core/app_export.dart';
import '../../widgets/brand_app_bar.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BrandAppBar(
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('General', style: AppTheme.lightTheme.textTheme.titleMedium),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Use Live Data'),
              value: false,
              onChanged: (v) {},
            ),
            const Divider(),
            Text('Appearance', style: AppTheme.lightTheme.textTheme.titleMedium),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              subtitle: const Text('Grey + Orange'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
