import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/api_mapping.dart';
import '../../../../core/utils/timestamp_util.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.avatar,
    required super.bookmarksId,
    required super.friendsId,
    required super.cover,
    required super.about,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[UserApiMap.kId] as String,
      fullName: json[UserApiMap.kFullName] as String,
      email: json[UserApiMap.kEmail] as String,
      avatar: json[UserApiMap.kAvatar] as String,
      cover: json[UserApiMap.kCover] as String,
      about: json[UserApiMap.kAbout] as String,
      bookmarksId:
          (json[UserApiMap.kBookmarksId] as List<dynamic>).map((e) => e.toString()).toList(),
      friendsId: (json[UserApiMap.kFriendIds] as List<dynamic>).map((e) => e.toString()).toList(),
      createdAt: DateTime.parse(json[kCreatedAt] as String),
      updatedAt: DateTime.parse(json[kUpdatedAt] as String),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      fullName: data[UserApiMap.kFullName] as String,
      email: data[UserApiMap.kEmail] as String,
      avatar: data[UserApiMap.kAvatar] as String,
      cover: data[UserApiMap.kCover] as String,
      about: data[UserApiMap.kAbout] as String,
      bookmarksId:
          (data[UserApiMap.kBookmarksId] as List<dynamic>).map((e) => e.toString()).toList(),
      friendsId: (data[UserApiMap.kFriendIds] as List<dynamic>).map((e) => e.toString()).toList(),
      createdAt: parseTimestamp(data[kCreatedAt]),
      updatedAt: parseTimestamp(data[kUpdatedAt]),
    );
  }

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      avatar: user.avatar,
      cover: user.cover,
      bookmarksId: user.bookmarksId,
      friendsId: user.friendsId,
      about: user.about,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  factory UserModel.newUser({required String id, required String fullName, required String email}) {
    return UserModel(
      id: id,
      fullName: fullName,
      email: email,
      avatar: 'https://picsum.photos/300/300?random=$id',
      cover: 'https://picsum.photos/800/450?random=$id',
      about: 'About me',
      bookmarksId: [],
      friendsId: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toFirebaseDoc() {
    return {
      UserApiMap.kId: id,
      UserApiMap.kFullName: fullName,
      UserApiMap.kEmail: email,
      UserApiMap.kAvatar: avatar,
      UserApiMap.kCover: cover,
      UserApiMap.kBookmarksId: bookmarksId,
      UserApiMap.kFriendIds: friendsId,
      UserApiMap.kAbout: about,
      kCreatedAt: Timestamp.fromDate(createdAt),
      kUpdatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      UserApiMap.kId: id,
      UserApiMap.kFullName: fullName,
      UserApiMap.kEmail: email,
      UserApiMap.kAvatar: avatar,
      UserApiMap.kCover: cover,
      UserApiMap.kBookmarksId: bookmarksId,
      UserApiMap.kFriendIds: friendsId,
      UserApiMap.kAbout: about,
      kCreatedAt: createdAt.toIso8601String(),
      kUpdatedAt: updatedAt.toIso8601String(),
    };
  }

  @override
  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? avatar,
    String? cover,
    String? about,
    List<String>? bookmarksId,
    List<String>? friendsId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      cover: cover ?? this.cover,
      about: about ?? this.about,
      bookmarksId: bookmarksId ?? this.bookmarksId,
      friendsId: friendsId ?? this.friendsId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
