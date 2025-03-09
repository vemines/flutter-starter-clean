import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_starter_clean/core/errors/exceptions.dart';
import 'package:flutter_starter_clean/core/usecase/params.dart';
import 'package:flutter_starter_clean/features/post/data/datasources/post_remote_data_source.dart';
import 'package:flutter_starter_clean/features/post/data/models/post_model.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/get_posts_by_user_id_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late PostRemoteDataSourceImpl dataSource;
  late FirebaseFirestore mockFirebaseFirestore;

  setUp(() {
    mockFirebaseFirestore = FakeFirebaseFirestore();
    dataSource = PostRemoteDataSourceImpl(firestore: mockFirebaseFirestore);
  });

  setUpAll(() {
    registerFallbackValue(tPostModel);
    registerFallbackValue(tGetPostsByUserIdParams);
    registerFallbackValue(tCreatePostParams);
    registerFallbackValue(tPaginationParams);
    registerFallbackValue(tListBookmarkPostIdParams);
  });

  group('getAllPosts', () {
    test('should return List<PostModel> on successful retrieval', () async {
      // Arrange
      await mockFirebaseFirestore.collection('posts').add(tPostModel.toJson());
      await mockFirebaseFirestore.collection('posts').add(tPostModel.toJson());

      // Act
      final result = await dataSource.getAllPosts(tPaginationParams);

      // Assert
      expect(result, isA<List<PostModel>>());
      expect(result.length, 2);
    });

    test('should handle pagination correctly', () async {
      // Arrange
      for (int i = 0; i < 25; i++) {
        await mockFirebaseFirestore
            .collection('posts')
            .add(tPostModel.copyWith(id: 'post$i', title: 'Post $i').toJson());
      }

      // Act
      final resultPage1 = await dataSource.getAllPosts(const PaginationParams(page: 1, limit: 11));
      final resultPage2 = await dataSource.getAllPosts(const PaginationParams(page: 2, limit: 11));
      final resultPage3 = await dataSource.getAllPosts(const PaginationParams(page: 3, limit: 11));
      // Assert
      expect(resultPage1.length, 11);
      expect(resultPage2.length, 11);
      expect(resultPage3.length, 3);
      expect(resultPage1[0].title, 'Post 0');
      expect(resultPage2[0].title, 'Post 11');
      expect(resultPage3[2].title, 'Post 24');
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(
        () => mockFirestore.collection(any()).orderBy(any()).limit(any()).get(),
      ).thenThrow(tFirebaseException);

      final failingDataSource = PostRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(
        () => failingDataSource.getAllPosts(tPaginationParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getPostsByUserId', () {
    test('should return List<PostModel> on successful retrieval', () async {
      // Arrange
      await mockFirebaseFirestore.collection('posts').add(tPostModel.toJson());

      // Act
      final result = await dataSource.getPostsByUserId(tGetPostsByUserIdParams);

      // Assert
      expect(result, isA<List<PostModel>>());
      expect(result.length, 1);
      expect(result[0].userId, tGetPostsByUserIdParams.userId);
    });

    test('should handle pagination correctly', () async {
      // Arrange
      for (int i = 0; i < 25; i++) {
        await mockFirebaseFirestore
            .collection('posts')
            .add(tPostModel.copyWith(id: 'post$i', userId: 'user1', title: 'Post $i').toJson());
      }

      // Act
      final resultPage1 = await dataSource.getPostsByUserId(
        const GetPostsByUserIdParams(userId: 'user1', page: 1, limit: 11),
      );
      final resultPage2 = await dataSource.getPostsByUserId(
        const GetPostsByUserIdParams(userId: 'user1', page: 2, limit: 11),
      );
      final resultPage3 = await dataSource.getPostsByUserId(
        const GetPostsByUserIdParams(userId: 'user1', page: 3, limit: 11),
      );

      // Assert
      expect(resultPage1.length, 11);
      expect(resultPage2.length, 11);
      expect(resultPage3.length, 3);
      expect(resultPage1[0].title, 'Post 0');
      expect(resultPage2[0].title, 'Post 11');
      expect(resultPage3[2].title, 'Post 24');
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(
        () =>
            mockFirestore
                .collection(any())
                .where(any(), isEqualTo: any(named: 'isEqualTo'))
                .orderBy(any())
                .limit(any())
                .get(),
      ).thenThrow(tFirebaseException);
      final failingDataSource = PostRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(
        () => failingDataSource.getPostsByUserId(tGetPostsByUserIdParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getPostById', () {
    test('should return PostModel on successful retrieval', () async {
      // Arrange
      await mockFirebaseFirestore.collection('posts').doc(tPostModel.id).set(tPostModel.toJson());

      // Act
      final result = await dataSource.getPostById(tPostModel.id);

      // Assert
      expect(result, isA<PostModel>());
      expect(result.id, tPostModel.id);
    });

    test('should throw ServerException if post does not exist', () async {
      // Act & Assert
      expect(() => dataSource.getPostById(tPostModel.id), throwsA(isA<ServerException>()));
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(() => mockFirestore.collection(any()).doc(any()).get()).thenThrow(tFirebaseException);
      final failingDataSource = PostRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(() => failingDataSource.getPostById(tPostModel.id), throwsA(isA<ServerException>()));
    });
  });

  group('createPost', () {
    test('should create a post and return PostModel', () async {
      // Act
      final result = await dataSource.createPost(tCreatePostParams);

      // Assert
      expect(result, isA<PostModel>());
      // Verify the post was added.
      final snapshot = await mockFirebaseFirestore.collection('posts').doc(result.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['title'], tCreatePostParams.title);
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(() => mockFirestore.collection(any()).doc().set(any())).thenThrow(tFirebaseException);
      final failingDataSource = PostRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(
        () => failingDataSource.createPost(tCreatePostParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('updatePost', () {
    test('should update a post and return PostModel', () async {
      // Arrange
      await mockFirebaseFirestore.collection('posts').doc(tPostModel.id).set(tPostModel.toJson());

      // Act
      final result = await dataSource.updatePost(tUpdatedPostModel);

      // Assert
      expect(result, isA<PostModel>());
      final snapshot = await mockFirebaseFirestore.collection('posts').doc(tPostModel.id).get();
      expect(snapshot.exists, isTrue);
      expect(snapshot.data()!['body'], tUpdatedPostModel.body);
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(
        () => mockFirestore.collection(any()).doc(any()).update(any()),
      ).thenThrow(tFirebaseException);
      final failingDataSource = PostRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(() => failingDataSource.updatePost(tPostModel), throwsA(isA<ServerException>()));
    });
  });

  group('deletePost', () {
    test('should delete a post', () async {
      // Arrange
      await mockFirebaseFirestore.collection('posts').doc(tPostModel.id).set(tPostModel.toJson());

      // Act
      await dataSource.deletePost(tPostModel.id);

      // Assert
      final snapshot = await mockFirebaseFirestore.collection('posts').doc(tPostModel.id).get();
      expect(snapshot.exists, isFalse);
    });

    test('should throw ServerException on Firestore errors', () async {
      // Arrange
      final mockFirestore = MockFirebaseFirestore();
      when(() => mockFirestore.collection(any()).doc(any()).delete()).thenThrow(tFirebaseException);
      final failingDataSource = PostRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(() => failingDataSource.deletePost(tPostModel.id), throwsA(isA<ServerException>()));
    });
  });

  group('searchPosts', () {
    test('should return a list of PostModel on successful search', () async {
      // Arrange
      final expectedResponse = SearchResponse(
        hits: [],
        page: tPaginationWithSearchParams.page - 1,
        hitsPerPage: tPaginationWithSearchParams.limit,
        nbHits: 0,
        processingTimeMS: 10,
        query: tPaginationWithSearchParams.search,
        params: '',
      );

      // Mock the behavior of searchIndex.
      when(
        () => tAlgoliaService.searchIndex(
          indexName: any(named: 'indexName'),
          query: any(named: 'query'),
          hitsPerPage: any(named: 'hitsPerPage'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => expectedResponse);

      // Act
      final result = await dataSource.searchPosts(tPaginationWithSearchParams);

      // Assert
      expect(result, isA<List<PostModel>>());
    });

    test('should throw ServerException on search failures', () async {
      // Arrange: Mock the behavior to throw an exception.
      when(
        () => tAlgoliaService.searchIndex(
          indexName: any(named: 'indexName'),
          query: any(named: 'query'),
          hitsPerPage: any(named: 'hitsPerPage'),
          page: any(named: 'page'),
        ),
      ).thenThrow(Exception('Search failed'));

      // Act & Assert
      expect(
        () => dataSource.searchPosts(tPaginationWithSearchParams),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('getPostsByIds', () {
    test('should return List<PostModel> for valid IDs', () async {
      // Arrange
      await mockFirebaseFirestore
          .collection('posts')
          .doc('post1')
          .set(tPostModel.copyWith(id: 'post1').toJson());
      await mockFirebaseFirestore
          .collection('posts')
          .doc('post2')
          .set(tPostModel.copyWith(id: 'post2').toJson());

      // Act
      final result = await dataSource.getPostsByIds(const ListIdParams(ids: ['post1', 'post2']));

      // Assert
      expect(result, isA<List<PostModel>>());
      expect(result.length, 2);
      expect(result[0].id, 'post1');
      expect(result[1].id, 'post2');
    });

    test('should throw ServerException on Firestore errors', () async {
      final mockFirestore = MockFirebaseFirestore();
      when(
        () => mockFirestore.collection(any()).where(any(), whereIn: any(named: 'whereIn')).get(),
      ).thenThrow(tFirebaseException);

      final failingDataSource = PostRemoteDataSourceImpl(firestore: mockFirestore);

      // Act & Assert
      expect(
        () => failingDataSource.getPostsByIds(tListBookmarkPostIdParams),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
