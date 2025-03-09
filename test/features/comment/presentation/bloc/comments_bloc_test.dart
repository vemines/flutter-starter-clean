import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/comment/presentation/blocs/comment_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late CommentBloc bloc;
  late MockGetCommentsByPostIdUseCase mockGetCommentsByPostId;
  late MockAddCommentUseCase mockAddComment;
  late MockUpdateCommentUseCase mockUpdateComment;
  late MockDeleteCommentUseCase mockDeleteComment;
  late MockLogService mockLogService;

  setUp(() {
    mockGetCommentsByPostId = MockGetCommentsByPostIdUseCase();
    mockAddComment = MockAddCommentUseCase();
    mockUpdateComment = MockUpdateCommentUseCase();
    mockDeleteComment = MockDeleteCommentUseCase();
    mockLogService = MockLogService();

    bloc = CommentBloc(
      getCommentsByPostId: mockGetCommentsByPostId,
      addComment: mockAddComment,
      updateComment: mockUpdateComment,
      deleteComment: mockDeleteComment,
      logService: mockLogService,
    );
    registerFallbackValue(tGetCommentsParams);
    registerFallbackValue(tAddCommentParams);
    registerFallbackValue(tCommentEntity);
  });
  tearDown(() {
    bloc.close();
  });

  test('initialState should be CommentInitial', () {
    expect(bloc.state, equals(CommentInitial()));
  });

  group('GetCommentsEvent', () {
    blocTest<CommentBloc, CommentState>(
      'should emit [CommentsLoaded] when data is gotten successfully and change post',
      build: () {
        when(() => mockGetCommentsByPostId(any())).thenAnswer((_) async => Right(tCommentEntities));
        return bloc;
      },
      act: (bloc) => bloc.add(GetCommentsEvent(postId: tPostEntity.id)),
      expect: () => [CommentsLoaded(comments: tCommentEntities, hasMore: true)],
    );

    blocTest<CommentBloc, CommentState>(
      'should emit [CommentsLoaded] when data is gotten successfully and do not change current post',
      build: () {
        when(() => mockGetCommentsByPostId(any())).thenAnswer((_) async => Right(tCommentEntities));
        return bloc;
      },
      seed: () => CommentsLoaded(comments: tCommentEntities, hasMore: true),
      act: (bloc) => bloc.add(GetCommentsEvent(postId: tPostEntity.id)),
      expect:
          () => [
            CommentsLoaded(comments: [...tCommentEntities, ...tCommentEntities], hasMore: true),
          ],
    );

    blocTest<CommentBloc, CommentState>(
      'should emit [CommentError] when getting data fails',
      build: () {
        when(() => mockGetCommentsByPostId(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(GetCommentsEvent(postId: tPostEntity.id)),
      expect: () => [CommentError(failure: tServerFailure)],
    );
  });

  group('AddCommentEvent', () {
    blocTest<CommentBloc, CommentState>(
      'should emit [CommentsLoaded] with new comment at start of list on success',
      build: () {
        when(() => mockAddComment(any())).thenAnswer((_) async => Right(tCommentEntity));
        return bloc;
      },
      seed: () => CommentsLoaded(comments: [], hasMore: false),
      act:
          (bloc) => bloc.add(
            AddCommentEvent(postId: tPostEntity.id, userId: tUserEntity.id, body: 'Test Body'),
          ),
      expect:
          () => [
            CommentsLoaded(comments: [tCommentEntity], hasMore: false),
          ],
    );

    blocTest<CommentBloc, CommentState>(
      'should emit [CommentError] when adding comment fails',
      build: () {
        when(() => mockAddComment(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      seed: () => CommentsLoaded(comments: [], hasMore: false),
      act:
          (bloc) => bloc.add(
            AddCommentEvent(postId: tPostEntity.id, userId: tUserEntity.id, body: 'Test Body'),
          ),
      expect: () => [CommentError(failure: tServerFailure)],
    );
  });

  group('UpdateCommentEvent', () {
    final updatedComment = tCommentEntity.copyWith(body: 'Updated comment');
    final initialState = CommentsLoaded(comments: [tCommentEntity], hasMore: false);

    blocTest<CommentBloc, CommentState>(
      'should emit [CommentsLoaded] with updated comment when successful',
      build: () {
        when(() => mockUpdateComment(any())).thenAnswer((_) async => Right(updatedComment));
        return bloc;
      },
      seed: () => initialState,
      act: (bloc) => bloc.add(UpdateCommentEvent(comment: updatedComment)),
      expect:
          () => [
            CommentsLoaded(comments: [updatedComment], hasMore: false),
          ],
    );

    blocTest<CommentBloc, CommentState>(
      'should emit [CommentError] when updating comment fails',
      build: () {
        when(() => mockUpdateComment(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      seed: () => initialState,
      act: (bloc) => bloc.add(UpdateCommentEvent(comment: updatedComment)),
      expect: () => [CommentError(failure: tServerFailure)],
    );
  });

  group('DeleteCommentEvent', () {
    final initialState = CommentsLoaded(comments: [tCommentEntity], hasMore: true);

    blocTest<CommentBloc, CommentState>(
      'should emit [CommentsLoaded] with comment removed on success',
      build: () {
        when(() => mockDeleteComment(any())).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      seed: () => initialState,
      act: (bloc) => bloc.add(DeleteCommentEvent(comment: tCommentEntity)),
      expect: () => [CommentsLoaded(comments: [], hasMore: true)],
    );

    blocTest<CommentBloc, CommentState>(
      'should emit [CommentError] when deleting comment fails',
      build: () {
        when(() => mockDeleteComment(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      seed: () => initialState,
      act: (bloc) => bloc.add(DeleteCommentEvent(comment: tCommentEntity)),
      expect: () => [CommentError(failure: tServerFailure)],
    );
  });
}
