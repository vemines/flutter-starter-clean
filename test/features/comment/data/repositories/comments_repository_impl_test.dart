import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/comment/data/models/comment_model.dart';
import 'package:flutter_starter_clean/features/comment/data/repositories/comment_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late CommentRepositoryImpl repository;
  late MockCommentRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockCommentRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = CommentRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });
  setUpAll(() {
    registerFallbackValue(tAddCommentParams);
    registerFallbackValue(tCommentModel);
    registerFallbackValue(tGetCommentsParams);
  });

  group('getCommentsByPostId', () {
    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.getCommentsByPostId(any()),
      ).thenAnswer((_) async => tCommentModels);

      // Act
      await repository.getCommentsByPostId(tGetCommentsParams);

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
          () => mockRemoteDataSource.getCommentsByPostId(any()),
        ).thenAnswer((_) async => tCommentModels);

        // Act
        final result = await repository.getCommentsByPostId(tGetCommentsParams);

        // Assert
        verify(() => mockRemoteDataSource.getCommentsByPostId(tGetCommentsParams));
        expect(result, equals(Right(tCommentModels)));
      });

      test('should return server failure on unsuccessful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.getCommentsByPostId(any())).thenThrow(tServerException);

        // Act
        final result = await repository.getCommentsByPostId(tGetCommentsParams);

        // Assert
        verify(() => mockRemoteDataSource.getCommentsByPostId(tGetCommentsParams));
        expect(result, equals(Left(tServerFailure)));
      });
    });

    group('when device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NoInternetFailure when offline', () async {
        // Act
        final result = await repository.getCommentsByPostId(tGetCommentsParams);

        // Assert
        verify(() => mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, equals(Left(tNoInternetFailure)));
      });
    });
  });

  group('addComment', () {
    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.addComment(any())).thenAnswer((_) async => tCommentModel);

      // Act
      await repository.addComment(tAddCommentParams);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return created comment on successful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.addComment(any())).thenAnswer((_) async => tCommentModel);

        // Act
        final result = await repository.addComment(tAddCommentParams);

        // Assert
        verify(() => mockRemoteDataSource.addComment(tAddCommentParams));
        expect(result, Right(tCommentModel));
      });

      test('should return server failure on unsuccessful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.addComment(any())).thenThrow(tServerException);

        // Act
        final result = await repository.addComment(tAddCommentParams);

        // Assert
        verify(() => mockRemoteDataSource.addComment(tAddCommentParams));
        expect(result, Left(tServerFailure));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NoInternetFailure when device is offline', () async {
        // Act
        final result = await repository.addComment(tAddCommentParams);

        // Assert
        verify(() => mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, Left(tNoInternetFailure));
      });
    });
  });

  group('updateComment', () {
    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateComment(any())).thenAnswer((_) async => tCommentModel);

      // Act
      await repository.updateComment(tCommentEntity);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return updated comment on successful call', () async {
        // Arrange
        when(
          () => mockRemoteDataSource.updateComment(any()),
        ).thenAnswer((_) async => tCommentModel);

        // Act
        final result = await repository.updateComment(tCommentEntity);

        // Assert
        verify(() => mockRemoteDataSource.updateComment(any(that: isA<CommentModel>())));
        expect(result, Right(tCommentModel));
      });

      test('should return server failure on unsuccessful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateComment(any())).thenThrow(tServerException);

        // Act
        final result = await repository.updateComment(tCommentEntity);

        // Assert
        verify(() => mockRemoteDataSource.updateComment(any(that: isA<CommentModel>())));
        expect(result, Left(tServerFailure));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NoInternetFailure when device is offline', () async {
        // Act
        final result = await repository.updateComment(tCommentEntity);

        // Assert
        verify(() => mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, Left(tNoInternetFailure));
      });
    });
  });

  group('deleteComment', () {
    test('should check if the device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.deleteComment(any())).thenAnswer((_) async => unit);

      // Act
      await repository.deleteComment(tCommentEntity);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      test('should return unit on successful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.deleteComment(any())).thenAnswer((_) async => unit);

        // Act
        final result = await repository.deleteComment(tCommentEntity);

        // Assert
        verify(() => mockRemoteDataSource.deleteComment(tCommentModel));
        expect(result, const Right(unit));
      });

      test('should return server failure on unsuccessful call', () async {
        // Arrange
        when(() => mockRemoteDataSource.deleteComment(any())).thenThrow(tServerException);

        // Act
        final result = await repository.deleteComment(tCommentEntity);

        // Assert
        verify(() => mockRemoteDataSource.deleteComment(tCommentModel));
        expect(result, Left(tServerFailure));
      });
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test('should return NoInternetFailure when device is offline', () async {
        // Act
        final result = await repository.deleteComment(tCommentEntity);

        // Assert
        verify(() => mockNetworkInfo.isConnected);
        verifyZeroInteractions(mockRemoteDataSource);
        expect(result, Left(tNoInternetFailure));
      });
    });
  });
}
