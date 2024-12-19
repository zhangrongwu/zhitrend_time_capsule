import 'user.dart';

enum CollaborationRole {
  owner,     // 创建者，拥有最高权限
  editor,    // 可编辑内容
  viewer,    // 仅可查看
  invitee,   // 待接受邀请
  remove     // 移除协作者
}

class CapsuleCollaborator {
  final String userId;
  final String username;
  final String email;
  final CollaborationRole role;
  final DateTime joinedAt;
  final bool hasAccepted;

  CapsuleCollaborator({
    required this.userId,
    required this.username,
    required this.email,
    this.role = CollaborationRole.invitee,
    DateTime? joinedAt,
    this.hasAccepted = false,
  }) : joinedAt = joinedAt ?? DateTime.now();

  bool get canEdit => 
    role == CollaborationRole.editor || 
    role == CollaborationRole.owner;

  bool get canView => 
    role != CollaborationRole.invitee;

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'username': username,
    'email': email,
    'role': role.toString().split('.').last,
    'joinedAt': joinedAt.toIso8601String(),
    'hasAccepted': hasAccepted,
  };

  factory CapsuleCollaborator.fromJson(Map<String, dynamic> json) {
    return CapsuleCollaborator(
      userId: json['userId'],
      username: json['username'],
      email: json['email'],
      role: CollaborationRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => CollaborationRole.invitee
      ),
      joinedAt: DateTime.parse(json['joinedAt']),
      hasAccepted: json['hasAccepted'] ?? false,
    );
  }
}

class CapsuleCommunity {
  final String capsuleId;
  final List<CapsuleCollaborator> collaborators;

  CapsuleCommunity({
    required this.capsuleId,
    required this.collaborators,
  });

  factory CapsuleCommunity.fromJson(Map<String, dynamic> json) {
    return CapsuleCommunity(
      capsuleId: json['capsuleId'],
      collaborators: (json['collaborators'] as List?)
        ?.map((c) => CapsuleCollaborator.fromJson(c))
        .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'capsuleId': capsuleId,
      'collaborators': collaborators.map((c) => c.toJson()).toList(),
    };
  }
}

class CapsuleCollaboration {
  final String capsuleId;
  final List<CapsuleCollaborator> collaborators;
  final bool isCollaborative;
  final DateTime createdAt;

  CapsuleCollaboration({
    required this.capsuleId,
    List<CapsuleCollaborator>? collaborators,
    this.isCollaborative = false,
    DateTime? createdAt,
  }) : 
    collaborators = collaborators ?? [],
    createdAt = createdAt ?? DateTime.now();

  // 添加协作者
  CapsuleCollaboration addCollaborator(CapsuleCollaborator collaborator) {
    final updatedCollaborators = List<CapsuleCollaborator>.from(collaborators);
    
    // 避免重复添加
    if (!updatedCollaborators.any((c) => c.userId == collaborator.userId)) {
      updatedCollaborators.add(collaborator);
    }

    return CapsuleCollaboration(
      capsuleId: capsuleId,
      collaborators: updatedCollaborators,
      isCollaborative: true,
      createdAt: createdAt,
    );
  }

  // 移除协作者
  CapsuleCollaboration removeCollaborator(String userId) {
    final updatedCollaborators = collaborators
      .where((c) => c.userId != userId)
      .toList();

    return CapsuleCollaboration(
      capsuleId: capsuleId,
      collaborators: updatedCollaborators,
      isCollaborative: updatedCollaborators.isNotEmpty,
      createdAt: createdAt,
    );
  }

  // 更新协作者角色
  CapsuleCollaboration updateCollaboratorRole(
    String userId, 
    CollaborationRole newRole
  ) {
    final updatedCollaborators = collaborators.map((collaborator) {
      return collaborator.userId == userId
        ? CapsuleCollaborator(
            userId: collaborator.userId,
            username: collaborator.username,
            email: collaborator.email,
            role: newRole,
            joinedAt: collaborator.joinedAt,
            hasAccepted: collaborator.hasAccepted,
          )
        : collaborator;
    }).toList();

    return CapsuleCollaboration(
      capsuleId: capsuleId,
      collaborators: updatedCollaborators,
      isCollaborative: true,
      createdAt: createdAt,
    );
  }

  // 获取所有编辑者
  List<CapsuleCollaborator> get editors => 
    collaborators.where((c) => c.canEdit).toList();

  // 获取所有查看者
  List<CapsuleCollaborator> get viewers => 
    collaborators.where((c) => c.canView && !c.canEdit).toList();

  // 获取所有邀请中的协作者
  List<CapsuleCollaborator> get pendingInvites => 
    collaborators.where((c) => !c.hasAccepted).toList();

  Map<String, dynamic> toJson() => {
    'capsuleId': capsuleId,
    'collaborators': collaborators.map((c) => c.toJson()).toList(),
    'isCollaborative': isCollaborative,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CapsuleCollaboration.fromJson(Map<String, dynamic> json) {
    return CapsuleCollaboration(
      capsuleId: json['capsuleId'],
      collaborators: (json['collaborators'] as List)
        .map((c) => CapsuleCollaborator.fromJson(c))
        .toList(),
      isCollaborative: json['isCollaborative'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
