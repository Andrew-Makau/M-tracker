import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_bottom_nav.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = const FlutterSecureStorage();
  String? _email;
  String? _name;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final email = await _storage.read(key: 'user_email');
      final name = await _storage.read(key: 'user_name');
      if (mounted) {
        setState(() {
          _email = email;
          _name = name;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    HapticFeedback.lightImpact();
    await AuthService().logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login-screen',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: BrandAppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboardHome,
              (route) => false,
            );
          },
          icon: const Icon(Icons.home),
        ),
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.pushNamed(context, '/edit-profile-screen');
              // Reload profile after edit
              await _loadProfile();
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
          body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 8.w,
                          backgroundColor: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.15),
                          child: Icon(
                            Icons.person,
                            size: 8.w,
                            color: AppTheme.lightTheme.primaryColor,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name?.isNotEmpty == true
                                    ? _name!
                                    : _deriveNameFromEmail(_email),
                                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.6.h),
                              Text(
                                _email ?? 'Unknown Email',
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 0.6.h),
                              Text(
                                'Signed in',
                                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    'Account',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  _SettingTile(
                    icon: 'person',
                    title: 'Name',
                    subtitle: _name?.isNotEmpty == true
                        ? _name!
                        : _deriveNameFromEmail(_email),
                    onTap: () async {
                      await Navigator.pushNamed(context, '/edit-profile-screen');
                      await _loadProfile();
                    },
                  ),

                  SizedBox(height: 1.5.h),

                  _SettingTile(
                    icon: 'email',
                    title: 'Email',
                    subtitle: _email ?? 'Not available',
                    onTap: () async {
                      await Navigator.pushNamed(context, '/edit-profile-screen');
                      await _loadProfile();
                    },
                  ),

                  SizedBox(height: 2.h),

                  _SettingTile(
                    icon: 'logout',
                    title: 'Logout',
                    subtitle: 'Sign out of your account',
                    destructive: true,
                    onTap: _logout,
                  ),
                ],
              ),
                ),
                bottomNavigationBar: const AppBottomNavWrapper(currentIndex: 3),
              );
  }
}

String _deriveNameFromEmail(String? email) {
  if (email == null || email.isEmpty) return 'User';
  final beforeAt = (email.split('@').isNotEmpty) ? email.split('@').first : email;
  final parts = beforeAt.replaceAll(RegExp(r'[._-]+'), ' ').split(' ');
  final capped = parts
      .where((p) => p.isNotEmpty)
      .map((p) => p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : ''))
      .join(' ');
  return capped.isEmpty ? 'User' : capped;
}

class _SettingTile extends StatelessWidget {
  final String icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightTheme.colorScheme.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: destructive
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.onSurface,
              size: 22,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      color: destructive
                          ? AppTheme.lightTheme.colorScheme.error
                          : AppTheme.lightTheme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 0.5.h),
                    Text(
                      subtitle!,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple wrapper to avoid duplicating onTap routing logic here.
class AppBottomNavWrapper extends StatelessWidget {
  final int currentIndex;
  const AppBottomNavWrapper({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.dashboardHome,
              (route) => false,
            );
            break;
          case 1:
            Navigator.pushNamed(context, '/transaction-history-screen');
            break;
          case 2:
            Navigator.pushNamed(context, '/budget-categories-screen');
            break;
          case 3:
            // current screen
            break;
        }
      },
    );
  }
}
