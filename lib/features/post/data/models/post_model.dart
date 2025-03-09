import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/api_mapping.dart';
import '../../../../core/utils/timestamp_util.dart';
import '../../domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.imageUrl,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PostModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PostModel(
      id: doc.id,
      userId: data[PostApiMap.kUserId] as String,
      title: data[PostApiMap.kTitle] as String,
      body: data[PostApiMap.kBody] as String,
      imageUrl: data[PostApiMap.kImageUrl] as String,
      createdAt: parseTimestamp(data[kCreatedAt]),
      updatedAt: parseTimestamp(data[kUpdatedAt]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      PostApiMap.kId: id,
      PostApiMap.kUserId: userId,
      PostApiMap.kTitle: title,
      PostApiMap.kBody: body,
      PostApiMap.kImageUrl: imageUrl,
      kCreatedAt: Timestamp.fromDate(createdAt),
      kUpdatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  factory PostModel.fromEntity(PostEntity post) {
    return PostModel(
      id: post.id,
      userId: post.userId,
      title: post.title,
      body: post.body,
      imageUrl: post.imageUrl,
      createdAt: post.createdAt,
      updatedAt: post.updatedAt,
    );
  }

  @override
  PostModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory PostModel.fromHit(Hit hit) {
    return PostModel(
      id: hit.objectID,
      userId: hit['userId'] as String,
      title: hit['title'] as String,
      body: hit['body'] as String,
      imageUrl: hit['imageUrl'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch((hit['createdAt'] as int) * 1000),
      updatedAt: DateTime.fromMillisecondsSinceEpoch((hit['updatedAt'] as int) * 1000),
    );
  }
}
