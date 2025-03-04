import 'package:dio/dio.dart';
import 'package:flutter_starter_clean/app/flavor.dart';
import 'package:flutter_starter_clean/core/constants/api_endpoints.dart';
import 'package:flutter_starter_clean/core/constants/api_mapping.dart';
import 'package:flutter_starter_clean/core/constants/enum.dart';
import 'package:flutter_starter_clean/core/errors/exceptions.dart';
import 'package:flutter_starter_clean/features/post/data/datasources/post_remote_data_source.dart';
import 'package:flutter_starter_clean/features/post/data/models/post_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late PostRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    FlavorService.initialize(Flavor.dev);
    mockDio = MockDio();
    dataSource = PostRemoteDataSourceImpl(dio: mockDio);
  });

  setUpAll(() {
    registerFallbackValue(tPostModel);
    registerFallbackValue(tGetPostsByUserIdParams);
  });

  final jsonListPost = [tPostModel.toJson(), tPostModel.toJson()];

  group('getAllPosts', () {
    test('should perform a GET request with pagination parameters', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          data: [tPostModel.toJson()],
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act
      await dataSource.getAllPosts(tPaginationParams);

      // Assert
      verify(
        () => mockDio.get(
          ApiEndpoints.posts,
          queryParameters: {
            '_page': tPaginationParams.page,
            '_limit': tPaginationParams.limit,
            '_sort': 'updatedAt',
            '_order': tPaginationParams.order.getString(),
          },
        ),
      );
    });

    test('should return List<PostModel> when the response code is 200', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          data: jsonListPost,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act
      final result = await dataSource.getAllPosts(tPaginationParams);

      // Assert
      expect(result, isA<List<PostModel>>());
      expect(result, equals(tPostModels));
    });

    test('should throw a ServerException when receive DioException', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ApiEndpoints.posts),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act & Assert
      expect(() => dataSource.getAllPosts(tPaginationParams), throwsA(isA<ServerException>()));
    });
  });

  group('getPostsByUserId', () {
    test('should perform a GET request with user ID and pagination parameters', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          data: [tPostModel.toJson()],
          statusCode: 200,
          requestOptions: RequestOptions(
            path: ApiEndpoints.userPosts(userId: tGetPostsByUserIdParams.userId),
          ),
        ),
      );

      // Act
      await dataSource.getPostsByUserId(tGetPostsByUserIdParams);

      // Assert
      verify(
        () => mockDio.get(
          ApiEndpoints.userPosts(userId: tGetPostsByUserIdParams.userId),
          queryParameters: {
            '_page': tGetPostsByUserIdParams.page,
            '_limit': tGetPostsByUserIdParams.limit,
            '_sort': 'updatedAt',
            '_order': tGetPostsByUserIdParams.order.getString(),
          },
        ),
      );
    });

    test('should return List<PostModel> when the response code is 200', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          data: jsonListPost,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.userPosts(userId: 'user1')),
        ),
      );

      // Act
      final result = await dataSource.getPostsByUserId(tGetPostsByUserIdParams);

      // Assert
      expect(result, isA<List<PostModel>>());
      expect(result, equals(tPostModels));
    });

    test('should throw a ServerException when receive DioException', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ApiEndpoints.userPosts(userId: 'user1')),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.userPosts(userId: 'user1')),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getPostsByUserId(tGetPostsByUserIdParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getPostById', () {
    test('should perform a GET request on a URL with the post ID', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tPostModel.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
        ),
      );

      // Act
      await dataSource.getPostById(tPostIdParams.id);

      // Assert
      verify(() => mockDio.get(ApiEndpoints.singlePost(tPostModel.id)));
    });

    test('should return PostModel when the response code is 200', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tPostModel.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
        ),
      );

      // Act
      final result = await dataSource.getPostById(tPostModel.id);

      // Assert
      expect(result, isA<PostModel>());
      expect(result, equals(tPostModel));
    });

    test('should throw a ServerException when receive DioException', () async {
      // Arrange
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
        ),
      );

      // Act & Assert
      expect(() => dataSource.getPostById(tPostModel.id), throwsA(isA<ServerException>()));
    });
  });

  group('createPost', () {
    test('should perform a POST request with the post data', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tPostModel.toJson(),
          statusCode: 201,
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act
      await dataSource.createPost(tCreatePostParams);

      // Assert
      verify(
        () => mockDio.post(
          ApiEndpoints.posts,
          data: {
            PostApiMap.kUserId: tCreatePostParams.userId,
            PostApiMap.kTitle: tCreatePostParams.title,
            PostApiMap.kBody: tCreatePostParams.body,
          },
        ),
      );
    });

    test('should return PostModel when the response code is 201 or 200', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tPostModel.toJson(),
          statusCode: 201,
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act
      final result = await dataSource.createPost(tCreatePostParams);

      // Assert
      expect(result, isA<PostModel>());
      expect(result, equals(tPostModel));
    });

    test('should throw a ServerException when the response code is not 2xx', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ApiEndpoints.posts),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act & Assert
      expect(() => dataSource.createPost(tCreatePostParams), throwsA(isA<ServerException>()));
    });
  });

  group('updatePost', () {
    test('should perform a PUT request with the post data', () async {
      // Arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tPostModel.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
        ),
      );

      // Act
      await dataSource.updatePost(tPostModel);

      // Assert
      verify(() => mockDio.put(ApiEndpoints.singlePost(tPostModel.id), data: tPostModel.toJson()));
    });

    test('should return PostModel when the response code is 200', () async {
      // Arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tPostModel.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
        ),
      );

      // Act
      final result = await dataSource.updatePost(tPostModel);

      // Assert
      expect(result, isA<PostModel>());
      expect(result, equals(tPostModel));
    });

    test('should throw a ServerException when receive DioException', () async {
      // Arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
        ),
      );

      // Act & Assert
      expect(() => dataSource.updatePost(tPostModel), throwsA(isA<ServerException>()));
    });
  });

  group('deletePost', () {
    test('should perform a DELETE request with the post ID', () async {
      // Arrange
      when(() => mockDio.delete(any())).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
        ),
      );

      // Act
      await dataSource.deletePost(tPostModel.id);

      // Assert
      verify(() => mockDio.delete(ApiEndpoints.singlePost(tPostModel.id)));
    });

    test('should throw a ServerException when receive DioException', () async {
      // Arrange
      when(() => mockDio.delete(any())).thenThrow(
        DioException(
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id)),
        ),
      );

      // Act & Assert
      expect(() => dataSource.deletePost(tPostModel.id), throwsA(isA<ServerException>()));
    });

    test('should throw a ServerException when dio error', () async {
      // Arrange
      when(() => mockDio.delete(any())).thenThrow(
        DioException(requestOptions: RequestOptions(path: ApiEndpoints.singlePost(tPostModel.id))),
      );

      // Act & Assert
      expect(() => dataSource.deletePost(tPostModel.id), throwsA(isA<ServerException>()));
    });
  });

  group('searchPosts', () {
    test('should perform a GET request with search query and pagination', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          data: [tPostModel.toJson()],
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act
      await dataSource.searchPosts(tPaginationWithSearchParams);

      // Assert
      verify(
        () => mockDio.get(
          ApiEndpoints.posts,
          queryParameters: {
            'q': tPaginationWithSearchParams.search,
            '_page': tPaginationWithSearchParams.page,
            '_limit': tPaginationWithSearchParams.limit,
            '_sort': 'updatedAt',
            '_order': tPaginationWithSearchParams.order.getString(),
          },
        ),
      );
    });

    test('should return List<PostModel> when response code is 200', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          data: jsonListPost,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act
      final result = await dataSource.searchPosts(tPaginationWithSearchParams);

      // Assert
      expect(result, isA<List<PostModel>>());
      expect(result, equals(tPostModels));
    });

    test('should throw ServerException when response code is not 200', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ApiEndpoints.posts),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.searchPosts(tPaginationWithSearchParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getPostsByIds', () {
    test('should perform a GET request with a list of post IDs', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          data: jsonListPost,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act
      await dataSource.getPostsByIds(tListBookmarkPostIdParams);

      // Assert
      verify(
        () =>
            mockDio.get(ApiEndpoints.posts, queryParameters: {'id': tListBookmarkPostIdParams.ids}),
      );
    });

    test('should return List<PostModel> when response code is 200', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          data: jsonListPost,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act
      final result = await dataSource.getPostsByIds(tListBookmarkPostIdParams);

      // Assert
      expect(result, isA<List<PostModel>>());
      expect(result, equals(tPostModels));
    });

    test('should throw ServerException when response code is not 200', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ApiEndpoints.posts),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.posts),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getPostsByIds(tListBookmarkPostIdParams),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
