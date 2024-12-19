import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/time_capsule.dart';
import '../models/capsule_status.dart';

class CapsuleNotificationService {
  static final CapsuleNotificationService _instance = 
      CapsuleNotificationService._internal();
  factory CapsuleNotificationService() => _instance;
  CapsuleNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  // 初始化通知插件
  Future<void> init() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  // 处理通知点击事件
  void _onNotificationTap(NotificationResponse details) {
    // 可以在这里添加点击通知后的跳转逻辑
    debugPrint('Notification tapped: ${details.payload}');
  }

  // 调度胶囊即将到期通知
  Future<void> scheduleCapsuleExpirationNotification(TimeCapsule capsule) async {
    if (capsule.status != CapsuleStatus.active) return;

    final remainingTime = capsule.remainingTime;
    
    // 提前7天、3天、1天发送通知
    final notificationTimes = [
      capsule.closedAt?.subtract(Duration(days: 7)),
      capsule.closedAt?.subtract(Duration(days: 3)),
      capsule.closedAt?.subtract(Duration(days: 1)),
    ];

    for (var notificationTime in notificationTimes) {
      if (notificationTime != null && notificationTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: capsule.id.hashCode + notificationTime.day,
          title: '时间胶囊即将到期',
          body: '您的胶囊 "${capsule.title}" 将在 ${_formatRemainingTime(remainingTime)} 后到期',
          scheduledDate: notificationTime,
          payload: capsule.id,
        );
      }
    }
  }

  // 发送胶囊状态变更通知
  Future<void> sendCapsuleStatusChangeNotification(TimeCapsule capsule) async {
    String title = '';
    String body = '';

    switch (capsule.status) {
      case CapsuleStatus.active:
        title = '时间胶囊已解锁';
        body = '您的胶囊 "${capsule.title}" 现在可以打开了！';
        break;
      case CapsuleStatus.expired:
        title = '时间胶囊已过期';
        body = '您的胶囊 "${capsule.title}" 已经过期';
        break;
      default:
        return;
    }

    await _showImmediateNotification(
      title: title,
      body: body,
      payload: capsule.id,
    );
  }

  // 调度定期提醒
  Future<void> schedulePeriodicReminder(TimeCapsule capsule) async {
    // 每周发送一次进度提醒
    await _scheduleNotification(
      id: capsule.id.hashCode + 1000,
      title: '时间胶囊进度提醒',
      body: '您的胶囊 "${capsule.title}" 还有 ${_formatRemainingTime(capsule.remainingTime)} 到期',
      scheduledDate: DateTime.now().add(Duration(days: 7)),
      payload: capsule.id,
    );
  }

  // 内部方法：调度具体通知
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'capsule_channel',
            '时间胶囊通知',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
      );
    } catch (e) {
      debugPrint('通知调度错误: $e');
    }
  }

  // 立即显示通知
  Future<void> _showImmediateNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'capsule_channel',
        '时间胶囊通知',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // 取消特定胶囊的所有通知
  Future<void> cancelCapsuleNotifications(String capsuleId) async {
    await _flutterLocalNotificationsPlugin.cancel(capsuleId.hashCode);
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // 格式化剩余时间
  String _formatRemainingTime(Duration remainingTime) {
    if (remainingTime.inDays > 0) {
      return '${remainingTime.inDays}天';
    } else if (remainingTime.inHours > 0) {
      return '${remainingTime.inHours}小时';
    } else {
      return '${remainingTime.inMinutes}分钟';
    }
  }
}
