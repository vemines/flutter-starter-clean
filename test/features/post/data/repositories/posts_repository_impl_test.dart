import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/post/data/repositories/post_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late PostRepositoryImpl repository;
  late MockPostRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockPostRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = PostRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  setUpAll(() {
    registerFallbackValue(tPostModel);
    registerFallbackValue(tPaginationParams);
    registerFallbackValue(tPaginationWithSearchParams);
    registerFallbackValue(tListBookmarkPostIdParams);
    registerFallbackValue(tGetPostsByUserIdParams);
    registerFallbackValue(tPostIdParams);
    registerFallbackValue(tCreatePostParams);
  });

  group('getAllPosts', () {
    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getAllPosts(any())).thenAnswer((_) async => tPostModels);

      // Act
      await repository.getAllPosts(tPaginationParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('when device online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return remote data and cache it on successful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.getAllPosts(any())).thenAnswer((_) async => tPostModels);

        // Act
        final result = await repository.getAllPosts(tPaginationParams);

        // Assert
        verify(() => mockRemoteDataSource.getAllPosts(tPaginationParams));
        expect(result, equals(Right(tPostModels)));
      });

      test('should return server failure on unsuccessful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.getAllPosts(any())).thenThrow(tServerException);

        // Act
        final result = await repository.getAllPosts(tPaginationParams);

        // Assert
        verify(() => mockRemoteDataSource.getAllPosts(tPaginationParams));
        expect(result, equals(Left(tServerFailure)));
      });
    });

    group('when device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NoInternetFailure when device is offline', () async {
        // Act
        final result = await repository.getAllPosts(tPaginationParams);

        // Assert
        verify(() => mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, Left(tNoInternetFailure));
      });
    });
  });

  group('getPostsByUserId', () {
    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getPostsByUserId(any())).thenAnswer((_) async => tPostModels);
      // Act
      await repository.getPostsByUserId(tGetPostsByUserIdParams);
      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('when device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return remote data on successful call', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.getPostsByUserId(any()),
        ).thenAnswer((_) async => tPostModels);

        // Act
        final result = await repository.getPostsByUserId(tGetPostsByUserIdParams);

        // Assert
        verify(() => mockRemoteDataSource.getPostsByUserId(tGetPostsByUserIdParams));
        expect(result, equals(Right(tPostModels)));
      });

      test('should return server failure on unsuccessful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.getPostsByUserId(any())).thenThrow(tServerException);

        // Act
        final result = await repository.getPostsByUserId(tGetPostsByUserIdParams);

        // Assert
        verify(() => mockRemoteDataSource.getPostsByUserId(tGetPostsByUserIdParams));
        expect(result, equals(Left(tServerFailure)));
      });
    });
    group('when device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      test('should return NoInternetFailure when device is offline', () async {
        // Act
        final result = await repository.getPostsByUserId(tGetPostsByUserIdParams);

        // Assert
        verify(() => mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, Left(tNoInternetFailure));
      });
    });
  });

  group('getPostById', () {
    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getPostById(any())).thenAnswer((_) async => tPostModel);

      // Act
      await repository.getPostById(tPostIdParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('when device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return remote data on successful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.getPostById(any())).thenAnswer((_) async => tPostModel);

        // Act
        final result = await repository.getPostById(tPostIdParams);

        // Assert
        verify(() => mockRemoteDataSource.getPostById(tPostIdParams.id));
        expect(result, equals(Right(tPostModel)));
      });

      test('should return server failure on unsuccessful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.getPostById(any())).thenThrow(tServerException);

        // Act
        final result = await repository.getPostById(tPostIdParams);

        // Assert
        verify(() => mockRemoteDataSource.getPostById(tPostIdParams.id));
        expect(result, Left(tServerFailure));
      });
    });
  });

  group('createPost', () {
    setUp(() {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('should check if the device is online', () async {
      // Arrange
      when(() => mockRemoteDataSource.createPost(any())).thenAnswer((_) async => tPostModel);

      // Act
      await repository.createPost(tCreatePostParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    test('should return newly created post on successful call', () async {
      // Arrange
      when(() => mockRemoteDataSource.createPost(any())).thenAnswer((_) async => tPostModel);

      // Act
      final result = await repository.createPost(tCreatePostParams);

      // Assert
      verify(() => mockRemoteDataSource.createPost(tCreatePostParams));
      expect(result, equals(Right(tPostModel)));
    });

    test('should return server failure on unsuccessful call', () async {
      // Arrange
      when(() => mockRemoteDataSource.createPost(any())).thenThrow(tServerException);

      // Act
      final result = await repository.createPost(tCreatePostParams);

      // Assert
      verify(() => mockRemoteDataSource.createPost(tCreatePostParams));
      expect(result, Left(tServerFailure));
    });

    test('should return NoInternetFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.createPost(tCreatePostParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
      expect(result, Left(tNoInternetFailure));
    });
  });

  group('updatePost', () {
    setUp(() {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('should check if the device is online', () async {
      // Arrange
      when(() => mockRemoteDataSource.updatePost(any())).thenAnswer((_) async => tPostModel);

      // Act
      await repository.updatePost(tPostModel);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    test('should return updated post on successful call', () async {
      // Arrange
      when(() => mockRemoteDataSource.updatePost(any())).thenAnswer((_) async => tPostModel);

      // Act
      final result = await repository.updatePost(tPostModel);

      // Assert
      verify(() => mockRemoteDataSource.updatePost(tPostModel));
      expect(result, equals(Right(tPostModel)));
    });

    test('should return server failure on unsuccessful call', () async {
      // Arrange
      when(() => mockRemoteDataSource.updatePost(any())).thenThrow(tServerException);

      // Act
      final result = await repository.updatePost(tPostEntity);

      // Assert
      verify(() => mockRemoteDataSource.updatePost(tPostModel));
      expect(result, Left(tServerFailure));
    });

    test('should return NoInternetFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.updatePost(tPostModel);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
      expect(result, Left(tNoInternetFailure));
    });
  });

  group('deletePost', () {
    setUp(() {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('should check if the device is online', () async {
      // Arrange
      when(() => mockRemoteDataSource.deletePost(any())).thenAnswer((_) async => unit);

      // Act
      await repository.deletePost(tPostEntity);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    test('should return unit on successful call', () async {
      // Arrange
      when(() => mockRemoteDataSource.deletePost(any())).thenAnswer((_) async => unit);

      // Act
      final result = await repository.deletePost(tPostEntity);

      // Assert
      verify(() => mockRemoteDataSource.deletePost(tPostEntity.id));
      expect(result, const Right(unit));
    });

    test('should return server failure on unsuccessful call', () async {
      // Arrange
      when(() => mockRemoteDataSource.deletePost(any())).thenThrow(tServerException);

      // Act
      final result = await repository.deletePost(tPostEntity);

      // Assert
      verify(() => mockRemoteDataSource.deletePost(tPostEntity.id));
      expect(result, Left(tServerFailure));
    });

    test('should return NoInternetFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.deletePost(tPostEntity);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
      expect(result, Left(tNoInternetFailure));
    });
  });

  group('searchPosts', () {
    setUp(() {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
    });

    test('should check if the device is online', () async {
      // Arrange
      when(() => mockRemoteDataSource.searchPosts(any())).thenAnswer((_) async => tPostModels);

      // Act
      await repository.searchPosts(tPaginationWithSearchParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    test('should return remote data on successful call', () async {
      // Arrange
      when(() => mockRemoteDataSource.searchPosts(any())).thenAnswer((_) async => tPostModels);

      // Act
      final result = await repository.searchPosts(tPaginationWithSearchParams);

      // Assert
      verify(() => mockRemoteDataSource.searchPosts(tPaginationWithSearchParams));
      expect(result, Right(tPostModels));
    });

    test('should return server failure on unsuccessful call', () async {
      // Arrange
      when(() => mockRemoteDataSource.searchPosts(any())).thenThrow(tServerException);

      // Act
      final result = await repository.searchPosts(tPaginationWithSearchParams);

      // Assert
      verify(() => mockRemoteDataSource.searchPosts(tPaginationWithSearchParams));
      expect(result, Left(tServerFailure));
    });

    test('should return NoInternetFailure when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.searchPosts(tPaginationWithSearchParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
      verifyZeroInteractions(mockRemoteDataSource);
      expect(result, Left(tNoInternetFailure));
    });
  });

  group('getBookmarkedPosts', () {
    test('should return remote data on successful call when online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getPostsByIds(any())).thenAnswer((_) async => tPostModels);

      // Act
      final result = await repository.getBookmarkedPosts(tListBookmarkPostIdParams);

      // Assert
      verify(() => mockRemoteDataSource.getPostsByIds(tListBookmarkPostIdParams));
      expect(result, Right(tPostModels));
    });

    test('should return server failure on unsuccessful remote call when online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getPostsByIds(any())).thenThrow(tServerException);

      // Act
      final result = await repository.getBookmarkedPosts(tListBookmarkPostIdParams);

      // Assert
      verify(() => mockRemoteDataSource.getPostsByIds(tListBookmarkPostIdParams));
      expect(result, Left(tServerFailure));
    });
  });
}
