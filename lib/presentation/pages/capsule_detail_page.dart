import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/models/time_capsule.dart';
import '../../domain/models/capsule_status.dart';
import '../../domain/providers/capsule_provider.dart';
import '../../domain/services/permission_service.dart';
import '../navigation/main_navigation.dart';
import '../widgets/capsule_media_gallery.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/permission_restricted_view.dart';

class CapsuleDetailPage extends StatefulWidget {
  final TimeCapsule capsule;
  final bool isPreview;

  const CapsuleDetailPage({
    Key? key, 
    required this.capsule,
    this.isPreview = false,
  }) : super(key: key);

  @override
  _CapsuleDetailPageState createState() => _CapsuleDetailPageState();
}

class _CapsuleDetailPageState extends State<CapsuleDetailPage> {
  late CapsuleProvider _capsuleProvider;
  late PermissionService _permissionService;
  late bool _canView;
  late bool _canEdit;

  @override
  void initState() {
    super.initState();
    _capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    _permissionService = PermissionService();
    
    // 在实际应用中，这里应该从身份验证服务获取当前用户
    final currentUser = _capsuleProvider.currentUser;
    
    _canView = _permissionService.canViewCapsule(widget.capsule, currentUser);
    _canEdit = _permissionService.canEditCapsule(widget.capsule, currentUser);
  }

  void _navigateToEditPage() {
    MainNavigation.navigateTo(
      MainNavigation.capsuleCreate,
      arguments: {
        'capsule': widget.capsule,
        'isEditing': true,
      },
    );
  }

  void _navigateToCollaborators() {
    MainNavigation.navigateTo(
      MainNavigation.capsuleCollaborators,
      arguments: {
        'capsule': widget.capsule,
      },
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除胶囊'),
        content: const Text('确定要删除这个时间胶囊吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              _capsuleProvider.deleteCapsule(widget.capsule.id);
              Navigator.of(context).pop();
              MainNavigation.navigateAndRemoveUntil(MainNavigation.home);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_canView) {
      return PermissionRestrictedView(
        title: '无法查看胶囊',
        message: '您没有权限查看此时间胶囊。',
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.capsule.title),
        actions: _buildAppBarActions(),
      ),
      body: _buildBody(),
    );
  }

  List<Widget> _buildAppBarActions() {
    final actions = <Widget>[];

    if (_canEdit) {
      actions.addAll([
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _navigateToEditPage,
          tooltip: '编辑胶囊',
        ),
        IconButton(
          icon: const Icon(Icons.group_add),
          onPressed: _navigateToCollaborators,
          tooltip: '管理协作者',
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: _showDeleteConfirmation,
          tooltip: '删除胶囊',
        ),
      ]);
    }

    return actions;
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusSection(),
            const SizedBox(height: 16),
            _buildTimerSection(),
            const SizedBox(height: 16),
            _buildDescriptionSection(),
            const SizedBox(height: 16),
            _buildMediaSection(),
            const SizedBox(height: 16),
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatusChip(),
        if (widget.capsule.collaboration != null)
          _buildCollaborationIndicator(),
      ],
    );
  }

  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;

    switch (widget.capsule.status) {
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
        style: TextStyle(color: chipColor),
      ),
      backgroundColor: chipColor.withOpacity(0.1),
      side: BorderSide.none,
    );
  }

  Widget _buildCollaborationIndicator() {
    return Row(
      children: [
        const Icon(Icons.group, size: 20, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          '${widget.capsule.collaboration?.collaborators.length ?? 0} 位协作者',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildTimerSection() {
    return CountdownTimer(
      targetTime: widget.capsule.closedAt ?? DateTime.now(),
      status: widget.capsule.status,
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '描述',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          widget.capsule.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildMediaSection() {
    if (widget.capsule.media == null || widget.capsule.media!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '媒体',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        CapsuleMediaGallery(media: widget.capsule.media!),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '详细信息',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildDetailRow(
          '创建时间',
          DateFormat('yyyy-MM-dd HH:mm').format(widget.capsule.createdAt),
        ),
        _buildDetailRow(
          '开启时间',
          widget.capsule.openedAt != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(widget.capsule.openedAt!)
            : '未设置',
        ),
        _buildDetailRow(
          '关闭时间',
          widget.capsule.closedAt != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(widget.capsule.closedAt!)
            : '未设置',
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
