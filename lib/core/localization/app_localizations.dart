import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'zh': {
      'app_title': 'ZhiTrend 时间胶囊',
      'login': '登录',
      'register': '注册',
      'create_capsule': '创建胶囊',
      'capsules_list': '胶囊列表',
      'no_capsules': '暂无时间胶囊',
      'create_first_capsule': '创建您的第一个时间胶囊',
      'delete_capsule': '删除胶囊',
      'edit_capsule': '编辑胶囊',
      'confirm_delete': '确认删除',
      'cancel': '取消',
    },
    'en': {
      'app_title': 'ZhiTrend Time Capsule',
      'login': 'Login',
      'register': 'Register',
      'create_capsule': 'Create Capsule',
      'capsules_list': 'Capsules List',
      'no_capsules': 'No time capsules yet',
      'create_first_capsule': 'Create your first time capsule',
      'delete_capsule': 'Delete Capsule',
      'edit_capsule': 'Edit Capsule',
      'confirm_delete': 'Confirm Delete',
      'cancel': 'Cancel',
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'zh'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
