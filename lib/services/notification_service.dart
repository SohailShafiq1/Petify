import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _plugin.initialize(initializationSettings);

    if (!kIsWeb) {
      await _requestPermissions();
    }

    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final macPlugin = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      await macPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  NotificationDetails _details() {
    const androidDetails = AndroidNotificationDetails(
      'petify_alerts',
      'Petify Alerts',
      channelDescription: 'Notifications for new pets and chat messages',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    return const NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );
  }

  String _truncate(String value, {int maxLength = 120}) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, maxLength - 3)}...';
  }

  Future<void> showPetUploaded({
    required String petName,
    String? city,
  }) async {
    if (!_initialized) {
      return;
    }

    final body = city != null && city.trim().isNotEmpty
        ? '$petName is now live in ${city.trim()}'
        : '$petName is now live on PetiFy';

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'Pet uploaded successfully',
      body,
      _details(),
    );
  }

  Future<void> showIncomingChatMessage({
    required String senderName,
    required String petName,
    required String message,
  }) async {
    if (!_initialized) {
      return;
    }

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      'New message from $senderName',
      '$petName: ${_truncate(message)}',
      _details(),
    );
  }
}
