import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'dart:io';

class SecurityUtils {
  /// Checks if the device is rooted or jailbroken.
  /// Returns true if it's safe (NOT rooted/jailbroken), false otherwise.
  static Future<bool> isDeviceSecure() async {
    try {
      bool jailbroken = await FlutterJailbreakDetection.jailbroken;
      bool developerMode = false;
      
      if (Platform.isAndroid) {
        developerMode = await FlutterJailbreakDetection.developerMode;
      }

      return !jailbroken && !developerMode;
    } on PlatformException {
      return false; 
    } catch (_) {
      return false;
    }
  }

  /// Throws an error if the device is not secure.
  static Future<void> ensureSecureDevice() async {
    final isSecure = await isDeviceSecure();
    if (!isSecure) {
      throw Exception('⚠️ عذراً، لا يمكن إجراء هذه العملية على جهاز تم كسر حمايته (Root/Jailbreak) أو في وضع المطورين حرصاً على أمان محفظتك وأمان المنصة.');
    }
  }
}
