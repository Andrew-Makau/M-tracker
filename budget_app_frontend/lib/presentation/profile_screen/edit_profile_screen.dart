import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/settings_service.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _storage = const FlutterSecureStorage();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;
  // font preferences
  final List<String> _fontFamilies = ['Inter', 'Roboto', 'Lato', 'Montserrat'];
  String _selectedFamily = SettingsService.fontFamily;
  double _fontScale = SettingsService.fontScale;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await _storage.read(key: 'user_name');
    final email = await _storage.read(key: 'user_email');
    // If logged in, try to fetch server-side settings and merge
    try {
      if (await AuthService().isLoggedIn()) {
        final map = await AuthService().getSettings();
        if (map != null) {
          if (map['font_family'] is String) _selectedFamily = map['font_family'];
          if (map['font_scale'] != null) {
            final parsed = double.tryParse(map['font_scale'].toString());
            if (parsed != null) _fontScale = parsed;
          }
        }
      }
    } catch (_) {}
    // load font prefs from SettingsService cache (initialized at app start)
    _selectedFamily = SettingsService.fontFamily;
    _fontScale = SettingsService.fontScale;
    setState(() {
      _nameController.text = name ?? '';
      _emailController.text = email ?? '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await _storage.write(key: 'user_name', value: _nameController.text.trim());
      await _storage.write(key: 'user_email', value: _emailController.text.trim());
      // persist font preferences locally
      await SettingsService.setFontFamily(_selectedFamily);
      await SettingsService.setFontScale(_fontScale);
      // also try to persist server-side when logged in
      try {
        if (await AuthService().isLoggedIn()) {
          await AuthService().saveSettings({
            'font_family': _selectedFamily,
            'font_scale': _fontScale,
          });
        }
      } catch (_) {
        // ignore network errors here
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final v = value.trim();
    final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$');
    if (!re.hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name is too short';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BrandAppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: _validateName,
              ),
              SizedBox(height: 2.h),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: _validateEmail,
              ),
              SizedBox(height: 2.h),
              // Font family selector
              Row(
                children: [
                  Expanded(
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Font Family'),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedFamily,
                          isExpanded: true,
                          items: _fontFamilies
                              .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _selectedFamily = v);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Font size slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Font Size', style: AppTheme.lightTheme.textTheme.bodyLarge),
                  Slider(
                    value: _fontScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    label: '${(_fontScale * 100).round()}%',
                    onChanged: (v) => setState(() => _fontScale = v),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
