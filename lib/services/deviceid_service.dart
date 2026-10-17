import 'package:android_id/android_id.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceIdService {
  static const AndroidId _androidId = AndroidId();

  static Future<String> getDeviceId() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      throw UnsupportedError(
        'Device identification is only implemented for Android.',
      );
    }

    try {
      final String? androidId = await _androidId.getId();

      if (androidId == null || androidId.isEmpty) {
        throw Exception('Android did not provide a device ID.');
      }

      debugPrint('ANDROID DEVICE ID: $androidId');

      return androidId;
    } on PlatformException catch (e) {
      throw Exception('Could not retrieve Android device ID: ${e.message}');
    }
  }
}
