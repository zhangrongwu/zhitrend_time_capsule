import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/capsule_collaboration.dart';
import '../../domain/models/time_capsule.dart';
import '../../domain/providers/capsule_provider.dart';
import '../../domain/services/capsule_collaboration_service.dart';
import '../../domain/services/permission_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class CapsuleInvitePage extends StatefulWidget {
  final TimeCapsule capsule;

  const CapsuleInvitePage({Key? key, required this.capsule}) : super(key: key);

  @override
  _CapsuleInvitePageState createState() => _CapsuleInvitePageState();
}

class _CapsuleInvitePageState extends State<CapsuleInvitePage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  CollaborationRole _selectedRole = CollaborationRole.viewer;

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

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _inviteCollaborator() {
    if (_formKey.currentState!.validate()) {
      // 在实际应用中，这里应该从身份验证服务获取当前用户
      final currentUser = _capsuleProvider.currentUser;

      // 检查是否有权限邀请协作者
      if (_permissionService.canInviteCollaborators(widget.capsule, currentUser)) {
        final updatedCollaboration = _collaborationService.inviteCollaborator(
          capsule: widget.capsule,
          inviteeEmail: _emailController.text.trim(),
          inviteeName: _nameController.text.trim(),
          role: _selectedRole,
        );

        // 更新胶囊的协作信息
        _capsuleProvider.updateCapsuleCollaboration(
          widget.capsule.id, 
          updatedCollaboration
        );

        // 发送邀请通知
        _collaborationService.sendInvitationNotification(
          updatedCollaboration.collaborators.last, 
          widget.capsule
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已成功邀请 ${_nameController.text}'),
            backgroundColor: Colors.green,
          ),
        );

        // 清空表单
        _emailController.clear();
        _nameController.clear();
        setState(() {
          _selectedRole = CollaborationRole.viewer;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('您没有权限邀请协作者'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('邀请协作者'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: '协作者姓名',
                hintText: '请输入协作者姓名',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入协作者姓名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: '协作者邮箱',
                hintText: '请输入协作者邮箱',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入邮箱地址';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return '请输入有效的邮箱地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text(
                '选择协作者角色',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CollaborationRole>(
                value: _selectedRole,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: CollaborationRole.viewer,
                    child: Text(
                      '查看者 - 仅可查看内容',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  DropdownMenuItem(
                    value: CollaborationRole.editor,
                    child: Text(
                      '编辑者 - 可编辑和添加内容',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
                onChanged: (role) {
                  setState(() {
                    _selectedRole = role!;
                  });
                },
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                onPressed: _inviteCollaborator,
                text: '发送邀请',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
