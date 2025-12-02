import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsService {
  static const _storage = FlutterSecureStorage();
  static const _fontFamilyKey = 'font_family';
  static const _fontScaleKey = 'font_scale';

  // in-memory cache
  static String fontFamily = 'Inter';
  static double fontScale = 1.0;

  // Notifiers so UI can rebuild when settings change
  static final ValueNotifier<String> fontFamilyNotifier = ValueNotifier(fontFamily);
  static final ValueNotifier<double> fontScaleNotifier = ValueNotifier(fontScale);

  static Future<void> init() async {
    final fam = await _storage.read(key: _fontFamilyKey);
    final scale = await _storage.read(key: _fontScaleKey);
    if (fam != null && fam.isNotEmpty) {
      fontFamily = fam;
      fontFamilyNotifier.value = fam;
    }
    if (scale != null) {
      final parsed = double.tryParse(scale);
      if (parsed != null && parsed > 0) {
        fontScale = parsed;
        fontScaleNotifier.value = parsed;
      }
    }
  }

  static Future<void> setFontFamily(String family) async {
    fontFamily = family;
    fontFamilyNotifier.value = family;
    await _storage.write(key: _fontFamilyKey, value: family);
  }

  static Future<void> setFontScale(double scale) async {
    fontScale = scale;
    fontScaleNotifier.value = scale;
    await _storage.write(key: _fontScaleKey, value: scale.toString());
  }
}
