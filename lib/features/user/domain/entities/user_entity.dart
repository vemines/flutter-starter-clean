import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String fullName;
  final String email;
  final String avatar;
  final String cover;
  final String about;
  final List<String> bookmarksId;
  final List<String> friendsId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    required this.avatar,
    required this.bookmarksId,
    required this.friendsId,
    required this.cover,
    required this.about,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, fullName, email, avatar, bookmarksId, friendsId, cover, about];

  UserEntity copyWith({
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
    return UserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      cover: avatar ?? this.cover,
      bookmarksId: bookmarksId ?? this.bookmarksId,
      friendsId: friendsId ?? this.friendsId,
      about: about ?? this.about,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
