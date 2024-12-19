import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../domain/providers/capsule_provider.dart';
import 'create_capsule_screen.dart';
import 'capsule_detail_screen.dart';
import '../widgets/empty_state.dart';

class CapsulesListScreen extends StatefulWidget {
  static const routeName = '/capsules-list';

  const CapsulesListScreen({Key? key}) : super(key: key);

  @override
  _CapsulesListScreenState createState() => _CapsulesListScreenState();
}

class _CapsulesListScreenState extends State<CapsulesListScreen> {
  @override
  void initState() {
    super.initState();
    // 在初始化时获取时间胶囊列表
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CapsuleProvider>().fetchCapsules();
    });
  }

  void _navigateToCreateCapsule() async {
    final result = await Navigator.of(context).pushNamed(CreateCapsuleScreen.routeName);
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('时间胶囊创建成功')),
      );
    }
  }

  void _navigateToCapsuleDetail(TimeCapsule capsule) {
    Navigator.of(context).pushNamed(
      CapsuleDetailScreen.routeName,
      arguments: capsule,
    );
  }

  Widget _buildCapsuleCard(TimeCapsule capsule) {
    final theme = Theme.of(context);
    final isUnlocked = capsule.canUnlock;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _navigateToCapsuleDetail(capsule),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      capsule.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isUnlocked ? '已解锁' : '未解锁',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isUnlocked ? Colors.green.shade800 : Colors.orange.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (capsule.description != null)
                Text(
                  capsule.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.lock_clock, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '解锁时间：${DateFormat('yyyy-MM-dd HH:mm').format(capsule.unlockTime)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final capsuleProvider = context.watch<CapsuleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的时间胶囊'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateCapsule,
            tooltip: '创建新的时间胶囊',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => capsuleProvider.fetchCapsules(),
        child: capsuleProvider.isLoading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : capsuleProvider.capsules.isEmpty
                ? EmptyState(
                    title: '还没有时间胶囊',
                    description: '点击右上角 + 创建你的第一个时间胶囊',
                    onAction: _navigateToCreateCapsule,
                    actionText: '创建时间胶囊',
                  )
                : ListView.builder(
                    itemCount: capsuleProvider.capsules.length,
                    itemBuilder: (context, index) {
                      final capsule = capsuleProvider.capsules[index];
                      return _buildCapsuleCard(capsule);
                    },
                  ),
      ),
    );
  }
}
