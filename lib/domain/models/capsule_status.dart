enum CapsuleStatus {
  draft,      // 草稿状态
  scheduled,  // 已计划，等待发布
  active,     // 已发布，正在进行
  expired,    // 已过期
  archived    // 已归档
}

extension CapsuleStatusExtension on CapsuleStatus {
  String get displayName {
    switch (this) {
      case CapsuleStatus.draft:
        return '草稿';
      case CapsuleStatus.scheduled:
        return '待发布';
      case CapsuleStatus.active:
        return '进行中';
      case CapsuleStatus.expired:
        return '已过期';
      case CapsuleStatus.archived:
        return '已归档';
    }
  }

  bool get isEditable => 
    this == CapsuleStatus.draft || 
    this == CapsuleStatus.scheduled;

  bool get isShareable => 
    this == CapsuleStatus.active || 
    this == CapsuleStatus.expired;
}

class CapsuleLifecycleManager {
  static CapsuleStatus determineCapsuleStatus(
    DateTime createdAt, 
    DateTime openAt, 
    DateTime? closedAt
  ) {
    final now = DateTime.now();

    // 草稿状态
    if (openAt.isAfter(now)) {
      return CapsuleStatus.draft;
    }

    // 已过期
    if (closedAt != null && now.isAfter(closedAt)) {
      return CapsuleStatus.expired;
    }

    // 进行中
    if (now.isAfter(openAt) && 
        (closedAt == null || now.isBefore(closedAt))) {
      return CapsuleStatus.active;
    }

    // 默认返回草稿
    return CapsuleStatus.draft;
  }

  static Duration getRemainingTime(DateTime openAt, DateTime? closedAt) {
    final now = DateTime.now();
    
    if (closedAt != null && now.isAfter(closedAt)) {
      return Duration.zero;
    }

    return openAt.isAfter(now) 
      ? openAt.difference(now)
      : (closedAt ?? DateTime.now()).difference(now);
  }
}
