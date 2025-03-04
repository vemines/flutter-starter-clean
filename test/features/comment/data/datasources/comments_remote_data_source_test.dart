import 'package:dio/dio.dart';
import 'package:flutter_starter_clean/app/flavor.dart';
import 'package:flutter_starter_clean/core/constants/api_endpoints.dart';
import 'package:flutter_starter_clean/core/constants/enum.dart';
import 'package:flutter_starter_clean/core/errors/exceptions.dart';
import 'package:flutter_starter_clean/features/comment/data/datasources/comment_remote_data_source.dart';
import 'package:flutter_starter_clean/features/comment/data/models/comment_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late CommentRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    FlavorService.initialize(Flavor.dev);
    mockDio = MockDio();
    dataSource = CommentRemoteDataSourceImpl(dio: mockDio);
  });

  setUpAll(() {
    registerFallbackValue(tCommentModel);
    registerFallbackValue(tGetCommentsParams);
  });

  group('getCommentsByPostId', () {
    test('should perform a GET request and return List<CommentModel>', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
        (_) async => Response(
          data: [tCommentModel.toJson(), tCommentModel.toJson()],
          statusCode: 200,
          requestOptions: RequestOptions(
            path: ApiEndpoints.getCommentsByPostId(postId: tPostModel.id),
          ),
        ),
      );

      // Act
      final result = await dataSource.getCommentsByPostId(tGetCommentsParams);

      // Assert
      verify(
        () => mockDio.get(
          ApiEndpoints.getCommentsByPostId(postId: tPostModel.id),
          queryParameters: {
            '_page': tGetCommentsParams.page,
            '_limit': tGetCommentsParams.limit,
            '_sort': 'updatedAt',
            '_order': tGetCommentsParams.order.getString(),
          },
        ),
      );
      expect(result, isA<List<CommentModel>>());
      expect(result, equals(tCommentModels));
    });

    test('should throw a ServerException when receive DioException', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(
              path: ApiEndpoints.getCommentsByPostId(postId: tPostModel.id),
            ),
          ),
          requestOptions: RequestOptions(
            path: ApiEndpoints.getCommentsByPostId(postId: tPostModel.id),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.getCommentsByPostId(tGetCommentsParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('addComment', () {
    test('should perform a POST request with the correct data and return CommentModel', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tCommentModel.toJson(),
          statusCode: 201,
          requestOptions: RequestOptions(
            path: ApiEndpoints.getCommentsByPostId(postId: tAddCommentParams.postId),
          ),
        ),
      );

      // Act
      final result = await dataSource.addComment(tAddCommentParams);

      // Assert
      verify(
        () => mockDio.post(
          ApiEndpoints.getCommentsByPostId(postId: tAddCommentParams.postId),
          data: {'userId': tAddCommentParams.userId, 'body': tAddCommentParams.body},
        ),
      );
      expect(result, equals(tCommentModel));
    });

    test('should throw a ServerException when receive DioException', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(
              path: ApiEndpoints.getCommentsByPostId(postId: tAddCommentParams.postId),
            ),
          ),
          requestOptions: RequestOptions(
            path: ApiEndpoints.getCommentsByPostId(postId: tAddCommentParams.postId),
          ),
        ),
      );

      // Act & Assert
      expect(() => dataSource.addComment(tAddCommentParams), throwsA(isA<ServerException>()));
    });
  });

  group('updateComment', () {
    test('should perform a PATCH request with correct data and return CommentModel', () async {
      // Arrange
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tCommentModel.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.singleComment(tCommentModel.id)),
        ),
      );

      // Act
      final result = await dataSource.updateComment(tCommentModel);

      // Assert
      verify(
        () => mockDio.patch(
          ApiEndpoints.singleComment(tCommentModel.id),
          data: {'userId': tCommentModel.user.id, 'body': tCommentModel.body},
        ),
      );
      expect(result, equals(tCommentModel));
    });

    test('should throw a ServerException when receive DioException', () async {
      // Arrange
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(
              path: ApiEndpoints.singleComment(tUpdatedCommentModel.id),
            ),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.singleComment(tUpdatedCommentModel.id)),
        ),
      );

      // Act & Assert
      expect(() => dataSource.updateComment(tUpdatedCommentModel), throwsA(isA<ServerException>()));
    });
  });

  group('deleteComment', () {
    test('should perform a DELETE request with the comment ID and userId', () async {
      // Arrange
      when(() => mockDio.delete(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.singleComment(tCommentModel.id)),
        ),
      );

      // Act
      await dataSource.deleteComment(tCommentModel);

      // Assert
      verify(
        () => mockDio.delete(
          ApiEndpoints.singleComment(tCommentModel.id),
          data: {'userId': tCommentModel.user.id},
        ),
      );
    });

    test('should throw a ServerException when receive DioException', () async {
      // Arrange
      when(() => mockDio.delete(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ApiEndpoints.singleComment(tCommentModel.id)),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.singleComment(tCommentModel.id)),
        ),
      );

      // Act & Assert
      expect(() => dataSource.deleteComment(tCommentModel), throwsA(isA<ServerException>()));
    });
  });
}
