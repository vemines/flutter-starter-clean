import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_starter_clean/core/errors/exceptions.dart';
import 'package:flutter_starter_clean/features/user/data/datasources/user_remote_data_source.dart';
import 'package:flutter_starter_clean/features/user/data/models/user_detail_model.dart';
import 'package:flutter_starter_clean/features/user/data/models/user_model.dart';
import 'package:flutter_starter_clean/features/user/domain/usecases/get_all_users_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late UserRemoteDataSourceImpl dataSource;
  late FirebaseFirestore mockFirebaseFirestore;

  setUp(() {
    mockFirebaseFirestore = FakeFirebaseFirestore();
    dataSource = UserRemoteDataSourceImpl(firestore: mockFirebaseFirestore);
  });

  setUpAll(() {
    registerFallbackValue(tUpdateFriendListParams);
    registerFallbackValue(tBookmarkPostParams);
    registerFallbackValue(tGetAllUsersWithExcludeParams);
    registerFallbackValue(tUserModel);
  });

  group('getAllUsers', () {
    test('should return List<UserModel> on successful retrieval', () async {
      // Arrange
      await mockFirebaseFirestore.collection('users').add(tUserModel.toFirebaseDoc());
      await mockFirebaseFirestore
          .collection('users')
          .add(tUserModel.copyWith(id: 'user2').toFirebaseDoc());

      // Act
      final result = await dataSource.getAllUsers(tGetAllUsersWithExcludeParams);

      // Assert
      expect(result, isA<List<UserModel>>());
    });

    test('should handle pagination correctly', () async {
      // Arrange
      for (int i = 0; i < 25; i++) {
        await mockFirebaseFirestore
            .collection('users')
            .add(tUserModel.copyWith(id: 'user$i', fullName: 'User $i').toFirebaseDoc());
      }

      // Act
      final resultPage1 = await dataSource.getAllUsers(
        GetAllUsersWithExcludeIdParams(excludeId: '', page: 1, limit: 11),
      );
      final resultPage2 = await dataSource.getAllUsers(
        GetAllUsersWithExcludeIdParams(excludeId: '', page: 2, limit: 11),
      );
      final resultPage3 = await dataSource.getAllUsers(
        GetAllUsersWithExcludeIdParams(excludeId: '', page: 3, limit: 11),
      );
      // Assert
      expect(resultPage1.length, 11);
      expect(resultPage2.length, 11);
      expect(resultPage3.length, 3);
      expect(resultPage1[0].fullName, 'User 0');
      expect(resultPage2[0].fullName, 'User 11');
      expect(resultPage3[2].fullName, 'User 24');
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(
        () => mockFirestore.collection(any()).where(any(), isNotEqualTo: any()).limit(any()).get(),
      ).thenThrow(tFirebaseException);
      final failingDataSource = UserRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(
        () => failingDataSource.getAllUsers(tGetAllUsersWithExcludeParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getUserById', () {
    test('should return UserModel on successful retrieval', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('users')
          .doc(tUserModel.id)
          .set(tUserModel.toFirebaseDoc());

      // Act
      final result = await dataSource.getUserById(tUserModel.id);

      // Assert
      expect(result, isA<UserModel>());
      expect(result, tUserModel);
    });

    test('should throw ServerException if user does not exist', () async {
      // Act & Assert
      expect(() => dataSource.getUserById(tUserModel.id), throwsA(isA<ServerException>()));
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(() => mockFirestore.collection(any()).doc(any()).get()).thenThrow(tFirebaseException);
      final failingDataSource = UserRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(() => failingDataSource.getUserById(tUserModel.id), throwsA(isA<ServerException>()));
    });
  });

  group('getUserDetail', () {
    test('should return UserDetailModel on successful retrieval', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('users')
          .doc(tUserModel.id)
          .set(tUserModel.toFirebaseDoc());
      await mockFirebaseFirestore.collection('posts').add({'userId': tUserModel.id});
      await mockFirebaseFirestore.collection('posts').add({'userId': tUserModel.id});
      await mockFirebaseFirestore.collection('comments').add({'userId': tUserModel.id});

      // Act
      final result = await dataSource.getUserDetail(tUserModel.id);

      // Assert
      expect(result, isA<UserDetailModel>());
      expect(result.posts, 2);
      expect(result.comments, 1);
    });

    test('should throw ServerException if user does not exist', () async {
      // Act & Assert
      expect(() => dataSource.getUserDetail(tUserModel.id), throwsA(isA<ServerException>()));
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(() => mockFirestore.collection(any()).doc(any()).get()).thenThrow(tFirebaseException);

      // Act & Assert
      expect(() => dataSource.getUserDetail(tUserModel.id), throwsA(isA<ServerException>()));
    });
  });

  group('updateUser', () {
    test('should update user data and return UserModel', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('users')
          .doc(tUserModel.id)
          .set(tUserModel.toFirebaseDoc());

      // Act
      final result = await dataSource.updateUser(tUpdateUserModel);

      // Assert
      expect(result, isA<UserModel>());
      // Verify the update.
      final snapshot = await mockFirebaseFirestore.collection('users').doc(tUserModel.id).get();
      expect(snapshot.data()!['fullName'], tUpdateUserModel.fullName);
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(
        () => mockFirestore.collection(any()).doc(any()).update(any()),
      ).thenThrow(tFirebaseException);
      final failingDataSource = UserRemoteDataSourceImpl(firestore: mockFirestore);
      // Act & Assert
      expect(() => failingDataSource.updateUser(tUserModel), throwsA(isA<ServerException>()));
    });
  });

  group('updateFriendList', () {
    test('should update friend list successfully', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('users')
          .doc(tUserModel.id)
          .set(tUserModel.toFirebaseDoc());

      // Act
      await dataSource.updateFriendList(tUpdateFriendListParams);

      // Assert: Verify the update.
      final snapshot = await mockFirebaseFirestore.collection('users').doc(tUserModel.id).get();
      expect(
        List<String>.from(snapshot.data()!['friendIds']),
        containsAll(tUpdateFriendListParams.friendIds),
      );
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(
        () => mockFirestore.collection(any()).doc(any()).update(any()),
      ).thenThrow(tFirebaseException);
      final failingDataSource = UserRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(
        () => failingDataSource.updateFriendList(tUpdateFriendListParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('bookmarkPost', () {
    test('should add post to bookmarks if not already present', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('users')
          .doc(tUserModel.id)
          .set(tUserModel.toFirebaseDoc());

      // Act
      await dataSource.bookmarkPost(tBookmarkPostParams);

      // Assert
      final snapshot = await mockFirebaseFirestore.collection('users').doc(tUserModel.id).get();
      expect(
        List<String>.from(snapshot.data()!['bookmarkedPosts']),
        contains(tBookmarkPostParams.postId),
      );
    });

    test('should remove post from bookmarks if already present', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('users')
          .doc(tUserModel.id)
          .set(tUserModel.toFirebaseDoc());

      // Act
      await dataSource.bookmarkPost(tBookmarkPostParams2);

      // Assert: Verify the post was removed.
      final snapshot = await mockFirebaseFirestore.collection('users').doc(tUserModel.id).get();
      expect(
        List<String>.from(snapshot.data()!['bookmarkedPosts']),
        isNot(contains(tBookmarkPostParams.postId)),
      );
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange.
      final mockFirestore = MockFirebaseFirestore();
      when(
        () => mockFirestore.collection(any()).doc(any()).update(any()),
      ).thenThrow(tFirebaseException);
      final failingDataSource = UserRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(
        () => failingDataSource.bookmarkPost(tBookmarkPostParams),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
