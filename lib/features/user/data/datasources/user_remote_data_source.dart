import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/bookmark_post_usecase.dart';
import '../../domain/usecases/get_all_users_usecase.dart';
import '../../domain/usecases/update_friend_list_usecase.dart';
import '../models/user_detail_model.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers(GetAllUsersWithExcludeIdParams params);
  Future<UserModel> getUserById(String id);
  Future<UserDetailModel> getUserDetail(String id);
  Future<UserModel> updateUser(UserModel user);
  Future<void> updateFriendList(UpdateFriendListParams params);
  Future<void> bookmarkPost(BookmarkPostParams params);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore firestore;

  UserRemoteDataSourceImpl({required this.firestore});

  DocumentSnapshot? _lastDocumentAllUsers;

  @override
  Future<List<UserModel>> getAllUsers(GetAllUsersWithExcludeIdParams params) async {
    try {
      Query query;
      if (params.excludeId.isNotEmpty) {
        query = firestore
            .collection('users')
            .where(FieldPath.documentId, isNotEqualTo: params.excludeId);
      } else {
        query = firestore.collection('users');
      }

      if (params.limit > 0 && params.page > 0) {
        query = query.limit(params.limit * params.page);
      }

      if (params.page > 1 && _lastDocumentAllUsers != null) {
        query = query.startAfterDocument(_lastDocumentAllUsers!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocumentAllUsers = querySnapshot.docs.last;
      }

      return querySnapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'getAllUsers');
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final docSnapshot = await firestore.collection('users').doc(id).get();
      if (!docSnapshot.exists) throw ServerException(message: 'User not found');
      return UserModel.fromFirestore(docSnapshot);
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'getUserById');
    }
  }

  @override
  Future<UserDetailModel> getUserDetail(String id) async {
    try {
      final docSnapshot = await firestore.collection('users').doc(id).get();

      if (!docSnapshot.exists) throw ServerException(message: 'User detail not found');

      final postsQuery =
          await firestore.collection('posts').where('userId', isEqualTo: id).count().get();
      final int postsCount = postsQuery.count ?? 0;

      final commentsQuery =
          await firestore.collection('comments').where('userId', isEqualTo: id).count().get();
      final int commentsCount = commentsQuery.count ?? 0;

      final friendsCount = (docSnapshot.data()?['friendIds'] as List<dynamic>?)?.length ?? 0;

      return UserDetailModel(friends: friendsCount, posts: postsCount, comments: commentsCount);
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'getUserDetail');
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final userRef = firestore.collection('users').doc(user.id);
      await userRef.update(user.toFirebaseDoc());
      return user;
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'updateUser');
    }
  }

  @override
  Future<void> updateFriendList(UpdateFriendListParams params) async {
    try {
      final userRef = firestore.collection('users').doc(params.userId);
      await userRef.update({'friendIds': params.friendIds});
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'updateFriendList');
    }
  }

  @override
  Future<void> bookmarkPost(BookmarkPostParams params) async {
    try {
      final userRef = firestore.collection('users').doc(params.userId);

      if (params.bookmarkedPostIds.contains(params.postId)) {
        await userRef.update({
          'bookmarkedPosts': FieldValue.arrayRemove([params.postId]),
        });
      } else {
        await userRef.update({
          'bookmarkedPosts': FieldValue.arrayUnion([params.postId]),
        });
      }
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'bookmarkPost');
    }
  }
}
