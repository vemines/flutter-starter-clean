import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/user/data/repositories/user_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late UserRepositoryImpl repository;
  late MockUserRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockUserRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = UserRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });
  setUpAll(() {
    registerFallbackValue(tBookmarkPostParams);
    registerFallbackValue(tPostIdParams);
    registerFallbackValue(tListBookmarkPostIdParams);
    registerFallbackValue(tGetAllUsersWithExcludeParams);
    registerFallbackValue(tUserModel);
    registerFallbackValue(tUpdateFriendListParams);
  });

  group('getAllUsers', () {
    test('should check if the device is online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getAllUsers(any())).thenAnswer((_) async => tUserModels);

      await repository.getAllUsers(tGetAllUsersWithExcludeParams);

      verify(() => mockNetworkInfo.isConnected);
    });
    test('should return remote data and when call to remote source is successful', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getAllUsers(any())).thenAnswer((_) async => tUserModels);

      // Act
      final result = await repository.getAllUsers(tGetAllUsersWithExcludeParams);

      // Assert
      verify(() => mockRemoteDataSource.getAllUsers(tGetAllUsersWithExcludeParams));
      expect(result, equals(Right(tUserModels)));
    });

    test('should return server failure when call to remote source is unsuccessful', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getAllUsers(any())).thenThrow(tServerException);

      // Act
      final result = await repository.getAllUsers(tGetAllUsersWithExcludeParams);

      // Assert
      expect(result, equals(Left(tServerFailure)));
    });

    test('should return NoInternetFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.getAllUsers(tGetAllUsersWithExcludeParams);

      // Assert
      expect(result, equals(Left(tNoInternetFailure)));
    });
  });

  group('getUserById', () {
    test(
      'should return remote data and cache it when call to remote source is successful',
      () async {
        // Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDataSource.getUserById(any())).thenAnswer((_) async => tUserModel);

        // Act
        final result = await repository.getUserById(tUserIdParams);

        // Assert
        verify(() => mockRemoteDataSource.getUserById(tUserIdParams.id));
        expect(result, equals(Right(tUserModel)));
      },
    );

    test('should return server failure when call to remote source is unsuccessful', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getUserById(any())).thenThrow(tServerException);

      // Act
      final result = await repository.getUserById(tUserIdParams);

      // Assert
      expect(result, Left(tServerFailure));
    });

    test('should return NoInternetFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.getUserById(tUserIdParams);

      // Assert
      expect(result, equals(Left(tNoInternetFailure)));
    });
  });

  group('getUserDetail', () {
    test('should return remote data when the call to remote source is successful', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.getUserDetail(any()),
      ).thenAnswer((_) async => tUserDetailModel);

      // Act
      final result = await repository.getUserDetail(tUserIdParams);

      // Assert
      verify(() => mockRemoteDataSource.getUserDetail(tUserIdParams.id));
      expect(result, equals(Right(tUserDetailModel)));
    });

    test('should return server failure when the call to remote source is unsuccessful', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getUserDetail(any())).thenThrow(tServerException);

      // Act
      final result = await repository.getUserDetail(tUserIdParams);

      // Assert
      expect(result, Left(tServerFailure));
    });

    test('should return NoInternetFailure when the device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.getUserDetail(tUserIdParams);

      // Assert
      expect(result, equals(Left(tNoInternetFailure)));
    });
  });

  group('updateUser', () {
    test('should return updated user data and cache it on successful remote call', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateUser(any())).thenAnswer((_) async => tUpdateUserModel);

      // Act
      final result = await repository.updateUser(tUpdateUserEntity);

      // Assert
      verify(() => mockRemoteDataSource.updateUser(tUpdateUserModel));
      expect(result, equals(Right(tUpdateUserModel)));
    });

    test('should return server failure on unsuccessful remote call', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateUser(any())).thenThrow(tServerException);

      // Act
      final result = await repository.updateUser(tUserEntity);

      // Assert
      expect(result, equals(Left(tServerFailure)));
    });

    test('should return NoInternetFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.updateUser(tUserEntity);

      // Assert
      expect(result, Left(tNoInternetFailure));
    });
  });

  group('updateFriendList', () {
    test('should complete successfully on successful remote call', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateFriendList(any())).thenAnswer((_) async => unit);

      // Act
      final result = await repository.updateFriendList(tUpdateFriendListParams);

      // Assert
      verify(() => mockRemoteDataSource.updateFriendList(tUpdateFriendListParams));
      expect(result, equals(const Right(unit)));
    });

    test('should return server failure on unsuccessful remote call', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateFriendList(any())).thenThrow(tServerException);

      // Act
      final result = await repository.updateFriendList(tUpdateFriendListParams);

      // Assert
      expect(result, equals(Left(tServerFailure)));
    });

    test('should return NoInternetFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.updateFriendList(tUpdateFriendListParams);

      // Assert
      expect(result, Left(tNoInternetFailure));
    });
  });

  group('bookmarkPost', () {
    setUp(() {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('should check if the device is online', () async {
      // Arrange
      when(() => mockRemoteDataSource.bookmarkPost(any())).thenAnswer((_) async => unit);

      // Act
      await repository.bookmarkPost(tBookmarkPostParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    test('should call remote and local data sources when online', () async {
      // Arrange
      when(() => mockRemoteDataSource.bookmarkPost(any())).thenAnswer((_) async => unit);

      // Act
      final result = await repository.bookmarkPost(tBookmarkPostParams);

      // Assert
      verify(() => mockRemoteDataSource.bookmarkPost(tBookmarkPostParams));
      expect(result, const Right(unit));
    });

    test('should return server failure on remote failure when online', () async {
      // Arrange
      when(() => mockRemoteDataSource.bookmarkPost(any())).thenThrow(tServerException);

      // Act
      final result = await repository.bookmarkPost(tBookmarkPostParams);

      // Assert
      verify(() => mockRemoteDataSource.bookmarkPost(tBookmarkPostParams));
      expect(result, Left(tServerFailure));
    });

    test('should return NoInternetFailure on local failure when offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.bookmarkPost(tBookmarkPostParams);

      // Assert
      verifyZeroInteractions(mockRemoteDataSource);
      expect(result, Left(tNoInternetFailure));
    });
  });
}
