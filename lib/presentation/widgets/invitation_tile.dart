import 'package:flutter/material.dart';

import '../../domain/models/capsule_invitation.dart';

class InvitationTile extends StatelessWidget {
  final CapsuleInvitation invitation;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const InvitationTile({
    Key? key,
    required this.invitation,
    required this.onAccept,
    required this.onReject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: _buildInvitationIcon(),
        title: Text(
          '${invitation.inviterName} 邀请您加入胶囊',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '角色：${_getRoleDescription()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            _buildExpirationInfo(context),
          ],
        ),
        trailing: _buildActionButtons(context),
      ),
    );
  }

  Widget _buildInvitationIcon() {
    return CircleAvatar(
      backgroundColor: _getColorForRole(),
      child: Icon(
        Icons.email_outlined,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildExpirationInfo(BuildContext context) {
    final remainingDays = invitation.expiresAt?.difference(DateTime.now()).inDays ?? 0;
    
    return Text(
      remainingDays > 0 
        ? '邀请将在 $remainingDays 天后过期' 
        : '邀请已过期',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: remainingDays > 0 ? Colors.grey : Colors.red,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.check, color: Colors.green),
          onPressed: onAccept,
          tooltip: '接受邀请',
        ),
        IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: onReject,
          tooltip: '拒绝邀请',
        ),
      ],
    );
  }

  Color _getColorForRole() {
    switch (invitation.role) {
      case CollaborationRole.owner:
        return Colors.purple;
      case CollaborationRole.editor:
        return Colors.green;
      case CollaborationRole.viewer:
        return Colors.blue;
      case CollaborationRole.invitee:
        return Colors.orange;
    }
  }

  String _getRoleDescription() {
    switch (invitation.role) {
      case CollaborationRole.owner:
        return '所有者';
      case CollaborationRole.editor:
        return '编辑者';
      case CollaborationRole.viewer:
        return '查看者';
      case CollaborationRole.invitee:
        return '邀请者';
    }
  }
}
