import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/enum.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../user/data/models/user_model.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/get_comments_by_post_id_usecase.dart';
import '../models/comment_model.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getCommentsByPostId(GetCommentsParams params);
  Future<CommentModel> addComment(AddCommentParams params);
  Future<CommentModel> updateComment(CommentModel comment);
  Future<void> deleteComment(CommentModel comment);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final FirebaseFirestore firestore;

  CommentRemoteDataSourceImpl({required this.firestore});

  DocumentSnapshot? _lastDocumentAllComments;

  Future<Map<String, UserModel>> _getUserMap(List<String> userIds) async {
    if (userIds.isEmpty) {
      return {};
    }
    final userDocs =
        await firestore.collection('users').where(FieldPath.documentId, whereIn: userIds).get();
    return {for (var doc in userDocs.docs) doc.id: UserModel.fromFirestore(doc)};
  }

  @override
  Future<List<CommentModel>> getCommentsByPostId(GetCommentsParams params) async {
    try {
      Query query = firestore
          .collection('comments')
          .where('postId', isEqualTo: params.postId)
          .orderBy('updatedAt', descending: params.order == PaginationOrder.desc);

      if (params.limit > 0 && params.page > 0) {
        query = query.limit(params.limit * (params.page));
      }

      if (params.page > 1 && _lastDocumentAllComments != null) {
        query = query.startAfterDocument(_lastDocumentAllComments!);
      }

      final querySnapshot = await query.get();

      if (querySnapshot.docs.isNotEmpty) {
        _lastDocumentAllComments = querySnapshot.docs.last;
      }

      final userIds =
          querySnapshot.docs
              .map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String)
              .toList();
      final userMap = await _getUserMap(userIds);

      final comments =
          querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final user = userMap[data['userId']];
            if (user == null) {
              throw ServerException(message: "User not found for comment ${doc.id}");
            }

            return CommentModel.fromFirestore(doc, user);
          }).toList();

      return comments;
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'getCommentsByPostId');
    }
  }

  @override
  Future<CommentModel> addComment(AddCommentParams params) async {
    try {
      final docRef = firestore.collection('comments').doc();
      final userSnapshot = await firestore.collection('users').doc(params.userId).get();

      if (!userSnapshot.exists) {
        throw ServerException(message: 'User not found');
      }

      final userModel = UserModel.fromFirestore(userSnapshot);
      final comment = CommentModel(
        id: docRef.id,
        postId: params.postId,
        user: userModel,
        body: params.body,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(comment.toJson());
      return comment;
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'addComment');
    }
  }

  @override
  Future<CommentModel> updateComment(CommentModel comment) async {
    try {
      final commentRef = firestore.collection('comments').doc(comment.id);

      await commentRef.update(comment.toJson());

      return comment;
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'updateComment');
    }
  }

  @override
  Future<void> deleteComment(CommentModel comment) async {
    try {
      await firestore.collection('comments').doc(comment.id).delete();
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'deleteComment');
    }
  }
}
