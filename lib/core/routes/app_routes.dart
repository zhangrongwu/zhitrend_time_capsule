import 'package:flutter/material.dart';

import '../../domain/providers/capsule_provider.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/register_screen.dart';
import '../../presentation/screens/capsules_list_screen.dart';
import '../../presentation/screens/create_capsule_screen.dart';
import '../../presentation/screens/capsule_detail_screen.dart';
import '../../presentation/screens/theme_selection_screen.dart';

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case LoginScreen.routeName:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case RegisterScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case CapsulesListScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CapsulesListScreen());
      
      case CreateCapsuleScreen.routeName:
        return MaterialPageRoute(builder: (_) => const CreateCapsuleScreen());
      
      case CapsuleDetailScreen.routeName:
        final capsule = settings.arguments as TimeCapsule;
        return MaterialPageRoute(
          builder: (_) => CapsuleDetailScreen(capsule: capsule),
        );
      
      case ThemeSelectionScreen.routeName:
        return MaterialPageRoute(builder: (_) => const ThemeSelectionScreen());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('没有找到路由：${settings.name}'),
            ),
          ),
        );
    }
  }
}
