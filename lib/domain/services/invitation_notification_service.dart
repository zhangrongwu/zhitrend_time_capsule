import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/capsule_invitation.dart';
import '../models/time_capsule.dart';

class InvitationNotificationService {
  static final InvitationNotificationService _instance = 
      InvitationNotificationService._internal();
  factory InvitationNotificationService() => _instance;
  InvitationNotificationService._internal();

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
    debugPrint('邀请通知被点击: ${details.payload}');
  }

  // 发送新邀请通知
  Future<void> sendNewInvitationNotification(
    CapsuleInvitation invitation, 
    TimeCapsule capsule
  ) async {
    try {
      await _flutterLocalNotificationsPlugin.show(
        invitation.id.hashCode,
        '新的时间胶囊邀请',
        '${invitation.inviterName} 邀请您加入 "${capsule.title}"',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'invitation_channel',
            '时间胶囊邀请通知',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: invitation.id,
      );
    } catch (e) {
      debugPrint('发送邀请通知失败: $e');
    }
  }

  // 发送邀请状态变更通知
  Future<void> sendInvitationStatusNotification(
    CapsuleInvitation invitation, 
    TimeCapsule capsule
  ) async {
    String title = '';
    String body = '';

    switch (invitation.status) {
      case InvitationStatus.accepted:
        title = '邀请已接受';
        body = '${invitation.inviteeName} 已接受您的邀请加入 "${capsule.title}"';
        break;
      case InvitationStatus.rejected:
        title = '邀请已拒绝';
        body = '${invitation.inviteeName} 拒绝了您的邀请加入 "${capsule.title}"';
        break;
      case InvitationStatus.expired:
        title = '邀请已过期';
        body = '${invitation.inviteeName} 的邀请已过期';
        break;
      default:
        return;
    }

    try {
      await _flutterLocalNotificationsPlugin.show(
        invitation.id.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'invitation_channel',
            '时间胶囊邀请通知',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: invitation.id,
      );
    } catch (e) {
      debugPrint('发送邀请状态通知失败: $e');
    }
  }

  // 发送邀请即将过期通知
  Future<void> sendInvitationExpirationNotification(
    CapsuleInvitation invitation, 
    TimeCapsule capsule
  ) async {
    final remainingDays = invitation.expiresAt?.difference(DateTime.now()).inDays ?? 0;
    
    if (remainingDays <= 3 && remainingDays > 0) {
      try {
        await _flutterLocalNotificationsPlugin.show(
          invitation.id.hashCode,
          '邀请即将过期',
          '来自 ${invitation.inviterName} 的邀请将在 $remainingDays 天后过期',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'invitation_channel',
              '时间胶囊邀请通知',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: invitation.id,
        );
      } catch (e) {
        debugPrint('发送邀请过期通知失败: $e');
      }
    }
  }

  // 取消特定邀请的通知
  Future<void> cancelInvitationNotifications(String invitationId) async {
    await _flutterLocalNotificationsPlugin.cancel(invitationId.hashCode);
  }

  // 取消所有邀请通知
  Future<void> cancelAllInvitationNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
