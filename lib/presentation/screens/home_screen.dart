import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> _capsules = [
    {
      'title': '我的大学梦想',
      'description': '写给未来的自己',
      'unlockDate': DateTime(2030, 1, 1),
      'color': Colors.purple[100],
    },
    {
      'title': '家庭时光',
      'description': '珍藏家庭回忆',
      'unlockDate': DateTime(2035, 6, 15),
      'color': Colors.blue[100],
    },
    // 更多胶囊...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的时间胶囊'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/create-capsule'),
          )
        ],
      ),
      body: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        padding: const EdgeInsets.all(10),
        itemCount: _capsules.length,
        itemBuilder: (context, index) {
          final capsule = _capsules[index];
          return Card(
            color: capsule['color'],
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capsule['title'],
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    capsule['description'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    '解锁日期: ${capsule['unlockDate'].toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
