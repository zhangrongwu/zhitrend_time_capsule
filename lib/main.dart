import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/routes/app_routes.dart';
import 'core/localization/app_localizations.dart';
import 'core/config/app_config.dart';
import 'core/utils/logger.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'domain/providers/user_provider.dart';
import 'domain/providers/capsule_provider.dart';
import 'domain/services/invitation_notification_service.dart';
import 'core/graphql/client.dart';
import 'presentation/navigation/main_navigation.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化环境配置
  await AppConfig.init();

  // 初始化日志
  AppLogger.init();

  // 记录应用启动日志
  AppLogger.info('ZhiTrend Time Capsule 应用启动');
  AppLogger.info('当前环境: ${AppConfig.currentEnvironment}');

  // 初始化通知服务
  final invitationNotificationService = InvitationNotificationService();
  await invitationNotificationService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(graphqlService: GraphQLClientService.createClient()),
        ),
        ChangeNotifierProvider(
          create: (context) => CapsuleProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: const ZhiTrendTimeCapsuleApp(),
    ),
  );
}

class ZhiTrendTimeCapsuleApp extends StatelessWidget {
  const ZhiTrendTimeCapsuleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'ZhiTrend Time Capsule',
      debugShowCheckedModeBanner: false,
      
      // 本地化配置
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // 根据系统语言选择最匹配的语言
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale?.languageCode) {
            return supportedLocale;
          }
        }
        // 默认返回英语
        return const Locale('en', 'US');
      },

      // 主题配置
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.currentThemeMode,

      // 使用全局导航键
      navigatorKey: MainNavigation.navigatorKey,
      
      // 使用自定义路由生成器
      onGenerateRoute: MainNavigation.generateRoute,
      
      // 默认首页
      initialRoute: MainNavigation.home,
    );
  }
}
