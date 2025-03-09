part of 'post_bloc.dart';

abstract class PostState extends Equatable {
  const PostState();

  @override
  List<Object> get props => [];
}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostsLoaded extends PostState {
  final List<PostEntity> posts;
  final bool hasMore;
  const PostsLoaded({required this.posts, required this.hasMore});
  @override
  List<Object> get props => [posts, hasMore];

  PostsLoaded copyWith({List<PostEntity>? posts, bool? hasMore, bool isInsert = false}) {
    return PostsLoaded(
      posts:
          posts != null
              ? isInsert
                  ? [...posts, ...this.posts]
                  : [...this.posts, ...posts]
              : this.posts,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class PostLoaded extends PostState {
  final PostEntity post;
  const PostLoaded({required this.post});
  @override
  List<Object> get props => [post];
}

class PostError extends PostState {
  final Failure failure;
  const PostError({required this.failure});
  @override
  List<Object> get props => [failure];
}
