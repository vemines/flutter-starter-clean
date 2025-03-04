import '../../../../core/constants/api_mapping.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.fullName,
    required super.userName,
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
      userName: json[UserApiMap.kUserName] as String,
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

  factory UserModel.fromEntity(UserEntity user) {
    return UserModel(
      id: user.id,
      fullName: user.fullName,
      userName: user.userName,
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

  Map<String, dynamic> toJson() {
    return {
      UserApiMap.kId: id,
      UserApiMap.kFullName: fullName,
      UserApiMap.kUserName: userName,
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
    String? userName,
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
      userName: userName ?? this.userName,
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
