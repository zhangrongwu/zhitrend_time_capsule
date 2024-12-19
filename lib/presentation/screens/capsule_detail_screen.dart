import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/capsule_provider.dart';
import '../widgets/primary_button.dart';

class CapsuleDetailScreen extends StatefulWidget {
  static const routeName = '/capsule-detail';

  final TimeCapsule capsule;

  const CapsuleDetailScreen({Key? key, required this.capsule}) : super(key: key);

  @override
  _CapsuleDetailScreenState createState() => _CapsuleDetailScreenState();
}

class _CapsuleDetailScreenState extends State<CapsuleDetailScreen> {
  late TimeCapsule _capsule;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _capsule = widget.capsule;
  }

  void _confirmDeleteCapsule() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除时间胶囊'),
        content: const Text('确定要删除这个时间胶囊吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteCapsule();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _deleteCapsule() async {
    setState(() => _isLoading = true);
    final capsuleProvider = context.read<CapsuleProvider>();
    
    final success = await capsuleProvider.deleteCapsule(_capsule.id);
    
    setState(() => _isLoading = false);
    
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('时间胶囊已删除')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(capsuleProvider.error ?? '删除失败')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = _capsule.canUnlock;

    return Scaffold(
      appBar: AppBar(
        title: Text(_capsule.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _confirmDeleteCapsule,
            tooltip: '删除时间胶囊',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 状态和解锁时间
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUnlocked ? Colors.green.shade100 : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isUnlocked ? '已解锁' : '未解锁',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUnlocked ? Colors.green.shade800 : Colors.orange.shade800,
                    ),
                  ),
                ),
                Text(
                  '解锁时间：${DateFormat('yyyy-MM-dd HH:mm').format(_capsule.unlockTime)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 描述
            if (_capsule.description != null)
              Text(
                _capsule.description!,
                style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
              ),
            const SizedBox(height: 16),

            // 内容
            if (isUnlocked && _capsule.content != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '胶囊内容',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _capsule.content!,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            else if (!isUnlocked)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.lock, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(
                      '时间胶囊尚未解锁',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '请等待至解锁时间：${DateFormat('yyyy-MM-dd HH:mm').format(_capsule.unlockTime)}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
