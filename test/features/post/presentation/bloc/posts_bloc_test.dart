import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/post/presentation/blocs/post_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late PostBloc bloc;
  late MockGetAllPostsUseCase mockGetAllPosts;
  late MockGetPostByIdUseCase mockGetPostById;
  late MockCreatePostUseCase mockCreatePost;
  late MockUpdatePostUseCase mockUpdatePost;
  late MockDeletePostUseCase mockDeletePost;
  late MockSearchPostsUseCase mockSearchPosts;
  late MockGetBookmarkedPostsUseCase mockGetBookmarkedPosts;
  late MockGetPostsByUserIdUseCase mockGetPostsByUserIdUseCase;
  late MockLogService mockLogService;

  setUp(() {
    mockGetAllPosts = MockGetAllPostsUseCase();
    mockGetPostById = MockGetPostByIdUseCase();
    mockCreatePost = MockCreatePostUseCase();
    mockUpdatePost = MockUpdatePostUseCase();
    mockDeletePost = MockDeletePostUseCase();
    mockSearchPosts = MockSearchPostsUseCase();
    mockGetBookmarkedPosts = MockGetBookmarkedPostsUseCase();
    mockGetPostsByUserIdUseCase = MockGetPostsByUserIdUseCase();
    mockLogService = MockLogService();

    bloc = PostBloc(
      getAllPosts: mockGetAllPosts,
      getPostById: mockGetPostById,
      createPost: mockCreatePost,
      updatePost: mockUpdatePost,
      deletePost: mockDeletePost,
      searchPosts: mockSearchPosts,
      getBookmarkedPosts: mockGetBookmarkedPosts,
      getPostsByUserIdUseCase: mockGetPostsByUserIdUseCase,
      logService: mockLogService,
    );

    registerFallbackValue(tPostEntity);
    registerFallbackValue(tPaginationParams);
    registerFallbackValue(tListBookmarkPostIdParams);
    registerFallbackValue(tPostIdParams);
    registerFallbackValue(tPaginationWithSearchParams);
    registerFallbackValue(tGetPostsByUserIdParams);
    registerFallbackValue(tCreatePostParams);
  });

  tearDown(() {
    bloc.close();
  });

  test('initialState should be PostInitial', () {
    expect(bloc.state, equals(PostInitial()));
  });

  group('GetAllPostsEvent', () {
    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostLoaded] on success',
      build: () {
        when(() => mockGetAllPosts(any())).thenAnswer((_) async => Right(tPostEntities));
        return bloc;
      },
      act: (bloc) => bloc.add(GetAllPostsEvent()),
      expect: () => [PostsLoaded(posts: tPostEntities, hasMore: false)],
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostLoaded] with hasMore false when empty list',
      build: () {
        when(() => mockGetAllPosts(any())).thenAnswer((_) async => Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(GetAllPostsEvent()),
      expect: () => [PostsLoaded(posts: [], hasMore: false)],
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostError] on failure',
      build: () {
        when(() => mockGetAllPosts(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(GetAllPostsEvent()),
      expect: () => [PostError(failure: tServerFailure)],
    );
  });

  group('GetPostsByUserIdEvent', () {
    final tPosts = [tPostEntity, tPostEntity];

    blocTest<PostBloc, PostState>(
      'should emit [PostsLoaded] with user posts when successful',
      build: () {
        when(() => mockGetPostsByUserIdUseCase(any())).thenAnswer((_) async => Right(tPosts));
        return bloc;
      },
      act: (bloc) => bloc.add(GetPostsByUserIdEvent(userId: 'user1')),
      expect: () => [PostsLoaded(posts: tPosts, hasMore: false)],
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostsLoaded] with when successful and do not change id',
      build: () {
        when(() => mockGetPostsByUserIdUseCase(any())).thenAnswer((_) async => Right(tPosts));
        return bloc;
      },
      seed: () => PostsLoaded(posts: tPosts, hasMore: true),
      act: (bloc) => bloc.add(GetPostsByUserIdEvent(userId: tGetPostsByUserIdParams.userId)),
      expect:
          () => [
            PostsLoaded(posts: [...tPosts, ...tPosts], hasMore: false),
          ],
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostError] when getting user posts fails',
      build: () {
        when(
          () => mockGetPostsByUserIdUseCase(any()),
        ).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(GetPostsByUserIdEvent(userId: 'user1')),
      expect: () => [PostError(failure: tServerFailure)],
    );
  });

  group('GetPostByIdEvent', () {
    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostLoaded] on success',
      build: () {
        when(() => mockGetPostById(any())).thenAnswer((_) async => Right(tPostEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(GetPostByIdEvent(id: tPostEntity.id)),
      expect: () => [PostLoading(), PostLoaded(post: tPostEntity)],
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostError] on failure',
      build: () {
        when(() => mockGetPostById(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(GetPostByIdEvent(id: tPostEntity.id)),
      expect: () => [PostLoading(), PostError(failure: tServerFailure)],
    );
  });

  group('CreatePostEvent', () {
    blocTest<PostBloc, PostState>(
      'should emit [PostsLoaded] with the new post at the start when successful',
      build: () {
        when(() => mockCreatePost(any())).thenAnswer((_) async => Right(tPostEntity));
        return bloc;
      },
      seed: () => PostsLoaded(posts: [], hasMore: false),
      act: (bloc) => bloc.add(CreatePostEvent(params: tCreatePostParams)),
      expect:
          () => [
            PostsLoaded(posts: [tPostEntity], hasMore: false),
          ],
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostError] on failure',
      build: () {
        when(() => mockCreatePost(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      seed: () => PostsLoaded(posts: [], hasMore: false),
      act: (bloc) => bloc.add(CreatePostEvent(params: tCreatePostParams)),
      expect: () => [PostError(failure: tServerFailure)],
    );
  });

  group('UpdatePostEvent', () {
    final updatedPost = tPostEntity.copyWith(title: 'Updated Title');
    final initialState = PostsLoaded(posts: [tPostEntity], hasMore: false);

    blocTest<PostBloc, PostState>(
      'should emit [PostsLoaded] with updated post when successful',
      build: () {
        when(() => mockUpdatePost(any())).thenAnswer((_) async => Right(updatedPost));
        return bloc;
      },
      seed: () => initialState,
      act: (bloc) => bloc.add(UpdatePostEvent(post: updatedPost)),
      expect:
          () => [
            PostsLoaded(posts: [updatedPost], hasMore: false),
          ],
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostError] when updating post fails',
      build: () {
        when(() => mockUpdatePost(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      seed: () => initialState,
      act: (bloc) => bloc.add(UpdatePostEvent(post: tPostEntity)),
      expect: () => [PostError(failure: tServerFailure)],
    );
  });

  group('DeletePostEvent', () {
    final initialState = PostsLoaded(posts: [tPostEntity], hasMore: true);

    blocTest<PostBloc, PostState>(
      'should emit [PostsLoaded] with post removed when successful',
      build: () {
        when(() => mockDeletePost(any())).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      seed: () => initialState,
      act: (bloc) => bloc.add(DeletePostEvent(post: tPostEntity)),
      expect: () => [PostsLoaded(posts: [], hasMore: true)],
    );
    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostError] on failure',
      build: () {
        when(() => mockDeletePost(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      seed: () => initialState,
      act: (bloc) => bloc.add(DeletePostEvent(post: tPostEntity)),
      expect: () => [PostError(failure: tServerFailure)],
    );
  });

  group('SearchPostsEvent', () {
    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostLoaded] on success',
      build: () {
        when(() => mockSearchPosts(any())).thenAnswer((_) async => Right(tPostEntities));
        return bloc;
      },
      act: (bloc) => bloc.add(SearchPostsEvent(query: tQuery)),
      expect:
          () => [
            PostsLoaded(posts: [], hasMore: true),
            PostsLoaded(posts: tPostEntities, hasMore: false),
          ],
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostLoaded] with hasMore false when empty list',
      build: () {
        when(() => mockSearchPosts(any())).thenAnswer((_) async => Right([]));
        return bloc;
      },
      act: (bloc) => bloc.add(SearchPostsEvent(query: tQuery)),
      expect: () => [PostsLoaded(posts: [], hasMore: true), PostsLoaded(posts: [], hasMore: false)],
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostError] on failure',
      build: () {
        when(() => mockSearchPosts(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(SearchPostsEvent(query: tQuery)),
      expect: () => [PostsLoaded(posts: [], hasMore: true), PostError(failure: tServerFailure)],
    );
  });

  group('GetBookmarkedPostsEvent', () {
    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostLoaded] on success',
      build: () {
        when(() => mockGetBookmarkedPosts(any())).thenAnswer((_) async => Right(tPostEntities));
        return bloc;
      },
      act: (bloc) => bloc.add(GetBookmarkedPostsEvent(bookmarksId: tUserEntity.bookmarksId)),
      expect: () => [PostsLoaded(posts: tPostEntities, hasMore: false)],
    );

    blocTest<PostBloc, PostState>(
      'should emit [PostLoading, PostError] on failure',
      build: () {
        when(() => mockGetBookmarkedPosts(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(GetBookmarkedPostsEvent(bookmarksId: tUserEntity.bookmarksId)),
      expect: () => [PostError(failure: tServerFailure)],
    );
  });
}
