import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/api_mapping.dart';
import '../../../../core/utils/timestamp_util.dart';
import '../../../user/data/models/user_model.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../../domain/entities/comment_entity.dart';

class CommentModel extends CommentEntity {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.user,
    required super.body,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot commentDoc, UserModel user) {
    final data = commentDoc.data() as Map<String, dynamic>;

    return CommentModel(
      id: commentDoc.id,
      postId: commentDoc[CommentApiMap.kPostId] as String,
      user: user,
      body: commentDoc[CommentApiMap.kBody] as String,
      createdAt: parseTimestamp(data[kCreatedAt]),
      updatedAt: parseTimestamp(data[kUpdatedAt]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      CommentApiMap.kId: id,
      CommentApiMap.kPostId: postId,
      CommentApiMap.kUserId: user.id,
      CommentApiMap.kBody: body,
      kCreatedAt: Timestamp.fromDate(createdAt),
      kUpdatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  factory CommentModel.fromEntity(CommentEntity comment) {
    return CommentModel(
      id: comment.id,
      postId: comment.postId,
      user: UserModel.fromEntity(comment.user),
      body: comment.body,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
    );
  }

  @override
  CommentModel copyWith({
    String? id,
    String? postId,
    UserEntity? user,
    String? body,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      user: user ?? this.user,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
