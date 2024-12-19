import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';

import '../../domain/models/time_capsule.dart';
import '../../domain/providers/capsule_provider.dart';
import '../navigation/main_navigation.dart';
import '../widgets/capsule_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late CapsuleProvider _capsuleProvider;
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  List<TimeCapsule> _filteredCapsules = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadCapsules();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCapsules() async {
    await _capsuleProvider.fetchCapsules();
    _updateFilteredCapsules();
  }

  void _updateFilteredCapsules() {
    final searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredCapsules = _capsuleProvider.capsules.where((capsule) {
        return capsule.title.toLowerCase().contains(searchTerm) ||
               capsule.description.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  void _navigateToCapsuleDetail(TimeCapsule capsule) {
    MainNavigation.navigateTo(
      MainNavigation.capsuleDetail,
      arguments: {
        'capsule': capsule,
        'isPreview': false,
      },
    );
  }

  void _navigateToCapsuleCreate() {
    MainNavigation.navigateTo(MainNavigation.capsuleCreate);
  }

  void _navigateToInvitations() {
    MainNavigation.navigateTo(MainNavigation.capsuleInvitations);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的时间胶囊'),
        actions: [
          IconButton(
            icon: const Icon(Icons.email_outlined),
            onPressed: _navigateToInvitations,
            tooltip: '邀请',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCapsules,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverToBoxAdapter(
                child: CustomSearchBar(
                  controller: _searchController,
                  onChanged: (value) {
                    _updateFilteredCapsules();
                    setState(() {
                      _isSearching = value.isNotEmpty;
                    });
                  },
                  hintText: '搜索时间胶囊',
                ),
              ),
            ),
            _buildCapsuleList(),
          ],
        ),
      ),
      floatingActionButton: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
        openBuilder: (context, _) => const CapsuleCreatePage(),
        closedElevation: 6,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        closedColor: Theme.of(context).colorScheme.primary,
        closedBuilder: (context, openContainer) => FloatingActionButton(
          onPressed: openContainer,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCapsuleList() {
    if (_capsuleProvider.isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_filteredCapsules.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          title: _isSearching 
            ? '没有找到匹配的时间胶囊' 
            : '还没有时间胶囊',
          description: _isSearching
            ? '尝试使用其他关键词搜索'
            : '点击右下角的 + 号创建你的第一个时间胶囊',
          onAction: _isSearching ? null : _navigateToCapsuleCreate,
          actionText: '创建胶囊',
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final capsule = _filteredCapsules[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CapsuleCard(
              capsule: capsule,
              onTap: () => _navigateToCapsuleDetail(capsule),
            ),
          );
        },
        childCount: _filteredCapsules.length,
      ),
    );
  }
}
