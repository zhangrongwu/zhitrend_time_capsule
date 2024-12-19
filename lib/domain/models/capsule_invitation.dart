import 'package:uuid/uuid.dart';

import 'capsule_collaboration.dart';
import 'time_capsule.dart';

enum InvitationStatus {
  pending,   // 待接受
  accepted,  // 已接受
  rejected,  // 已拒绝
  expired    // 已过期
}

class CapsuleInvitation {
  final String id;
  final String capsuleId;
  final String inviterId;
  final String inviterName;
  final String inviteeEmail;
  final String inviteeName;
  final CollaborationRole role;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final InvitationStatus status;

  CapsuleInvitation({
    String? id,
    required this.capsuleId,
    required this.inviterId,
    required this.inviterName,
    required this.inviteeEmail,
    required this.inviteeName,
    this.role = CollaborationRole.viewer,
    DateTime? createdAt,
    this.expiresAt,
    this.status = InvitationStatus.pending,
  }) : 
    id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now(),
    expiresAt = expiresAt ?? DateTime.now().add(const Duration(days: 7));

  // 检查邀请是否已过期
  bool get isExpired => 
    status == InvitationStatus.expired || 
    (expiresAt != null && DateTime.now().isAfter(expiresAt!));

  // 接受邀请
  CapsuleInvitation accept() {
    return CapsuleInvitation(
      id: id,
      capsuleId: capsuleId,
      inviterId: inviterId,
      inviterName: inviterName,
      inviteeEmail: inviteeEmail,
      inviteeName: inviteeName,
      role: role,
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: InvitationStatus.accepted,
    );
  }

  // 拒绝邀请
  CapsuleInvitation reject() {
    return CapsuleInvitation(
      id: id,
      capsuleId: capsuleId,
      inviterId: inviterId,
      inviterName: inviterName,
      inviteeEmail: inviteeEmail,
      inviteeName: inviteeName,
      role: role,
      createdAt: createdAt,
      expiresAt: expiresAt,
      status: InvitationStatus.rejected,
    );
  }

  // 使邀请过期
  CapsuleInvitation expire() {
    return CapsuleInvitation(
      id: id,
      capsuleId: capsuleId,
      inviterId: inviterId,
      inviterName: inviterName,
      inviteeEmail: inviteeEmail,
      inviteeName: inviteeName,
      role: role,
      createdAt: createdAt,
      expiresAt: DateTime.now(),
      status: InvitationStatus.expired,
    );
  }

  // JSON序列化
  Map<String, dynamic> toJson() => {
    'id': id,
    'capsuleId': capsuleId,
    'inviterId': inviterId,
    'inviterName': inviterName,
    'inviteeEmail': inviteeEmail,
    'inviteeName': inviteeName,
    'role': role.toString().split('.').last,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt?.toIso8601String(),
    'status': status.toString().split('.').last,
  };

  // JSON反序列化
  factory CapsuleInvitation.fromJson(Map<String, dynamic> json) {
    return CapsuleInvitation(
      id: json['id'],
      capsuleId: json['capsuleId'],
      inviterId: json['inviterId'],
      inviterName: json['inviterName'],
      inviteeEmail: json['inviteeEmail'],
      inviteeName: json['inviteeName'],
      role: CollaborationRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => CollaborationRole.viewer
      ),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null 
        ? DateTime.parse(json['expiresAt']) 
        : null,
      status: InvitationStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => InvitationStatus.pending
      ),
    );
  }

  // 友好的状态描述
  String get statusDescription {
    switch (status) {
      case InvitationStatus.pending:
        return '等待接受';
      case InvitationStatus.accepted:
        return '已接受';
      case InvitationStatus.rejected:
        return '已拒绝';
      case InvitationStatus.expired:
        return '已过期';
    }
  }
}
