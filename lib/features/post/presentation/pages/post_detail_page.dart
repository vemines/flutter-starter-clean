import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/locale.dart';
import '../../../../core/extensions/build_content_extensions.dart';
import '../../../../core/extensions/scroll_controller.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/widgets/has_more_incaditor.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../core/widgets/post_item.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../comment/domain/entities/comment_entity.dart';
import '../../../comment/presentation/blocs/comment_bloc.dart';
import '../../../user/presentation/blocs/user_bloc.dart';
import '../blocs/post_bloc.dart';
import '../widgets/comment_item.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  const PostDetailPage({super.key, required this.postId});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _comment = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late PostBloc _postBloc;
  late CommentBloc _commentBloc;
  late UserBloc _userBloc;
  bool _loadingComments = false;
  bool _hasMoreComments = true;

  @override
  void initState() {
    super.initState();
    _postBloc = sl<PostBloc>()..add(GetPostByIdEvent(id: widget.postId));
    _commentBloc = sl<CommentBloc>()..add(GetCommentsEvent(postId: widget.postId));
    _userBloc =
        sl<UserBloc>()..add(GetUserByIdEvent(id: (sl<AuthBloc>().state as AuthLoaded).auth.id));
    _scrollController.addListener(_onScroll);
    _bookmarkStatus();
  }

  @override
  void dispose() {
    _comment.dispose();
    _scrollController.dispose();
    _postBloc.close();
    _commentBloc.close();
    _userBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>(create: (_) => _postBloc),
        BlocProvider<CommentBloc>(create: (_) => _commentBloc),
        BlocProvider<UserBloc>(create: (_) => _userBloc),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(context.tr(I18nKeys.postDetail)), centerTitle: true),
        body: safeWrapContainer(
          context,
          _scrollController,
          border: Border.all(color: context.colorScheme.outline),
          BlocBuilder<PostBloc, PostState>(
            builder: (_, postState) {
              if (postState is PostInitial || postState is PostLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (postState is PostError) {
                return Center(child: Text('Error: ${postState.failure.message}'));
              } else if (postState is PostLoaded) {
                final post = postState.post;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // PostItem(post: post, isDetail: true, key: post.key),
                    PostItem(post: post, isDetail: true),

                    BlocBuilder<CommentBloc, CommentState>(
                      builder: (_, commentState) {
                        if (commentState is CommentInitial) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (commentState is CommentError) {
                          return Center(child: Text('Error: ${commentState.failure.message}'));
                        } else if (commentState is CommentsLoaded) {
                          _loadingComments = false;
                          _hasMoreComments = commentState.hasMore;
                          return _buildCommentsSection(commentState.comments, commentState.hasMore);
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _bookmarkPost,
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              if (state is UserLoaded && _bookmarkStatus()) {
                return Icon(Icons.bookmark);
              }
              return Icon(Icons.bookmark_outline);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCommentsSection(List<CommentEntity> listComment, bool hasMore) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(I18nKeys.comments),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          16.sbH(),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoaded) {
                final currentUser = state.auth;
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _comment,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: context.tr(I18nKeys.addAComment),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // Pass the user ID to the _addComment function.
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _addComment(currentUser.id),
                    ),
                  ],
                );
              } else {
                return Center(child: Text(context.tr(I18nKeys.loginToAddComments)));
              }
            },
          ),
          16.sbH(),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: listComment.length + 1,
            itemBuilder: (context, index) {
              if (index < listComment.length) {
                final comment = listComment[index];
                // Check if the current user is the author of the comment
                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (_, authState) {
                    bool isMyComment = false;
                    if (authState is AuthLoaded) {
                      isMyComment = comment.user.id == authState.auth.id;
                    }

                    return CommentItem(
                      key: ValueKey('comment-${comment.id}'),
                      comment: comment,
                      isMyComment: isMyComment,
                      onEdit: () => _showEditDialog(comment),
                      onDelete: () => _showDeleteDialog(comment),
                    );
                  },
                );
              } else {
                return hasMoreWidget(context, hasMore);
              }
            },
          ),
        ],
      ),
    );
  }

  void _onScroll() {
    if (_loadingComments) return;
    if (!_hasMoreComments) return;

    if (_scrollController.isBottom) {
      _loadingComments = true;
      _commentBloc.add(GetCommentsEvent(postId: widget.postId));
    }
  }

  void _addComment(String userId) {
    if (_comment.text.trim().isNotEmpty) {
      _commentBloc.add(AddCommentEvent(postId: widget.postId, userId: userId, body: _comment.text));
      _comment.clear();
    }
  }

  void _showEditDialog(CommentEntity comment) {
    String editedComment = comment.body;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr(I18nKeys.editComment)),
          content: SizedBox(
            width: 500,
            child: TextFormField(
              initialValue: editedComment,
              maxLines: 4,
              decoration: InputDecoration(hintText: context.tr(I18nKeys.updateYourComment)),
              onChanged: (value) {
                editedComment = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr(I18nKeys.cancel)),
            ),
            TextButton(
              onPressed: () {
                _commentBloc.add(
                  UpdateCommentEvent(comment: comment.copyWith(body: editedComment)),
                );
                Navigator.of(context).pop();
              },
              child: Text(context.tr(I18nKeys.updateComment)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(CommentEntity comment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr(I18nKeys.deleteComment)),
          content: SizedBox(width: 500, child: Text(context.tr(I18nKeys.deleteCommentConfirm))),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr(I18nKeys.cancel)),
            ),
            TextButton(
              onPressed: () {
                _commentBloc.add(DeleteCommentEvent(comment: comment));
                Navigator.of(context).pop();
              },
              child: Text(context.tr(I18nKeys.deleteCommentConfirmAction)),
            ),
          ],
        );
      },
    );
  }

  void _bookmarkPost() {
    if (_userBloc.state is UserLoaded) {
      final user = (_userBloc.state as UserLoaded).user;
      _userBloc.add(
        BookmarkPostEvent(
          userId: user.id,
          postId: widget.postId,
          bookmarkedPostIds: user.bookmarksId,
        ),
      );
    }
  }

  bool _bookmarkStatus() {
    if (_userBloc.state is UserLoaded) {
      return (_userBloc.state as UserLoaded).user.bookmarksId.contains(widget.postId);
    }
    return false;
  }
}
