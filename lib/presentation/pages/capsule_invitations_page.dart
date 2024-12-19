import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/capsule_invitation.dart';
import '../../domain/providers/capsule_provider.dart';
import '../../domain/services/invitation_service.dart';
import '../widgets/invitation_tile.dart';

class CapsuleInvitationsPage extends StatefulWidget {
  const CapsuleInvitationsPage({Key? key}) : super(key: key);

  @override
  _CapsuleInvitationsPageState createState() => _CapsuleInvitationsPageState();
}

class _CapsuleInvitationsPageState extends State<CapsuleInvitationsPage> {
  late InvitationService _invitationService;
  late CapsuleProvider _capsuleProvider;
  List<CapsuleInvitation> _pendingInvitations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    _invitationService = InvitationService(
      capsuleProvider: _capsuleProvider
    );
    _loadPendingInvitations();
  }

  Future<void> _loadPendingInvitations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 在实际应用中，这里应该从当前登录用户获取邮箱
      final userEmail = _capsuleProvider.currentUser.email;
      final invitations = await _invitationService.getPendingInvitationsForUser(userEmail);
      
      setState(() {
        _pendingInvitations = invitations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('加载邀请失败：${e.toString()}');
    }
  }

  Future<void> _acceptInvitation(CapsuleInvitation invitation) async {
    try {
      await _invitationService.acceptInvitation(invitation);
      await _loadPendingInvitations();
      _showSuccessSnackBar('已接受邀请');
    } catch (e) {
      _showErrorSnackBar('接受邀请失败：${e.toString()}');
    }
  }

  Future<void> _rejectInvitation(CapsuleInvitation invitation) async {
    try {
      await _invitationService.rejectInvitation(invitation);
      await _loadPendingInvitations();
      _showSuccessSnackBar('已拒绝邀请');
    } catch (e) {
      _showErrorSnackBar('拒绝邀请失败：${e.toString()}');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的邀请'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingInvitations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildInvitationsList(),
    );
  }

  Widget _buildInvitationsList() {
    if (_pendingInvitations.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pendingInvitations.length,
      itemBuilder: (context, index) {
        final invitation = _pendingInvitations[index];
        return InvitationTile(
          invitation: invitation,
          onAccept: () => _acceptInvitation(invitation),
          onReject: () => _rejectInvitation(invitation),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.mark_email_read_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无新的邀请',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '当有人邀请您加入时，邀请将显示在这里',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
