import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GraphQLClientService {
  static final HttpLink httpLink = HttpLink('https://your-backend-url.workers.dev/graphql');

  static final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static Link get authLink => Link.function((request, [forward]) async {
    final token = await _secureStorage.read(key: 'auth_token');
    
    final modifiedRequest = Request(
      operation: request.operation,
      variables: request.variables,
      context: Context.fromList([
        ...request.context.toList(),
        if (token != null) 
          HeadersLink.headers({'Authorization': 'Bearer $token'})
      ]),
    );

    return forward!(modifiedRequest);
  });

  static GraphQLClient createClient() {
    return GraphQLClient(
      link: Link.from([authLink, httpLink]),
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  // 时间胶囊相关查询和变更
  static const String createTimeCapsuleMutation = r'''
    mutation CreateTimeCapsule($input: CreateTimeCapsuleInput!) {
      createTimeCapsule(input: $input) {
        id
        title
        description
        unlockTime
        isUnlocked
        creator {
          id
          username
        }
      }
    }
  ''';

  static const String getTimeCapsuleQuery = r'''
    query GetTimeCapsules {
      timeCapsules {
        id
        title
        description
        unlockTime
        isUnlocked
        creator {
          id
          username
        }
      }
    }
  ''';

  static const String getTimeCapsuleByIdQuery = r'''
    query GetTimeCapsule($id: String!) {
      timeCapsule(id: $id) {
        id
        title
        description
        unlockTime
        isUnlocked
        content
        creator {
          id
          username
        }
      }
    }
  ''';

  static const String updateTimeCapsuleMutation = r'''
    mutation UpdateTimeCapsule($id: String!, $input: CreateTimeCapsuleInput!) {
      updateTimeCapsule(id: $id, input: $input) {
        id
        title
        description
        unlockTime
        isUnlocked
        creator {
          id
          username
        }
      }
    }
  ''';

  static const String deleteTimeCapsuleMutation = r'''
    mutation DeleteTimeCapsule($id: String!) {
      deleteTimeCapsule(id: $id)
    }
  ''';

  // 创建时间胶囊
  static Future<Map<String, dynamic>?> createTimeCapsule({
    required String title, 
    String? description, 
    required DateTime unlockTime,
    String? content,
  }) async {
    try {
      final client = createClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(createTimeCapsuleMutation),
          variables: {
            'input': {
              'title': title,
              'description': description,
              'unlockTime': unlockTime.toIso8601String(),
              'content': content,
            }
          },
        ),
      );

      if (result.hasException) {
        debugPrint('创建时间胶囊错误: ${result.exception.toString()}');
        return null;
      }

      return result.data?['createTimeCapsule'];
    } catch (e) {
      debugPrint('创建时间胶囊异常: $e');
      return null;
    }
  }

  // 获取所有时间胶囊
  static Future<List<dynamic>> getTimeCapsules() async {
    try {
      final client = createClient();
      final result = await client.query(
        QueryOptions(
          document: gql(getTimeCapsuleQuery),
        ),
      );

      if (result.hasException) {
        debugPrint('获取时间胶囊错误: ${result.exception.toString()}');
        return [];
      }

      return result.data?['timeCapsules'] ?? [];
    } catch (e) {
      debugPrint('获取时间胶囊异常: $e');
      return [];
    }
  }

  // 获取单个时间胶囊详情
  static Future<Map<String, dynamic>?> getTimeCapsuleById(String id) async {
    try {
      final client = createClient();
      final result = await client.query(
        QueryOptions(
          document: gql(getTimeCapsuleByIdQuery),
          variables: {'id': id},
        ),
      );

      if (result.hasException) {
        debugPrint('获取时间胶囊详情错误: ${result.exception.toString()}');
        return null;
      }

      return result.data?['timeCapsule'];
    } catch (e) {
      debugPrint('获取时间胶囊详情异常: $e');
      return null;
    }
  }

  // 更新时间胶囊
  static Future<Map<String, dynamic>?> updateTimeCapsule({
    required String id,
    required String title, 
    String? description, 
    required DateTime unlockTime,
    String? content,
  }) async {
    try {
      final client = createClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(updateTimeCapsuleMutation),
          variables: {
            'id': id,
            'input': {
              'title': title,
              'description': description,
              'unlockTime': unlockTime.toIso8601String(),
              'content': content,
            }
          },
        ),
      );

      if (result.hasException) {
        debugPrint('更新时间胶囊错误: ${result.exception.toString()}');
        return null;
      }

      return result.data?['updateTimeCapsule'];
    } catch (e) {
      debugPrint('更新时间胶囊异常: $e');
      return null;
    }
  }

  // 删除时间胶囊
  static Future<bool> deleteTimeCapsule(String id) async {
    try {
      final client = createClient();
      final result = await client.mutate(
        MutationOptions(
          document: gql(deleteTimeCapsuleMutation),
          variables: {'id': id},
        ),
      );

      if (result.hasException) {
        debugPrint('删除时间胶囊错误: ${result.exception.toString()}');
        return false;
      }

      return result.data?['deleteTimeCapsule'] != null;
    } catch (e) {
      debugPrint('删除时间胶囊异常: $e');
      return false;
    }
  }
}
