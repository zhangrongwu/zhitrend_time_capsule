import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/time_capsule.dart';
import '../../domain/models/capsule_status.dart';

class CapsuleCard extends StatelessWidget {
  final TimeCapsule capsule;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CapsuleCard({
    Key? key,
    required this.capsule,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 12),
              _buildDescription(context),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            capsule.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _buildStatusChip(context),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      capsule.description,
      style: Theme.of(context).textTheme.bodyMedium,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildDateInfo(context),
        _buildRemainingTimeInfo(context),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText;

    switch (capsule.status) {
      case CapsuleStatus.draft:
        chipColor = Colors.grey;
        statusText = '草稿';
        break;
      case CapsuleStatus.scheduled:
        chipColor = Colors.blue;
        statusText = '已计划';
        break;
      case CapsuleStatus.active:
        chipColor = Colors.green;
        statusText = '进行中';
        break;
      case CapsuleStatus.expired:
        chipColor = Colors.red;
        statusText = '已过期';
        break;
      case CapsuleStatus.archived:
        chipColor = Colors.purple;
        statusText = '已归档';
        break;
    }

    return Chip(
      label: Text(
        statusText,
        style: TextStyle(color: chipColor, fontSize: 12),
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildDateInfo(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          DateFormat('yyyy-MM-dd').format(capsule.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildRemainingTimeInfo(BuildContext context) {
    final remainingTime = capsule.remainingTime;
    final color = _getRemainingTimeColor(context, remainingTime);

    return Text(
      _formatRemainingTime(remainingTime),
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
    );
  }

  String _formatRemainingTime(Duration remainingTime) {
    if (remainingTime.isNegative) {
      return '已过期';
    }

    final days = remainingTime.inDays;
    final hours = remainingTime.inHours % 24;
    final minutes = remainingTime.inMinutes % 60;

    if (days > 0) {
      return '$days 天';
    } else if (hours > 0) {
      return '$hours 小时';
    } else {
      return '$minutes 分钟';
    }
  }

  Color _getRemainingTimeColor(BuildContext context, Duration remainingTime) {
    if (remainingTime.isNegative) {
      return Colors.red;
    } else if (remainingTime.inDays <= 7) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
