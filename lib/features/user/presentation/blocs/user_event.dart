part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetAllUsersEvent extends UserEvent {
  final String exclude;

  const GetAllUsersEvent({required this.exclude});
}

class GetUserByIdEvent extends UserEvent {
  final String id;

  const GetUserByIdEvent({required this.id});

  @override
  List<Object> get props => [id];
}

class UpdateUserEvent extends UserEvent {
  final UserEntity user;

  const UpdateUserEvent({required this.user});
  @override
  List<Object> get props => [user];
}

class UpdateFriendListEvent extends UserEvent {
  final String userId;
  final List<String> friendIds;
  const UpdateFriendListEvent({required this.userId, required this.friendIds});
  @override
  List<Object> get props => [userId, friendIds];
}

class BookmarkPostEvent extends UserEvent {
  final String userId;
  final String postId;
  final List<String> bookmarkedPostIds;

  const BookmarkPostEvent({
    required this.userId,
    required this.postId,
    required this.bookmarkedPostIds,
  });

  @override
  List<Object> get props => [userId, postId, bookmarkedPostIds];
}
