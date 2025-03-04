import 'package:dio/dio.dart';
import 'package:flutter_starter_clean/app/flavor.dart';
import 'package:flutter_starter_clean/core/constants/api_endpoints.dart';
import 'package:flutter_starter_clean/core/constants/enum.dart';
import 'package:flutter_starter_clean/core/errors/exceptions.dart';
import 'package:flutter_starter_clean/features/user/data/datasources/user_remote_data_source.dart';
import 'package:flutter_starter_clean/features/user/data/models/user_detail_model.dart';
import 'package:flutter_starter_clean/features/user/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late UserRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    FlavorService.initialize(Flavor.dev);
    mockDio = MockDio();
    dataSource = UserRemoteDataSourceImpl(dio: mockDio);
  });
  setUpAll(() {
    registerFallbackValue(tUpdateUserPasswordParams);
    registerFallbackValue(tUpdateFriendListParams);
    registerFallbackValue(tBookmarkPostParams);
    registerFallbackValue(tGetAllUsersWithExcludeParams);
  });

  group('getAllUsers', () {
    test(
      'should perform a GET request with correct parameters and return List<UserModel>',
      () async {
        // Arrange
        when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenAnswer(
          (_) async => Response(
            data: [tUserModel.toJson(), tUserModel.toJson()],
            statusCode: 200,
            requestOptions: RequestOptions(path: ApiEndpoints.users),
          ),
        );

        // Act
        final result = await dataSource.getAllUsers(tGetAllUsersWithExcludeParams);

        // Assert
        verify(
          () => mockDio.get(
            ApiEndpoints.users,
            queryParameters: {
              '_page': tGetAllUsersWithExcludeParams.page,
              '_limit': tGetAllUsersWithExcludeParams.limit,
              '_order': tGetAllUsersWithExcludeParams.order.getString(),
              'exclude': tGetAllUsersWithExcludeParams.excludeId,
            },
          ),
        );
        expect(result, isA<List<UserModel>>());
        expect(result, equals(tUserModels));
      },
    );

    test('should throw ServerException when response code is not 200', () async {
      // Arrange
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: ApiEndpoints.users),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.users),
        ),
      );

      // Act & Assert
      final call = dataSource.getAllUsers;
      expect(() => call(tGetAllUsersWithExcludeParams), throwsA(isA<ServerException>()));
    });
  });

  group('getUserById', () {
    test('should perform a GET request and return UserModel', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tUserModel.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: '${ApiEndpoints.users}/1'),
        ),
      );

      // Act
      final result = await dataSource.getUserById(tUserModel.id);

      // Assert
      verify(() => mockDio.get(ApiEndpoints.singleUser(tUserModel.id)));
      expect(result, isA<UserModel>());
      expect(result, equals(tUserModel));
    });

    test('should throw ServerException when response code is not 200', () async {
      // Arrange
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '${ApiEndpoints.users}/1'),
          ),
          requestOptions: RequestOptions(path: '${ApiEndpoints.users}/1'),
        ),
      );

      // Act & Assert
      final call = dataSource.getUserById;
      expect(() => call(tUserModel.id), throwsA(isA<ServerException>()));
    });
  });

  group('getUserDetail', () {
    test('should perform a GET request and return UserDetailModel', () async {
      // Arrange
      when(() => mockDio.get(any())).thenAnswer(
        (_) async => Response(
          data: tUserDetailModel.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.userDetail(tUserModel.id)),
        ),
      );

      // Act
      final result = await dataSource.getUserDetail(tUserModel.id);

      // Assert
      verify(() => mockDio.get(ApiEndpoints.userDetail(tUserModel.id)));
      expect(result, isA<UserDetailModel>());
      expect(result, equals(tUserDetailModel));
    });

    test('should throw ServerException when response code is not 200', () async {
      // Arrange
      when(() => mockDio.get(any())).thenThrow(
        DioException(
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: ApiEndpoints.userDetail(tUserModel.id)),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.userDetail(tUserModel.id)),
        ),
      );

      // Act & Assert
      final call = dataSource.getUserDetail;
      expect(() => call(tUserModel.id), throwsA(isA<ServerException>()));
    });
  });

  group('updateUser', () {
    test('should perform a PUT request and return UserModel', () async {
      // Arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tUserModel.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.singleUser(tUserModel.id)),
        ),
      );

      // Act
      final result = await dataSource.updateUser(tUserModel);

      // Assert
      verify(() => mockDio.put(ApiEndpoints.singleUser(tUserModel.id), data: tUserModel.toJson()));
      expect(result, isA<UserModel>());
      expect(result, equals(tUserModel));
    });

    test('should throw ServerException when response code is not 200', () async {
      // Arrange
      when(() => mockDio.put(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: ApiEndpoints.singleUser(tUserModel.id)),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.singleUser(tUserModel.id)),
        ),
      );

      // Act & Assert
      final call = dataSource.updateUser;
      expect(() => call(tUserModel), throwsA(isA<ServerException>()));
    });
  });

  group('updateFriendList', () {
    test('should perform a PATCH request with correct data', () async {
      // Arrange
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(
            path: ApiEndpoints.userFriendList(tUpdateFriendListParams.userId),
          ),
        ),
      );

      // Act
      await dataSource.updateFriendList(tUpdateFriendListParams);

      // Assert
      verify(
        () => mockDio.patch(
          ApiEndpoints.userFriendList(tUpdateFriendListParams.userId),
          data: {'friendIds': tUpdateFriendListParams.friendIds},
        ),
      );
    });

    test('should throw ServerException for non-200 status codes', () async {
      // Arrange
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(
              path: ApiEndpoints.userFriendList(tUpdateFriendListParams.userId),
            ),
          ),
          requestOptions: RequestOptions(
            path: ApiEndpoints.userFriendList(tUpdateFriendListParams.userId),
          ),
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.updateFriendList(tUpdateFriendListParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('updateUserPassword', () {
    test('should perform a PATCH request with correct data', () async {
      // Arrange
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(
            path: ApiEndpoints.singleUser(tUpdateUserPasswordParams.userId),
          ),
        ),
      );

      // Act
      await dataSource.updateUserPassword(tUpdateUserPasswordParams);

      // Assert
      verify(
        () => mockDio.patch(
          ApiEndpoints.singleUser(tUpdateUserPasswordParams.userId),
          data: {'password': tUpdateUserPasswordParams.newPassword},
        ),
      );
    });

    test('should throw ServerException for non-200 status codes', () async {
      // Arrange
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(
              path: ApiEndpoints.singleUser(tUpdateUserPasswordParams.userId),
            ),
          ),
          requestOptions: RequestOptions(
            path: ApiEndpoints.singleUser(tUpdateUserPasswordParams.userId),
          ),
        ),
      );

      expect(
        () => dataSource.updateUserPassword(tUpdateUserPasswordParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('bookmarkPost', () {
    test('should perform a PATCH request to bookmark a post', () async {
      // Arrange
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          requestOptions: RequestOptions(
            path: ApiEndpoints.bookmarkPost(userId: tBookmarkPostParams.userId),
          ),
        ),
      );
      // Act
      await dataSource.bookmarkPost(tBookmarkPostParams);
      // Assert
      verify(
        () => mockDio.patch(
          ApiEndpoints.bookmarkPost(userId: tBookmarkPostParams.userId),
          data: {'postId': tBookmarkPostParams.postId},
        ),
      );
    });

    test('should throw ServerException for non-200 status codes', () async {
      // Arrange
      when(() => mockDio.patch(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(
              path: ApiEndpoints.bookmarkPost(userId: tBookmarkPostParams.userId),
            ),
          ),
          requestOptions: RequestOptions(
            path: ApiEndpoints.bookmarkPost(userId: tBookmarkPostParams.userId),
          ),
        ),
      );
      // Act & Assert
      expect(() => dataSource.bookmarkPost(tBookmarkPostParams), throwsA(isA<ServerException>()));
    });
  });
}
