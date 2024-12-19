import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/capsule_collaboration.dart';
import '../../domain/models/time_capsule.dart';
import '../../domain/providers/capsule_provider.dart';
import '../../domain/services/capsule_collaboration_service.dart';
import '../../domain/services/permission_service.dart';
import '../widgets/collaborator_tile.dart';
import 'capsule_invite_page.dart';

class CapsuleCollaboratorsPage extends StatefulWidget {
  final TimeCapsule capsule;

  const CapsuleCollaboratorsPage({Key? key, required this.capsule}) : super(key: key);

  @override
  _CapsuleCollaboratorsPageState createState() => _CapsuleCollaboratorsPageState();
}

class _CapsuleCollaboratorsPageState extends State<CapsuleCollaboratorsPage> {
  late CapsuleCollaborationService _collaborationService;
  late PermissionService _permissionService;
  late CapsuleProvider _capsuleProvider;

  @override
  void initState() {
    super.initState();
    _collaborationService = CapsuleCollaborationService();
    _permissionService = PermissionService();
    _capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
  }

  void _removeCollaborator(String userId) {
    final currentUser = _capsuleProvider.currentUser;

    if (_permissionService.canRemoveCollaborator(widget.capsule, currentUser, userId)) {
      final updatedCollaboration = _collaborationService.removeCollaborator(
        collaboration: widget.capsule.collaboration!,
        userId: userId,
      );

      _capsuleProvider.updateCapsuleCollaboration(
        widget.capsule.id, 
        updatedCollaboration
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已成功移除协作者'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('您没有权限移除协作者'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _changeCollaboratorRole(String userId, CollaborationRole newRole) {
    final currentUser = _capsuleProvider.currentUser;

    if (_permissionService.canChangeCollaboratorRole(widget.capsule, currentUser)) {
      final updatedCollaboration = _collaborationService.changeCollaboratorRole(
        collaboration: widget.capsule.collaboration!,
        userId: userId,
        newRole: newRole,
      );

      _capsuleProvider.updateCapsuleCollaboration(
        widget.capsule.id, 
        updatedCollaboration
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('已将协作者角色更改为 ${_getRoleDescription(newRole)}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('您没有权限更改协作者角色'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getRoleDescription(CollaborationRole role) {
    switch (role) {
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

  @override
  Widget build(BuildContext context) {
    final collaboration = widget.capsule.collaboration;
    final currentUser = _capsuleProvider.currentUser;
    final userRole = _permissionService.getUserRole(widget.capsule, currentUser);

    return Scaffold(
      appBar: AppBar(
        title: const Text('协作者管理'),
        centerTitle: true,
        actions: [
          if (userRole == CollaborationRole.owner || 
              userRole == CollaborationRole.editor)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CapsuleInvitePage(capsule: widget.capsule),
                  ),
                );
              },
            ),
        ],
      ),
      body: collaboration == null || collaboration.collaborators.isEmpty
          ? _buildEmptyState()
          : _buildCollaboratorsList(collaboration, userRole),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.group_off_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无协作者',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CapsuleInvitePage(capsule: widget.capsule),
                ),
              );
            },
            child: const Text('邀请协作者'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaboratorsList(
    CapsuleCollaboration collaboration, 
    CollaborationRole currentUserRole
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: collaboration.collaborators.length,
      itemBuilder: (context, index) {
        final collaborator = collaboration.collaborators[index];
        
        return CollaboratorTile(
          collaborator: collaborator,
          canManage: currentUserRole == CollaborationRole.owner,
          onRemove: () => _removeCollaborator(collaborator.userId),
          onChangeRole: (newRole) => _changeCollaboratorRole(
            collaborator.userId, 
            newRole
          ),
        );
      },
    );
  }
}
