import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'capsule_status.dart';
import 'capsule_collaboration.dart';

enum CapsuleContentType {
  text,
  image,
  video,
  audio,
  model3D
}

enum CapsulePrivacy {
  public,
  private,
  friendsOnly
}

enum MediaType {
  image,
  video,
  audio,
  document
}

class CapsuleContent {
  final String id;
  final CapsuleContentType type;
  final String data;
  final String? metadata;

  CapsuleContent({
    required this.id,
    required this.type,
    required this.data,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toString().split('.').last,
    'data': data,
    'metadata': metadata,
  };

  factory CapsuleContent.fromJson(Map<String, dynamic> json) => CapsuleContent(
    id: json['id'],
    type: CapsuleContentType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type']
    ),
    data: json['data'],
    metadata: json['metadata'],
  );
}

class CapsuleMedia {
  final String id;
  final String url;
  final MediaType type;
  final String? description;
  final DateTime uploadedAt;

  CapsuleMedia({
    required this.id,
    required this.url,
    required this.type,
    this.description,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'type': type.toString().split('.').last,
    'description': description,
    'uploadedAt': uploadedAt.toIso8601String(),
  };

  factory CapsuleMedia.fromJson(Map<String, dynamic> json) => CapsuleMedia(
    id: json['id'],
    url: json['url'],
    type: MediaType.values.firstWhere(
      (e) => e.toString().split('.').last == json['type']
    ),
    description: json['description'],
    uploadedAt: DateTime.parse(json['uploadedAt']),
  );
}

class TimeCapsule {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime openAt;
  final DateTime? closedAt;
  final List<String> tags;
  final List<CapsuleMedia> media;
  final CapsuleStatus status;
  final bool isPrivate;
  final String? password;
  final String creatorId;
  final String ownerId;
  final CapsuleCommunity? collaboration;

  TimeCapsule({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.openAt,
    this.closedAt,
    this.tags = const [],
    this.media = const [],
    required this.status,
    this.isPrivate = false,
    this.password,
    required this.creatorId,
    required this.ownerId,
    this.collaboration,
  });

  TimeCapsule copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? openAt,
    DateTime? closedAt,
    List<String>? tags,
    List<CapsuleMedia>? media,
    CapsuleStatus? status,
    bool? isPrivate,
    String? password,
    String? creatorId,
    String? ownerId,
    CapsuleCommunity? collaboration,
  }) {
    return TimeCapsule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      openAt: openAt ?? this.openAt,
      closedAt: closedAt ?? this.closedAt,
      tags: tags ?? this.tags,
      media: media ?? this.media,
      status: status ?? this.status,
      isPrivate: isPrivate ?? this.isPrivate,
      password: password ?? this.password,
      creatorId: creatorId ?? this.creatorId,
      ownerId: ownerId ?? this.ownerId,
      collaboration: collaboration ?? this.collaboration,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'openAt': openAt.toIso8601String(),
    'closedAt': closedAt?.toIso8601String(),
    'tags': tags,
    'media': media.map((m) => m.toJson()).toList(),
    'status': status.toString().split('.').last,
    'isPrivate': isPrivate,
    'password': password,
    'creatorId': creatorId,
    'ownerId': ownerId,
    'collaboration': collaboration?.toJson(),
  };

  factory TimeCapsule.fromJson(Map<String, dynamic> json) => TimeCapsule(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    openAt: DateTime.parse(json['openAt']),
    closedAt: json['closedAt'] != null ? DateTime.parse(json['closedAt']) : null,
    tags: List<String>.from(json['tags'] ?? []),
    media: (json['media'] as List?)?.map((m) => CapsuleMedia.fromJson(m)).toList() ?? [],
    status: CapsuleStatus.values.firstWhere(
      (e) => e.toString().split('.').last == json['status']
    ),
    isPrivate: json['isPrivate'] ?? false,
    password: json['password'],
    creatorId: json['creatorId'],
    ownerId: json['ownerId'],
    collaboration: json['collaboration'] != null 
      ? CapsuleCommunity.fromJson(json['collaboration']) 
      : null,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeCapsule &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  // 添加计算剩余时间的方法
  Duration get remainingTime {
    final now = DateTime.now();
    if (now.isBefore(openAt)) {
      return openAt.difference(now);
    } else if (closedAt != null && now.isAfter(closedAt)) {
      return Duration.zero;
    } else if (closedAt != null) {
      return closedAt!.difference(now);
    }
    return const Duration(days: 365); // 默认一年
  }

  // 检查胶囊是否可以打开
  bool get canOpen {
    final now = DateTime.now();
    return now.isAtSameMomentAs(openAt) || now.isAfter(openAt);
  }

  // 检查胶囊是否已过期
  bool get isExpired {
    final now = DateTime.now();
    return closedAt != null && now.isAfter(closedAt!);
  }

  // 检查是否可以编辑
  bool get isEditable {
    return status == CapsuleStatus.draft || status == CapsuleStatus.scheduled;
  }

  // 检查是否可以添加协作者
  bool get canAddCollaborators {
    return status == CapsuleStatus.draft || status == CapsuleStatus.scheduled;
  }

  // 获取胶囊的总媒体数量
  int get totalMediaCount => media.length;

  // 获取特定类型的媒体数量
  int getMediaCountByType(MediaType type) {
    return media.where((m) => m.type == type).length;
  }

  // 检查是否需要密码
  bool get requiresPassword => isPrivate && password != null;

  // 获取协作者数量
  int get collaboratorCount => collaboration?.collaborators.length ?? 0;

  // 检查用户是否是协作者
  bool isCollaborator(String userId) {
    return collaboration?.collaborators.any((c) => c.user.id == userId) ?? false;
  }

  // 获取用户在胶囊中的角色
  CollaborationRole? getUserRole(String userId) {
    final collaborator = collaboration?.collaborators.firstWhere(
      (c) => c.user.id == userId, 
      orElse: () => null
    );
    return collaborator?.role;
  }

  // 创建一个新的胶囊实例，但保留原始ID
  TimeCapsule duplicate() {
    return TimeCapsule(
      id: id,  // 保留原始ID，但实际使用时可能需要生成新ID
      title: title,
      description: description,
      createdAt: DateTime.now(),
      openAt: openAt,
      closedAt: closedAt,
      tags: List.from(tags),
      media: List.from(media),
      status: CapsuleStatus.draft,
      isPrivate: isPrivate,
      password: password,
      creatorId: creatorId,
      ownerId: ownerId,
      collaboration: null,  // 重置协作者
    );
  }
}
