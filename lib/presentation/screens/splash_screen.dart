import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../domain/providers/user_provider.dart';
import '../../domain/providers/capsule_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _navigateToNextScreen();
        }
      });
  }

  Future<void> _initializeApp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final capsuleProvider = Provider.of<CapsuleProvider>(context, listen: false);

    // 尝试恢复会话
    await userProvider.restoreSession();

    // 如果用户已登录，获取胶囊列表
    if (userProvider.isAuthenticated) {
      await capsuleProvider.fetchCapsules();
    }
  }

  void _navigateToNextScreen() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // 根据用户登录状态决定跳转页面
    Navigator.of(context).pushReplacementNamed(
      userProvider.isAuthenticated ? '/home' : '/login'
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/time_capsule_splash.json',
              controller: _controller,
              onLoaded: (composition) {
                _controller.forward();
              },
            ),
            const SizedBox(height: 20),
            Text(
              'ZhiTrend Time Capsule',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 20),
            Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.isLoading) {
                  return const CircularProgressIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
