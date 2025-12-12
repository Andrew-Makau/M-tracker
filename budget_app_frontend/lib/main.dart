import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import 'core/app_export.dart';
import 'services/settings_service.dart';
import 'services/app_state.dart';
import 'widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!hasShownError) {
      hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  // Load persisted settings before launching the app so scale is applied.
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) async {
    // initialize settings service
    try {
      await SettingsService.init();
    } catch (_) {}
    runApp(MyApp());
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Rebuild when settings change
    SettingsService.fontFamilyNotifier.addListener(_onSettingsChanged);
    SettingsService.fontScaleNotifier.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    SettingsService.fontFamilyNotifier.removeListener(_onSettingsChanged);
    SettingsService.fontScaleNotifier.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final scale = SettingsService.fontScaleNotifier.value;
    final fontFamily = SettingsService.fontFamilyNotifier.value;

    return AppStateProvider(
      appState: AppState(),
      child: Sizer(builder: (context, orientation, screenType) {
      final baseLight = AppTheme.lightTheme;
      final baseDark = AppTheme.darkTheme;

      return MaterialApp(
        title: 'budgetflow',
        theme: baseLight.copyWith(
          textTheme: baseLight.textTheme.apply(fontFamily: fontFamily),
          primaryTextTheme: baseLight.primaryTextTheme.apply(fontFamily: fontFamily),
          appBarTheme: baseLight.appBarTheme.copyWith(
            titleTextStyle: baseLight.appBarTheme.titleTextStyle?.copyWith(fontFamily: fontFamily),
          ),
        ),
        darkTheme: baseDark.copyWith(
          textTheme: baseDark.textTheme.apply(fontFamily: fontFamily),
          primaryTextTheme: baseDark.primaryTextTheme.apply(fontFamily: fontFamily),
          appBarTheme: baseDark.appBarTheme.copyWith(
            titleTextStyle: baseDark.appBarTheme.titleTextStyle?.copyWith(fontFamily: fontFamily),
          ),
        ),
        themeMode: ThemeMode.light,
        // Apply saved text scale factor here (from SettingsService)
        builder: (context, child) {
          // Use the supported textScaleFactor field on MediaQueryData
          final mq = MediaQuery.of(context);
          return MediaQuery(
            data: mq.copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
      );
      }),
    );
  }
}
