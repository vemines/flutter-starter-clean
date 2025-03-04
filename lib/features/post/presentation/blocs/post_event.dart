part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();

  @override
  List<Object> get props => [];
}

class GetAllPostsEvent extends PostEvent {}

class GetPostsByUserIdEvent extends PostEvent {
  final String userId;
  const GetPostsByUserIdEvent({required this.userId});
  @override
  List<Object> get props => [userId];
}

class GetPostByIdEvent extends PostEvent {
  final String id;
  const GetPostByIdEvent({required this.id});
  @override
  List<Object> get props => [id];
}

class CreatePostEvent extends PostEvent {
  final CreatePostParams params;
  const CreatePostEvent({required this.params});
  @override
  List<Object> get props => [params];
}

class UpdatePostEvent extends PostEvent {
  final PostEntity post;
  const UpdatePostEvent({required this.post});
  @override
  List<Object> get props => [post];
}

class DeletePostEvent extends PostEvent {
  final PostEntity post;
  const DeletePostEvent({required this.post});
  @override
  List<Object> get props => [post];
}

class SearchPostsEvent extends PostEvent {
  final String query;
  const SearchPostsEvent({required this.query});
  @override
  List<Object> get props => [query];
}

class GetBookmarkedPostsEvent extends PostEvent {
  final List<String> bookmarksId;
  const GetBookmarkedPostsEvent({required this.bookmarksId});

  @override
  List<Object> get props => [bookmarksId];
}

//
