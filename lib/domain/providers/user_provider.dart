import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../core/graphql/client.dart';

class User {
  final String id;
  final String username;
  final String email;

  User({
    required this.id,
    required this.username,
    required this.email,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    username: json['username'],
    email: json['email'],
  );
}

class UserProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  final _storage = const FlutterSecureStorage();
  final GraphQLClient graphqlService;

  UserProvider({required this.graphqlService});

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  String? get error => _error;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await graphqlService.login(email, password);
      
      if (token != null) {
        // 获取用户详细信息的查询
        const userQuery = r'''
          query GetUser($email: String!) {
            userByEmail(email: $email) {
              id
              username
              email
            }
          }
        ''';

        final result = await graphqlService.performQuery(
          userQuery, 
          variables: {'email': email}
        );

        if (result.hasException) {
          throw Exception(result.exception?.graphqlErrors.first.message);
        }

        final userData = result.data?['userByEmail'];
        if (userData != null) {
          _currentUser = User.fromJson(userData);
        }
      }
    } catch (e) {
      _error = '登录失败：${e.toString()}';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await graphqlService.register(
        username: username,
        email: email,
        password: password,
      );

      if (userData != null) {
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      _error = '注册失败：${e.toString()}';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await graphqlService.logout();
      _currentUser = null;
    } catch (e) {
      _error = '退出登录失败：${e.toString()}';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'auth_token');
      
      if (token != null) {
        // TODO: 实现通过 token 获取用户信息的查询
        const userQuery = r'''
          query GetCurrentUser {
            currentUser {
              id
              username
              email
            }
          }
        ''';

        final result = await graphqlService.performQuery(userQuery);

        if (result.hasException) {
          throw Exception(result.exception?.graphqlErrors.first.message);
        }

        final userData = result.data?['currentUser'];
        if (userData != null) {
          _currentUser = User.fromJson(userData);
        }
      }
    } catch (e) {
      _error = '恢复会话失败：${e.toString()}';
      if (kDebugMode) {
        print(_error);
      }
      await graphqlService.logout(); // 清除无效 token
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
