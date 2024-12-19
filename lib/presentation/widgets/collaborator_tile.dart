import 'package:flutter/material.dart';

import '../../domain/models/capsule_collaboration.dart';

class CollaboratorTile extends StatelessWidget {
  final CapsuleCollaborator collaborator;
  final bool canManage;
  final VoidCallback onRemove;
  final Function(CollaborationRole) onChangeRole;

  const CollaboratorTile({
    Key? key,
    required this.collaborator,
    this.canManage = false,
    required this.onRemove,
    required this.onChangeRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: _buildAvatar(),
        title: Text(
          collaborator.username,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              collaborator.email,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            _buildRoleChip(context),
          ],
        ),
        trailing: canManage ? _buildManageActions(context) : null,
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      backgroundColor: _getColorForRole(),
      child: Text(
        collaborator.username[0].toUpperCase(),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildRoleChip(BuildContext context) {
    return Chip(
      label: Text(_getRoleLabel()),
      backgroundColor: _getColorForRole().withOpacity(0.2),
      labelStyle: TextStyle(
        color: _getColorForRole(),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildManageActions(BuildContext context) {
    return PopupMenuButton<CollaborationRole>(
      icon: const Icon(Icons.more_vert),
      onSelected: (CollaborationRole role) {
        if (role == CollaborationRole.remove) {
          onRemove();
        } else {
          onChangeRole(role);
        }
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem(
          value: CollaborationRole.viewer,
          child: const Text('设为查看者'),
          enabled: collaborator.role != CollaborationRole.viewer,
        ),
        PopupMenuItem(
          value: CollaborationRole.editor,
          child: const Text('设为编辑者'),
          enabled: collaborator.role != CollaborationRole.editor,
        ),
        const PopupMenuItem(
          value: CollaborationRole.remove,
          child: Text(
            '移除协作者',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }

  Color _getColorForRole() {
    switch (collaborator.role) {
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

  String _getRoleLabel() {
    switch (collaborator.role) {
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
