import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/providers/capsule_provider.dart';
import '../pages/home_page.dart';
import '../screens/capsule_create_screen.dart';
import '../pages/capsule_detail_page.dart';
import '../pages/capsule_invite_page.dart';
import '../pages/capsule_collaborators_page.dart';
import '../pages/capsule_invitations_page.dart';

class MainNavigation {
  static const String home = '/';
  static const String capsuleCreate = '/capsule/create';
  static const String capsuleDetail = '/capsule/detail';
  static const String capsuleInvite = '/capsule/invite';
  static const String capsuleCollaborators = '/capsule/collaborators';
  static const String capsuleInvitations = '/capsule/invitations';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      case capsuleCreate:
        return MaterialPageRoute(builder: (_) => const CapsuleCreateScreen());
      
      case capsuleDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CapsuleDetailPage(capsuleId: args['capsuleId'])
        );
      
      case capsuleInvite:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CapsuleInvitePage(capsuleId: args['capsuleId'])
        );
      
      case capsuleCollaborators:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CapsuleCollaboratorsPage(capsuleId: args['capsuleId'])
        );
      
      case capsuleInvitations:
        return MaterialPageRoute(builder: (_) => const CapsuleInvitationsPage());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // 全局导航键，用于在没有上下文的情况下进行导航
  static final GlobalKey<NavigatorState> navigatorKey = 
      GlobalKey<NavigatorState>();

  // 便捷的导航方法
  static void navigateTo(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamed(routeName, arguments: arguments);
  }

  static void navigateReplaceTo(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushReplacementNamed(routeName, arguments: arguments);
  }

  static void navigateAndRemoveUntil(String routeName, {Object? arguments}) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName, 
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop() {
    navigatorKey.currentState?.pop();
  }
}
