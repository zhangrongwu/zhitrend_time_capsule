import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // 环境类型
  static const Environment currentEnvironment = 
      kDebugMode ? Environment.development 
      : kProfileMode ? Environment.staging 
      : Environment.production;

  // GraphQL 服务器配置
  static late String graphqlUrl;
  
  // 身份验证相关配置
  static late String authTokenKey;
  
  // 应用版本
  static const String appVersion = '1.0.0';

  // 初始化配置
  static Future<void> init() async {
    // 根据不同环境加载不同的环境变量文件
    switch (currentEnvironment) {
      case Environment.development:
        await dotenv.load(fileName: '.env.development');
        break;
      case Environment.staging:
        await dotenv.load(fileName: '.env.staging');
        break;
      case Environment.production:
        await dotenv.load(fileName: '.env.production');
        break;
    }

    // 加载配置
    graphqlUrl = dotenv.env['GRAPHQL_URL'] ?? 'https://api.zhitrend.com/graphql';
    authTokenKey = dotenv.env['AUTH_TOKEN_KEY'] ?? 'zhitrend_time_capsule_token';
  }

  // 是否启用调试模式
  static bool get isDebugMode => kDebugMode;

  // 环境类型枚举
  static bool get isDevelopment => currentEnvironment == Environment.development;
  static bool get isStaging => currentEnvironment == Environment.staging;
  static bool get isProduction => currentEnvironment == Environment.production;
}

enum Environment {
  development,
  staging,
  production
}
