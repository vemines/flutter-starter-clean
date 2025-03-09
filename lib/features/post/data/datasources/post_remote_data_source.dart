import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/enum.dart';
import '../../../../core/constants/env.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/usecase/params.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/get_posts_by_user_id_usecase.dart';
import '../../domain/usecases/search_posts_usecase.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getAllPosts(PaginationParams params);
  Future<List<PostModel>> getPostsByUserId(GetPostsByUserIdParams params);
  Future<PostModel> getPostById(String id);
  Future<PostModel> createPost(CreatePostParams params);
  Future<PostModel> updatePost(PostModel post);
  Future<void> deletePost(String id);
  Future<List<PostModel>> searchPosts(PaginationSearchPostParams params);
  Future<List<PostModel>> getPostsByIds(ListIdParams params);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final FirebaseFirestore firestore;

  DocumentSnapshot? _lastDocumentAllPosts;
  DocumentSnapshot? _lastDocumentPostsByUserId;

  PostRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<PostModel>> getAllPosts(PaginationParams params) async {
    try {
      Query query = firestore
          .collection('posts')
          .orderBy('updatedAt', descending: params.order == PaginationOrder.desc);

      if (params.limit > 0 && params.page > 0) {
        query = query.limit(params.limit * (params.page));
      }

      if (params.page > 1 && _lastDocumentAllPosts != null) {
        query = query.startAfterDocument(_lastDocumentAllPosts!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocumentAllPosts = querySnapshot.docs.last;
      }
      return querySnapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'getAllPosts');
    }
  }

  @override
  Future<List<PostModel>> getPostsByUserId(GetPostsByUserIdParams params) async {
    try {
      Query query = firestore
          .collection('posts')
          .where('userId', isEqualTo: params.userId)
          .orderBy('updatedAt', descending: params.order == PaginationOrder.desc);

      if (params.limit > 0 && params.page > 0) {
        query = query.limit(params.limit * params.page);
      }
      if (params.page > 1 && _lastDocumentPostsByUserId != null) {
        query = query.startAfterDocument(_lastDocumentPostsByUserId!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocumentPostsByUserId = querySnapshot.docs.last;
      }
      return querySnapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'getPostsByUserId');
    }
  }

  @override
  Future<PostModel> getPostById(String id) async {
    try {
      final docSnapshot = await firestore.collection('posts').doc(id).get();
      if (!docSnapshot.exists) throw ServerException(message: 'Post not found');
      return PostModel.fromFirestore(docSnapshot);
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'getPostById');
    }
  }

  @override
  Future<PostModel> createPost(CreatePostParams params) async {
    try {
      final docRef = firestore.collection('posts').doc();
      final post = PostModel(
        id: docRef.id,
        userId: params.userId,
        title: params.title,
        body: params.body,
        imageUrl: "https://picsum.photos/800/450?random=${docRef.id}",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await docRef.set(post.toJson());
      return post;
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'createPost');
    }
  }

  @override
  Future<PostModel> updatePost(PostModel post) async {
    try {
      final postRef = firestore.collection('posts').doc(post.id);
      await postRef.update(post.toJson());
      return post;
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'updatePost');
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      await firestore.collection('posts').doc(id).delete();
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'deletePost');
    }
  }

  @override
  Future<List<PostModel>> getPostsByIds(ListIdParams params) async {
    // Firestore's whereIn operator has a hard limit of 30 values.
    try {
      List<PostModel> allPosts = [];
      for (int i = 0; i < params.ids.length; i += 30) {
        final end = (i + 30 < params.ids.length) ? i + 30 : params.ids.length;
        final chunk = params.ids.sublist(i, end);

        final querySnapshot =
            await firestore.collection('posts').where(FieldPath.documentId, whereIn: chunk).get();
        allPosts.addAll(querySnapshot.docs.map((doc) => PostModel.fromFirestore(doc)));
      }
      return allPosts;
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'getPostsByIds');
    }
  }

  @override
  Future<List<PostModel>> searchPosts(PaginationSearchPostParams params) async {
    try {
      final response = await params.algoliaService.searchIndex(
        indexName: ALGOLIA_INDEX_NAME_POSTS,
        query: params.search,
        hitsPerPage: params.limit,
        page: params.page - 1,
      );
      return response.hits.map((hit) {
        return PostModel.fromHit(hit);
      }).toList();
    } on AlgoliaException catch (e, s) {
      throw ServerException(message: "Algolia Error: $e", stackTrace: s);
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
