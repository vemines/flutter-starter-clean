import 'package:dio/dio.dart';
import 'package:flutter_starter_clean/app/flavor.dart';
import 'package:flutter_starter_clean/core/constants/api_endpoints.dart';
import 'package:flutter_starter_clean/core/errors/exceptions.dart';
import 'package:flutter_starter_clean/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockDio mockDio;

  setUp(() {
    FlavorService.initialize(Flavor.dev);
    mockDio = MockDio();
    dataSource = AuthRemoteDataSourceImpl(dio: mockDio);
  });

  setUpAll(() {
    registerFallbackValue(tAuthModel);
    registerFallbackValue(tUpdateUserPasswordParams);
  });

  group('login', () {
    test('should perform a POST request with correct data and return AuthModel', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tAuthModel.toJson(),
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiEndpoints.login),
        ),
      );

      // Act
      final result = await dataSource.login(tLoginParams);

      // Assert
      verify(
        () => mockDio.post(
          ApiEndpoints.login,
          data: {'username': tLoginParams.username, 'password': tLoginParams.password},
        ),
      );
      expect(result, equals(tAuthModel));
    });

    test('should throw InvalidCredentialsException for invalid credentials (401)', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: ApiEndpoints.login),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.login),
        ),
      );

      // Act & Assert
      expect(() => dataSource.login(tLoginParams), throwsA(isA<InvalidCredentialsException>()));
    });
  });

  group('register', () {
    test('should perform a POST and return AuthModel', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: tAuthModel.toJson(),
          statusCode: 201,
          requestOptions: RequestOptions(path: ApiEndpoints.register),
        ),
      );

      // Act
      final result = await dataSource.register(tRegisterParams);

      // Assert
      verify(
        () => mockDio.post(
          ApiEndpoints.register,
          data: {
            'username': tRegisterParams.userName,
            'email': tRegisterParams.email,
            'password': tRegisterParams.password,
          },
        ),
      );
      expect(result, equals(tAuthModel));
    });
  });
  group('verifySecret', () {
    test('should perform a POST request and return true if successful', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async =>
            Response(statusCode: 200, requestOptions: RequestOptions(path: ApiEndpoints.verify)),
      );

      // Act
      final result = await dataSource.verifySecret(tSecret);

      // Assert
      verify(() => mockDio.post(ApiEndpoints.verify, data: {'secret': tSecret}));
      expect(result, isTrue);
    });

    test('should return false for unauthenticated user (403)', () async {
      // Arrange
      when(() => mockDio.post(any(), data: any(named: 'data'))).thenThrow(
        DioException(
          response: Response(
            statusCode: 403,
            requestOptions: RequestOptions(path: ApiEndpoints.verify),
          ),
          requestOptions: RequestOptions(path: ApiEndpoints.verify),
        ),
      );

      // Act
      final result = await dataSource.verifySecret(tSecret);

      // Assert
      expect(result, isFalse);
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

    test('should throw ServerException for non-2xx status codes', () async {
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

      // Act & Assert
      expect(
        () => dataSource.updateUserPassword(tUpdateUserPasswordParams),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
