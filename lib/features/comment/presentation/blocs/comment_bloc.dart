import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/logs.dart';
import '../../../../../core/constants/pagination.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/comment_entity.dart';
import '../../domain/usecases/add_comment_usecase.dart';
import '../../domain/usecases/delete_comment_usecase.dart';
import '../../domain/usecases/get_comments_by_post_id_usecase.dart';
import '../../domain/usecases/update_comment_usecase.dart';

part 'comment_event.dart';
part 'comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetCommentsByPostIdUseCase getCommentsByPostId;
  final AddCommentUseCase addComment;
  final UpdateCommentUseCase updateComment;
  final DeleteCommentUseCase deleteComment;
  final LogService logService;

  CommentBloc({
    required this.getCommentsByPostId,
    required this.addComment,
    required this.updateComment,
    required this.deleteComment,
    required this.logService,
  }) : super(CommentInitial()) {
    on<GetCommentsEvent>(_onGetComments);
    on<AddCommentEvent>(_onAddComment);
    on<UpdateCommentEvent>(_onUpdateComment);
    on<DeleteCommentEvent>(_onDeleteComment);
  }

  PaginationStorage _getCommentsPS = PaginationStorage().copyWith(limit: 2);
  String _currentPostId = '';

  void _onGetComments(GetCommentsEvent event, Emitter<CommentState> emit) async {
    if (_getCommentsPS.onProcess) return;
    _getCommentsPS.onProcess = true;
    try {
      if (event.postId != _currentPostId) {
        _getCommentsPS = PaginationStorage().copyWith(limit: 2);
      }
      _currentPostId = event.postId;

      final result = await getCommentsByPostId(
        GetCommentsParams(postId: event.postId, page: _getCommentsPS.currentPage, limit: 2),
      );

      result.fold(
        (failure) {
          logService.w(
            '$failure occur at _onGetComments(GetCommentsEvent event, Emitter<CommentState> emit)',
          );
          return emit(CommentError(failure: failure));
        },
        (comments) {
          _handleGetListComments(comments: comments, emit: emit, ps: _getCommentsPS);
        },
      );
    } finally {
      _getCommentsPS.onProcess = false;
    }
  }

  void _handleGetListComments({
    required List<CommentEntity> comments,
    required PaginationStorage ps,
    required Emitter<CommentState> emit,
  }) {
    if (comments.isEmpty) {
      ps.hasMore = false;
      if (state is CommentsLoaded) {
        emit((state as CommentsLoaded).copyWith(hasMore: false));
        return;
      } else {
        emit(CommentsLoaded(comments: [], hasMore: false));
        return;
      }
    }

    if (ps.currentPage == 1 && comments.length < ps.limit) ps.hasMore = false;
    ps.currentPage++;

    if (state is CommentsLoaded) {
      emit((state as CommentsLoaded).copyWith(comments: comments));
      return;
    } else {
      emit(CommentsLoaded(comments: comments, hasMore: ps.hasMore));
      return;
    }
  }

  void _onAddComment(AddCommentEvent event, Emitter<CommentState> emit) async {
    if (state is CommentsLoaded) {
      final result = await addComment(
        AddCommentParams(postId: event.postId, userId: event.userId, body: event.body),
      );

      result.fold(
        (failure) {
          logService.w(
            '$failure occur at _onAddComment(AddCommentEvent event, Emitter<CommentState> emit)',
          );
          emit(CommentError(failure: failure));
        },
        (comment) {
          if ((state as CommentsLoaded).comments.isEmpty) {
            emit(CommentsLoaded(hasMore: false, comments: [comment]));
            return;
          }
          emit((state as CommentsLoaded).copyWith(comments: [comment], isInsert: true));
        },
      );
    }
  }

  void _onUpdateComment(UpdateCommentEvent event, Emitter<CommentState> emit) async {
    final currentState = state;
    if (currentState is CommentsLoaded) {
      final result = await updateComment(event.comment);

      result.fold(
        (failure) {
          logService.w(
            '$failure occur at _onUpdateComment(UpdateCommentEvent event, Emitter<CommentState> emit)',
          );
          emit(CommentError(failure: failure));
        },
        (updatedComment) {
          final updatedComments =
              currentState.comments.map((comment) {
                return comment.id == updatedComment.id ? updatedComment : comment;
              }).toList();
          emit(CommentsLoaded(comments: updatedComments, hasMore: currentState.hasMore));
        },
      );
    }
  }

  void _onDeleteComment(DeleteCommentEvent event, Emitter<CommentState> emit) async {
    final currentState = state;
    if (currentState is CommentsLoaded) {
      final result = await deleteComment(event.comment);

      result.fold(
        (failure) {
          logService.w(
            '$failure occur at _onDeleteComment(DeleteCommentEvent event, Emitter<CommentState> emit)',
          );
          emit(CommentError(failure: failure));
        },
        (_) {
          final updatedComments =
              currentState.comments.where((comment) => comment.id != event.comment.id).toList();
          emit(CommentsLoaded(comments: updatedComments, hasMore: currentState.hasMore));
        },
      );
    }
  }
}
