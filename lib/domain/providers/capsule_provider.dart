import 'package:flutter/foundation.dart';
import '../models/time_capsule.dart';
import '../models/capsule_status.dart';
import '../services/capsule_lifecycle_service.dart';
import '../models/capsule_invitation.dart';

class CapsuleProvider with ChangeNotifier {
  final CapsuleLifecycleService _lifecycleService = CapsuleLifecycleService();
  
  List<TimeCapsule> _capsules = [];
  TimeCapsule? _currentCapsule;

  List<TimeCapsule> get capsules => _capsules;
  TimeCapsule? get currentCapsule => _currentCapsule;

  // 获取不同状态的胶囊
  List<TimeCapsule> getCapsulesByStatus(CapsuleStatus status) {
    return _capsules.where((capsule) => capsule.status == status).toList();
  }

  // 创建新胶囊
  Future<TimeCapsule> createCapsule(TimeCapsule capsule) async {
    // 自动设置创建时间和状态
    final newCapsule = capsule.copyWith(
      createdAt: DateTime.now(),
      status: CapsuleStatus.draft
    );

    _capsules.add(newCapsule);
    _currentCapsule = newCapsule;
    
    _lifecycleService.logLifecycleEvent(newCapsule, 'Capsule Created');
    notifyListeners();
    return newCapsule;
  }

  // 更新胶囊
  Future<TimeCapsule> updateCapsule(TimeCapsule capsule) async {
    // 检查是否可编辑
    if (!_lifecycleService.isCapsuleEditable(capsule)) {
      throw Exception('Cannot edit capsule in current status');
    }

    final updatedCapsule = _lifecycleService.updateCapsuleStatus(capsule);
    
    final index = _capsules.indexWhere((c) => c.id == capsule.id);
    if (index != -1) {
      _capsules[index] = updatedCapsule;
      _currentCapsule = updatedCapsule;
    }

    _lifecycleService.logLifecycleEvent(updatedCapsule, 'Capsule Updated');
    notifyListeners();
    return updatedCapsule;
  }

  // 删除胶囊
  Future<void> deleteCapsule(TimeCapsule capsule) async {
    _capsules.removeWhere((c) => c.id == capsule.id);
    
    if (_currentCapsule?.id == capsule.id) {
      _currentCapsule = null;
    }

    _lifecycleService.logLifecycleEvent(capsule, 'Capsule Deleted');
    notifyListeners();
  }

  // 选择当前胶囊
  void selectCapsule(TimeCapsule capsule) {
    _currentCapsule = capsule;
    _lifecycleService.monitorCapsuleStatus(capsule);
    notifyListeners();
  }

  // 批量更新胶囊状态
  Future<void> updateAllCapsuleStatuses() async {
    _capsules = _lifecycleService.batchUpdateCapsuleStatuses(_capsules);
    notifyListeners();
  }

  // 获取即将到期的胶囊
  List<TimeCapsule> getUpcomingCapsules() {
    final now = DateTime.now();
    return _capsules.where((capsule) {
      final remainingTime = _lifecycleService.getRemainingTime(capsule);
      return remainingTime.inDays <= 7 && 
             capsule.status == CapsuleStatus.active;
    }).toList();
  }

  // 归档过期胶囊
  Future<void> archiveExpiredCapsules() async {
    final expiredCapsules = _capsules
        .where((capsule) => capsule.status == CapsuleStatus.expired)
        .toList();

    for (var capsule in expiredCapsules) {
      final archivedCapsule = await _lifecycleService.archiveCapsule(capsule);
      final index = _capsules.indexOf(capsule);
      _capsules[index] = archivedCapsule;
    }

    notifyListeners();
  }

  // 监听胶囊状态变更
  void initStatusChangeListener() {
    _lifecycleService.statusChangeStream.listen((updatedCapsule) {
      final index = _capsules.indexWhere((c) => c.id == updatedCapsule.id);
      if (index != -1) {
        _capsules[index] = updatedCapsule;
        notifyListeners();
      }
    });
  }

  // 邀请相关方法
  Future<void> saveInvitation(CapsuleInvitation invitation) async {
    try {
      // 实际应用中应调用后端API保存邀请
      _invitations.add(invitation);
      notifyListeners();
    } catch (e) {
      print('保存邀请失败: $e');
      rethrow;
    }
  }

  Future<void> updateInvitation(CapsuleInvitation invitation) async {
    try {
      // 实际应用中应调用后端API更新邀请
      final index = _invitations.indexWhere((inv) => inv.id == invitation.id);
      if (index != -1) {
        _invitations[index] = invitation;
        notifyListeners();
      }
    } catch (e) {
      print('更新邀请失败: $e');
      rethrow;
    }
  }

  Future<void> deleteInvitation(String invitationId) async {
    try {
      // 实际应用中应调用后端API删除邀请
      _invitations.removeWhere((inv) => inv.id == invitationId);
      notifyListeners();
    } catch (e) {
      print('删除邀请失败: $e');
      rethrow;
    }
  }

  Future<List<CapsuleInvitation>> getPendingInvitationsForUser(String userEmail) async {
    try {
      // 实际应用中应调用后端API获取邀请
      return _invitations.where((inv) => 
        inv.inviteeEmail == userEmail && 
        inv.status == InvitationStatus.pending
      ).toList();
    } catch (e) {
      print('获取邀请失败: $e');
      rethrow;
    }
  }

  Future<List<CapsuleInvitation>> getExpiredInvitations() async {
    try {
      // 实际应用中应调用后端API获取过期邀请
      return _invitations.where((inv) => inv.isExpired).toList();
    } catch (e) {
      print('获取过期邀请失败: $e');
      rethrow;
    }
  }

  Future<bool> checkInvitationExists(String capsuleId, String inviteeEmail) async {
    try {
      // 实际应用中应调用后端API检查邀请是否存在
      return _invitations.any((inv) => 
        inv.capsuleId == capsuleId && 
        inv.inviteeEmail == inviteeEmail &&
        inv.status == InvitationStatus.pending
      );
    } catch (e) {
      print('检查邀请失败: $e');
      rethrow;
    }
  }

  // 私有邀请列表，实际应用中应替换为远程存储
  final List<CapsuleInvitation> _invitations = [];

  @override
  void dispose() {
    _lifecycleService.dispose();
    super.dispose();
  }
}
