import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameCtrl = TextEditingController(text: 'Alex Johnson');
  final TextEditingController _emailCtrl = TextEditingController(text: 'alex.johnson@gmail.com');
  String _currency = 'USD (\$)';
  String _language = 'English';

  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _budgetAlert = true;
  bool _weeklyReport = false;

  bool _editingProfile = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: BrandAppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: Text(
          'Settings',
          style: TextStyle(
            color: const Color(0xFF131720),
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileCard(),
              SizedBox(height: 2.h),
              _buildAppearanceCard(),
              SizedBox(height: 2.h),
              _buildNotificationsCard(),
              SizedBox(height: 2.h),
              _buildSecurityCard(),
              SizedBox(height: 2.h),
              _buildExtrasCard(),
              SizedBox(height: 2.h),
              Center(
                child: Text(
                  'BudgetFlow v1.0.0',
                  style: TextStyle(
                    color: const Color(0xFF676F7E),
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF131720)),
                  ),
                  SizedBox(height: 0.4.h),
                  Text(
                    'Manage your personal information',
                    style: TextStyle(fontSize: 12.sp, color: const Color(0xFF676F7E)),
                  ),
                ],
              ),
              OutlinedButton(
                onPressed: () => setState(() => _editingProfile = !_editingProfile),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF131720),
                  side: const BorderSide(color: Color(0xFFE0E5EB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(_editingProfile ? 'Done' : 'Edit', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF29A385),
                child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16.sp)),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  children: [
                    _buildTextField('Full Name', _nameCtrl, enabled: _editingProfile),
                    SizedBox(height: 1.2.h),
                    _buildTextField('Email', _emailCtrl, enabled: _editingProfile),
                    SizedBox(height: 1.2.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: 'Currency',
                            value: _currency,
                            items: const ['USD (\$)', 'EUR (€)', 'KES (KSh)'],
                            onChanged: _editingProfile
                                ? (v) => setState(() => _currency = v ?? _currency)
                                : null,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _buildDropdown(
                            label: 'Language',
                            value: _language,
                            items: const ['English', 'Spanish', 'French'],
                            onChanged: _editingProfile
                                ? (v) => setState(() => _language = v ?? _language)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Appearance', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF131720))),
          SizedBox(height: 1.5.h),
          _buildSwitchRow('Dark Mode', _darkMode, (v) => setState(() => _darkMode = v)),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notifications', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF131720))),
          SizedBox(height: 1.h),
          _buildSwitchRow('Push Notifications', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
          const Divider(height: 24),
          _buildSwitchRow('Budget Alert', _budgetAlert, (v) => setState(() => _budgetAlert = v)),
          const Divider(height: 24),
          _buildSwitchRow('Weekly Report', _weeklyReport, (v) => setState(() => _weeklyReport = v)),
        ],
      ),
    );
  }

  Widget _buildSecurityCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Security', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF131720))),
          SizedBox(height: 1.5.h),
          _buildNavRow('Change Password', Icons.lock_outline, onTap: () {}),
          const Divider(height: 24),
          _buildNavRow('Two-Factor Authentication', Icons.shield_outlined, onTap: () {}),
          const Divider(height: 24),
          _buildNavRow('Connected Devices', Icons.devices_other_outlined, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildExtrasCard() {
    return Container(
      decoration: _cardDecoration(),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNavRow('Connected Accounts', Icons.account_circle_outlined, onTap: () {}),
          const Divider(height: 24),
          _buildNavRow('Help & Support', Icons.help_outline, onTap: () {}),
          const Divider(height: 24),
          _buildNavRow('Log Out', Icons.logout, destructive: true, onTap: () {
            // Optional: hook into AuthService().logout()
            Navigator.pushNamedAndRemoveUntil(context, '/login-screen', (route) => false);
          }),
        ],
      ),
    );
  }

  // Helpers
  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E5EB), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 6))],
      );

  Widget _buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: const Color(0xFF676F7E), fontSize: 12.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 0.6.h),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: enabled ? Colors.white : const Color(0xFFF5F7FA),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E5EB))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E5EB))),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE0E5EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF29A385), width: 2)),
          ),
          style: TextStyle(fontSize: 14.sp),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: const Color(0xFF676F7E), fontSize: 12.sp, fontWeight: FontWeight.w500)),
        SizedBox(height: 0.6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE0E5EB)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF131720), fontWeight: FontWeight.w600)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF29A385),
          activeTrackColor: const Color(0xFF29A385).withOpacity(0.5),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildNavRow(String label, IconData icon, {VoidCallback? onTap, bool destructive = false}) {
    final Color color = destructive ? const Color(0xFFDC2828) : const Color(0xFF131720);
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: destructive ? const Color(0xFFDC2828) : const Color(0xFF676F7E)),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: color),
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9AA3AF)),
        ],
      ),
    );
  }
}
