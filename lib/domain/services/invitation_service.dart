import 'dart:async';

import '../models/capsule_collaboration.dart';
import '../models/capsule_invitation.dart';
import '../models/time_capsule.dart';
import '../models/user.dart';
import '../providers/capsule_provider.dart';
import 'capsule_collaboration_service.dart';

class InvitationService {
  final CapsuleProvider _capsuleProvider;
  final CapsuleCollaborationService _collaborationService;

  InvitationService({
    required CapsuleProvider capsuleProvider,
    CapsuleCollaborationService? collaborationService,
  }) : 
    _capsuleProvider = capsuleProvider,
    _collaborationService = collaborationService ?? CapsuleCollaborationService();

  // 创建邀请
  CapsuleInvitation createInvitation({
    required TimeCapsule capsule,
    required User inviter,
    required String inviteeEmail,
    required String inviteeName,
    CollaborationRole role = CollaborationRole.viewer,
  }) {
    return CapsuleInvitation(
      capsuleId: capsule.id,
      inviterId: inviter.id,
      inviterName: inviter.username,
      inviteeEmail: inviteeEmail,
      inviteeName: inviteeName,
      role: role,
    );
  }

  // 发送邀请（模拟发送，实际应用中应集成邮件服务）
  Future<void> sendInvitation(CapsuleInvitation invitation) async {
    // 在实际应用中，这里应该调用后端API发送邮件
    print('发送邀请：${invitation.inviteeName} (${invitation.inviteeEmail})');
    
    // 保存邀请到本地或远程存储
    await _capsuleProvider.saveInvitation(invitation);
  }

  // 接受邀请
  Future<void> acceptInvitation(CapsuleInvitation invitation) async {
    // 检查邀请是否有效
    if (invitation.isExpired || 
        invitation.status != InvitationStatus.pending) {
      throw Exception('邀请无效或已过期');
    }

    // 获取胶囊
    final capsule = await _capsuleProvider.getCapsuleById(invitation.capsuleId);
    
    // 创建协作者
    final updatedCollaboration = _collaborationService.inviteCollaborator(
      capsule: capsule,
      inviteeEmail: invitation.inviteeEmail,
      inviteeName: invitation.inviteeName,
      role: invitation.role,
    );

    // 更新胶囊的协作信息
    await _capsuleProvider.updateCapsuleCollaboration(
      capsule.id, 
      updatedCollaboration
    );

    // 更新邀请状态
    final acceptedInvitation = invitation.accept();
    await _capsuleProvider.updateInvitation(acceptedInvitation);
  }

  // 拒绝邀请
  Future<void> rejectInvitation(CapsuleInvitation invitation) async {
    // 检查邀请是否有效
    if (invitation.isExpired || 
        invitation.status != InvitationStatus.pending) {
      throw Exception('邀请无效或已过期');
    }

    // 更新邀请状态
    final rejectedInvitation = invitation.reject();
    await _capsuleProvider.updateInvitation(rejectedInvitation);
  }

  // 取消邀请
  Future<void> cancelInvitation(CapsuleInvitation invitation) async {
    // 检查是否可以取消
    if (invitation.status != InvitationStatus.pending) {
      throw Exception('只能取消待处理的邀请');
    }

    // 更新邀请状态为过期
    final expiredInvitation = invitation.expire();
    await _capsuleProvider.updateInvitation(expiredInvitation);
  }

  // 获取用户的所有待处理邀请
  Future<List<CapsuleInvitation>> getPendingInvitationsForUser(String userEmail) async {
    return await _capsuleProvider.getPendingInvitationsForUser(userEmail);
  }

  // 定期清理过期邀请
  Future<void> cleanupExpiredInvitations() async {
    final expiredInvitations = await _capsuleProvider.getExpiredInvitations();
    
    for (var invitation in expiredInvitations) {
      await _capsuleProvider.deleteInvitation(invitation.id);
    }
  }

  // 检查邀请是否已存在
  Future<bool> checkInvitationExists(
    String capsuleId, 
    String inviteeEmail
  ) async {
    return await _capsuleProvider.checkInvitationExists(
      capsuleId, 
      inviteeEmail
    );
  }
}
