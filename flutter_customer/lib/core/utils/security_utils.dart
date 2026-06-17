import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'dart:io';

class SecurityUtils {
  /// Checks if the device is rooted or jailbroken.
  /// Returns true if it's safe (NOT rooted/jailbroken), false otherwise.
  static Future<bool> isDeviceSecure() async {
    // Skip check in debug mode for development ease if needed, 
    // but for production hardening, we should be strict.
    try {
      bool jailbroken = await FlutterJailbreakDetection.jailbroken;
      bool developerMode = false;
      
      // Developer mode check only works on Android
      if (Platform.isAndroid) {
        developerMode = await FlutterJailbreakDetection.developerMode;
      }

      return !jailbroken && !developerMode;
    } on PlatformException {
      // If the plugin fails, we assume insecure for safety in high-risk apps,
      // or we can allow it if we don't want to block users on weird errors.
      return false; 
    } catch (_) {
      return false;
    }
  }

  /// Throws an error if the device is not secure.
  static Future<void> ensureSecureDevice() async {
    final isSecure = await isDeviceSecure();
    if (!isSecure) {
      throw Exception('⚠️ عذراً، لا يمكن إجراء هذه العملية على جهاز تم كسر حمايته (Root/Jailbreak) أو في وضع المطورين حرصاً على أمان محفظتك.');
    }
  }
}
