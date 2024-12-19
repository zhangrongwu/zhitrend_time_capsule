import '../models/capsule_collaboration.dart';
import '../models/time_capsule.dart';

class CapsuleCollaborationService {
  // 邀请协作者
  CapsuleCollaboration inviteCollaborator({
    required TimeCapsule capsule,
    required String inviteeEmail,
    required String inviteeName,
    CollaborationRole role = CollaborationRole.invitee,
  }) {
    // 生成唯一的用户ID（实际应用中应从身份系统获取）
    final userId = _generateTemporaryUserId(inviteeEmail);

    final newCollaborator = CapsuleCollaborator(
      userId: userId,
      username: inviteeName,
      email: inviteeEmail,
      role: role,
    );

    // 如果胶囊尚未启用协作，则启用
    final collaboration = capsule.collaboration ?? 
      CapsuleCollaboration(
        capsuleId: capsule.id, 
        isCollaborative: true
      );

    return collaboration.addCollaborator(newCollaborator);
  }

  // 接受邀请
  CapsuleCollaboration acceptInvitation({
    required CapsuleCollaboration collaboration,
    required String userId,
  }) {
    final updatedCollaborators = collaboration.collaborators.map((collaborator) {
      return collaborator.userId == userId
        ? CapsuleCollaborator(
            userId: collaborator.userId,
            username: collaborator.username,
            email: collaborator.email,
            role: collaborator.role,
            joinedAt: DateTime.now(),
            hasAccepted: true,
          )
        : collaborator;
    }).toList();

    return CapsuleCollaboration(
      capsuleId: collaboration.capsuleId,
      collaborators: updatedCollaborators,
      isCollaborative: true,
      createdAt: collaboration.createdAt,
    );
  }

  // 更改协作者角色
  CapsuleCollaboration changeCollaboratorRole({
    required CapsuleCollaboration collaboration,
    required String userId,
    required CollaborationRole newRole,
  }) {
    // 检查当前用户是否有权限更改角色
    return collaboration.updateCollaboratorRole(userId, newRole);
  }

  // 移除协作者
  CapsuleCollaboration removeCollaborator({
    required CapsuleCollaboration collaboration,
    required String userId,
  }) {
    return collaboration.removeCollaborator(userId);
  }

  // 检查用户是否有编辑权限
  bool canEdit(CapsuleCollaboration collaboration, String userId) {
    return collaboration.collaborators.any(
      (collaborator) => 
        collaborator.userId == userId && 
        collaborator.canEdit
    );
  }

  // 检查用户是否有查看权限
  bool canView(CapsuleCollaboration collaboration, String userId) {
    return collaboration.collaborators.any(
      (collaborator) => 
        collaborator.userId == userId && 
        collaborator.canView
    );
  }

  // 生成临时用户ID（实际应用中应使用更安全的方法）
  String _generateTemporaryUserId(String email) {
    return email.hashCode.toString();
  }

  // 发送邀请通知（可以集成邮件服务）
  void sendInvitationNotification(
    CapsuleCollaborator invitee, 
    TimeCapsule capsule
  ) {
    // TODO: 实现邀请通知逻辑
    print('发送邀请给 ${invitee.email}，胶囊：${capsule.title}');
  }
}
