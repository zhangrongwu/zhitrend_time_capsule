import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/time_capsule.dart';
import '../models/capsule_status.dart';

class CapsuleLifecycleService {
  // 定期检查胶囊状态的间隔
  static const Duration _statusCheckInterval = Duration(minutes: 5);

  // 胶囊状态变更流控制器
  final _statusChangeController = StreamController<TimeCapsule>.broadcast();
  Stream<TimeCapsule> get statusChangeStream => _statusChangeController.stream;

  // 定时检查胶囊状态的定时器
  Timer? _statusCheckTimer;

  // 监控特定胶囊的状态
  void monitorCapsuleStatus(TimeCapsule capsule) {
    // 取消之前的定时器
    _statusCheckTimer?.cancel();

    // 创建新的定时器
    _statusCheckTimer = Timer.periodic(_statusCheckInterval, (timer) {
      final newStatus = CapsuleLifecycleManager.determineCapsuleStatus(
        capsule.createdAt, 
        capsule.openAt, 
        capsule.closedAt
      );

      // 如果状态发生变化，触发通知
      if (newStatus != capsule.status) {
        final updatedCapsule = capsule.copyWith(status: newStatus);
        _statusChangeController.add(updatedCapsule);
      }
    });
  }

  // 检查并更新胶囊状态
  TimeCapsule updateCapsuleStatus(TimeCapsule capsule) {
    final newStatus = CapsuleLifecycleManager.determineCapsuleStatus(
      capsule.createdAt, 
      capsule.openAt, 
      capsule.closedAt
    );

    return capsule.copyWith(status: newStatus);
  }

  // 获取胶囊剩余时间
  Duration getRemainingTime(TimeCapsule capsule) {
    return CapsuleLifecycleManager.getRemainingTime(
      capsule.openAt, 
      capsule.closedAt
    );
  }

  // 判断胶囊是否可编辑
  bool isCapsuleEditable(TimeCapsule capsule) {
    return capsule.status.isEditable;
  }

  // 判断胶囊是否可分享
  bool isCapsuleShareable(TimeCapsule capsule) {
    return capsule.status.isShareable;
  }

  // 自动归档过期胶囊
  Future<TimeCapsule> archiveCapsule(TimeCapsule capsule) async {
    if (capsule.status == CapsuleStatus.expired) {
      return capsule.copyWith(status: CapsuleStatus.archived);
    }
    return capsule;
  }

  // 批量处理胶囊状态
  List<TimeCapsule> batchUpdateCapsuleStatuses(List<TimeCapsule> capsules) {
    return capsules.map((capsule) => 
      updateCapsuleStatus(capsule)
    ).toList();
  }

  // 生命周期事件日志
  void logLifecycleEvent(TimeCapsule capsule, String event) {
    debugPrint('Capsule Lifecycle Event: $event - Capsule ID: ${capsule.id}');
    // 在实际应用中，可以替换为更复杂的日志记录系统
  }

  // 清理资源
  void dispose() {
    _statusCheckTimer?.cancel();
    _statusChangeController.close();
  }
}
