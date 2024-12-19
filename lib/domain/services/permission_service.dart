import '../models/capsule_collaboration.dart';
import '../models/time_capsule.dart';
import '../models/user.dart';

class PermissionService {
  // 检查用户是否是胶囊的所有者
  bool isOwner(TimeCapsule capsule, User currentUser) {
    return capsule.ownerId == currentUser.id;
  }

  // 检查用户是否有编辑权限
  bool canEditCapsule(TimeCapsule capsule, User currentUser) {
    // 如果是所有者，直接允许编辑
    if (isOwner(capsule, currentUser)) return true;

    // 检查协作权限
    if (capsule.collaboration != null) {
      return capsule.collaboration!.collaborators.any((collaborator) => 
        collaborator.userId == currentUser.id && 
        collaborator.canEdit
      );
    }

    return false;
  }

  // 检查用户是否有查看权限
  bool canViewCapsule(TimeCapsule capsule, User currentUser) {
    // 所有者和协作者都可以查看
    if (isOwner(capsule, currentUser)) return true;

    // 检查协作权限
    if (capsule.collaboration != null) {
      return capsule.collaboration!.collaborators.any((collaborator) => 
        collaborator.userId == currentUser.id && 
        collaborator.canView
      );
    }

    return false;
  }

  // 检查用户是否可以删除胶囊
  bool canDeleteCapsule(TimeCapsule capsule, User currentUser) {
    // 只有所有者可以删除
    return isOwner(capsule, currentUser);
  }

  // 检查用户是否可以邀请协作者
  bool canInviteCollaborators(TimeCapsule capsule, User currentUser) {
    // 只有所有者和具有编辑权限的协作者可以邀请
    if (isOwner(capsule, currentUser)) return true;

    if (capsule.collaboration != null) {
      return capsule.collaboration!.collaborators.any((collaborator) => 
        collaborator.userId == currentUser.id && 
        collaborator.role == CollaborationRole.editor
      );
    }

    return false;
  }

  // 检查用户是否可以更改协作者角色
  bool canChangeCollaboratorRole(TimeCapsule capsule, User currentUser) {
    // 只有所有者可以更改协作者角色
    return isOwner(capsule, currentUser);
  }

  // 检查用户是否可以移除协作者
  bool canRemoveCollaborator(TimeCapsule capsule, User currentUser, String collaboratorId) {
    // 所有者可以移除任何协作者
    if (isOwner(capsule, currentUser)) return true;

    // 不允许协作者移除其他协作者
    return false;
  }

  // 获取用户在胶囊中的角色
  CollaborationRole getUserRole(TimeCapsule capsule, User currentUser) {
    // 如果是所有者，返回所有者角色
    if (isOwner(capsule, currentUser)) {
      return CollaborationRole.owner;
    }

    // 检查协作者角色
    if (capsule.collaboration != null) {
      final collaborator = capsule.collaboration!.collaborators.firstWhere(
        (c) => c.userId == currentUser.id,
        orElse: () => CapsuleCollaborator(
          userId: '', 
          username: '', 
          email: ''
        )
      );

      return collaborator.role;
    }

    // 如果不是所有者也不是协作者，返回默认的邀请者角色
    return CollaborationRole.invitee;
  }
}
