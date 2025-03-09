import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_starter_clean/core/errors/exceptions.dart';
import 'package:flutter_starter_clean/features/comment/data/datasources/comment_remote_data_source.dart';
import 'package:flutter_starter_clean/features/comment/data/models/comment_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late CommentRemoteDataSourceImpl dataSource;
  late FirebaseFirestore mockFirebaseFirestore;

  setUp(() {
    mockFirebaseFirestore = FakeFirebaseFirestore();
    dataSource = CommentRemoteDataSourceImpl(firestore: mockFirebaseFirestore);
  });

  setUpAll(() {
    registerFallbackValue(tCommentModel);
    registerFallbackValue(tGetCommentsParams);
    registerFallbackValue(tAddCommentParams);
  });

  group('getCommentsByPostId', () {
    test('should return List<CommentModel> on successful retrieval', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('users')
          .doc(tUserModel.id)
          .set(tUserModel.toFirebaseDoc());
      await mockFirebaseFirestore
          .collection('comments')
          .doc(tCommentModel.id)
          .set(tCommentModel.toJson());

      // Act
      final result = await dataSource.getCommentsByPostId(tGetCommentsParams);

      // Assert
      expect(result, isA<List<CommentModel>>());
      expect(result.length, 1);
      expect(result[0].postId, tPostModel.id);
      expect(result[0].user.id, tUserModel.id);
      expect(result[0].body, 'Test comment');
    });
    test('should throw ServerException when user data is missing', () async {
      // Arrange
      await mockFirebaseFirestore.collection('comments').add(tCommentModel.toJson());

      // Act & Assert
      expect(
        () => dataSource.getCommentsByPostId(tGetCommentsParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('addComment', () {
    test('should add a comment and return CommentModel', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('users')
          .doc(tUserModel.id)
          .set(tUserModel.toFirebaseDoc());

      // Act
      final result = await dataSource.addComment(tAddCommentParams);

      // Assert
      expect(result, isA<CommentModel>());
      final snapshot = await mockFirebaseFirestore.collection('comments').doc(result.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['body'], tAddCommentParams.body);
    });

    test('should throw ServerException if user does not exist', () async {
      // Act & Assert
      expect(() => dataSource.addComment(tAddCommentParams), throwsA(isA<ServerException>()));
    });
  });
  group('updateComment', () {
    test('should update a comment and return CommentModel', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('comments')
          .doc(tCommentModel.id)
          .set(tCommentModel.toJson());

      // Act
      final result = await dataSource.updateComment(tUpdatedCommentModel);

      // Assert
      expect(result, isA<CommentModel>());
      final snapshot =
          await mockFirebaseFirestore.collection('comments').doc(tCommentModel.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['body'], tUpdatedCommentModel.body);
    });
  });
  group('deleteComment', () {
    test('should delete a comment', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('comments')
          .doc(tCommentModel.id)
          .set(tCommentModel.toJson());

      // Act
      await dataSource.deleteComment(tCommentModel);

      // Assert
      final snapshot =
          await mockFirebaseFirestore.collection('comments').doc(tCommentModel.id).get();
      expect(snapshot.exists, isFalse);
    });
  });
}
