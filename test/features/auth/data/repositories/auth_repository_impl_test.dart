import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_starter_clean/core/errors/failures.dart';

import '../../../../mocks.dart';

void main() {
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockUserRemoteDataSource mockUserRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockFirebaseAuth mockFirebaseAuth;
  late AuthRepositoryImpl repository;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockUserRemoteDataSource = MockUserRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    mockFirebaseAuth = MockFirebaseAuth();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
      firebaseAuth: mockFirebaseAuth,
      userRemoteDataSource: mockUserRemoteDataSource,
    );
    registerFallbackValue(tLoginParams);
    registerFallbackValue(tRegisterParams);
    registerFallbackValue(tUserModel);
    registerFallbackValue(tUpdateUserPasswordParams);
  });

  group('login', () {
    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.login(any())).thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.cacheAuth(any())).thenAnswer((_) async => {});

      // Act
      await repository.login(tLoginParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('when device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should cache and return remote data on successful login', () async {
        // Arrange
        when(() => mockRemoteDataSource.login(any())).thenAnswer((_) async => tUserModel);
        when(() => mockLocalDataSource.cacheAuth(any())).thenAnswer((_) async => {});

        // Act
        final result = await repository.login(tLoginParams);

        // Assert
        verify(() => mockLocalDataSource.cacheAuth(tUserModel));
        expect(result, equals(Right(tUserModel)));
      });

      test('should return ServerFailure on unsuccessful login', () async {
        // Arrange
        when(() => mockRemoteDataSource.login(any())).thenThrow(tServerException);

        // Act
        final result = await repository.login(tLoginParams);

        // Assert
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, Left(tServerFailure));
      });
    });

    group('when device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NoInternetFailure when device is offline', () async {
        // Act
        final result = await repository.login(tLoginParams);

        // Assert
        expect(result, equals(Left(tNoInternetFailure)));
      });
    });
  });

  group('register', () {
    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.register(any())).thenAnswer((_) async => tUserModel);
      when(() => mockLocalDataSource.cacheAuth(any())).thenAnswer((_) async => {});

      // Act
      await repository.register(tRegisterParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('when device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should cache and return remote data on successful register', () async {
        // Arrange
        when(() => mockRemoteDataSource.register(any())).thenAnswer((_) async => tUserModel);
        when(() => mockLocalDataSource.cacheAuth(any())).thenAnswer((_) async => {});

        // Act
        final result = await repository.register(tRegisterParams);

        // Assert
        verify(() => mockLocalDataSource.cacheAuth(tUserModel));
        expect(result, equals(Right(tUserModel)));
      });

      test('should return ServerFailure on unsuccessful register', () async {
        // Arrange
        when(() => mockRemoteDataSource.register(any())).thenThrow(tServerException);

        // Act
        final result = await repository.register(tRegisterParams);

        // Assert
        verifyZeroInteractions(mockLocalDataSource);
        expect(result, equals(Left(tServerFailure)));
      });
    });

    group('when device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NoInternetFailure when device is offline', () async {
        // Act
        final result = await repository.register(tRegisterParams);

        // Assert
        expect(result, equals(Left(tNoInternetFailure)));
      });
    });
  });

  group('getLoggedInUser', () {
    test('should return last locally cached data when present', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getCachedAuth()).thenAnswer((_) async => tUserModel);

      // Act
      final result = await repository.getLoggedInUser();

      // Assert
      expect(result, equals(Right(tUserModel)));
    });

    test(
      'should return UnauthenticatedFailure when no cache data and no user in firebase auth',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockLocalDataSource.getCachedAuth()).thenAnswer((_) async => null);
        when(() => mockFirebaseAuth.currentUser).thenAnswer((_) => null);

        // Act
        final result = await repository.getLoggedInUser();

        // Assert
        expect(result, equals(Left(UnauthenticatedFailure())));
      },
    );
  });

  group('logout', () {
    test('should clear the cache and return Right(unit)', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockLocalDataSource.logout()).thenAnswer((_) async => {});
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async => {});

      // Act
      final result = await repository.logout();

      // Assert
      verify(() => mockLocalDataSource.logout());
      verify(() => mockRemoteDataSource.logout());
      expect(result, equals(const Right(unit)));
    });
  });

  group('updateUserPassword', () {
    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateUserPassword(any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.logout()).thenAnswer((_) async => {});
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async => {});

      // Act
      await repository.updateUserPassword(tUpdateUserPasswordParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
      verify(() => mockRemoteDataSource.updateUserPassword(tUpdateUserPasswordParams));
      verify(() => mockLocalDataSource.logout());
    });

    test('should clear cached auth and return Right(unit) on success', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateUserPassword(any())).thenAnswer((_) async => {});
      when(() => mockLocalDataSource.logout()).thenAnswer((_) async => {});
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async => {});
      // Act
      final result = await repository.updateUserPassword(tUpdateUserPasswordParams);

      // Assert
      expect(result, const Right(unit));
    });

    test('should return ServerFailure on unsuccessful remote call', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateUserPassword(any())).thenThrow(tServerException);

      // Act
      final result = await repository.updateUserPassword(tUpdateUserPasswordParams);

      // Assert
      expect(result, Left(tServerFailure));
    });

    test('should return NoInternetFailure when the device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.updateUserPassword(tUpdateUserPasswordParams);

      // Assert
      expect(result, equals(Left(tNoInternetFailure)));
    });
  });
}
