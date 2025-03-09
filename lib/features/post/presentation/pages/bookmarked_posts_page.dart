import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/locale.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../user/presentation/blocs/user_bloc.dart';
import '../blocs/post_bloc.dart';
import '../widgets/list_post.dart';

class BookmarkedPostsPage extends StatefulWidget {
  const BookmarkedPostsPage({super.key});

  @override
  State<BookmarkedPostsPage> createState() => _BookmarkedPostsPageState();
}

class _BookmarkedPostsPageState extends State<BookmarkedPostsPage> {
  late PostBloc _postBloc;
  late UserBloc _userBloc;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _postBloc = sl<PostBloc>();
    _userBloc =
        sl<UserBloc>()..add(GetUserByIdEvent(id: (sl<AuthBloc>().state as AuthLoaded).auth.id));

    _loadBookmarkedPost();
  }

  @override
  void dispose() {
    _postBloc.close();
    _userBloc.close();
    super.dispose();
  }

  void _loadBookmarkedPost() {
    if (_userBloc.state is UserLoaded) {
      final bookmarkPostIds = (_userBloc.state as UserLoaded).user.bookmarksId;
      _postBloc.add(GetBookmarkedPostsEvent(bookmarksId: bookmarkPostIds));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>(create: (_) => _postBloc),
        BlocProvider<UserBloc>(create: (_) => _userBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.tr(I18nKeys.bookmarkedPosts)),
          centerTitle: true,
        ), //ADD Translate
        body: safeWrapContainer(
          context,
          _scrollController,
          hasBottomBar: false,
          BlocBuilder<UserBloc, UserState>(
            builder: (_, userState) {
              if (userState is UserInitial || userState is UserLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (userState is UserError) {
                return Center(child: Text('Error (Post): ${userState.failure.message}'));
              } else if (userState is! UserLoaded) {
                return Center(child: Text('Unknown User State: $userState'));
              }
              _loadBookmarkedPost();

              return BlocBuilder<PostBloc, PostState>(
                builder: (_, postState) {
                  if (postState is PostInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (postState is PostError) {
                    return Center(child: Text('Error (Post): ${postState.failure.message}'));
                  } else if (postState is PostsLoaded) {
                    final bookmarkedPosts = postState.posts;
                    return bookmarkedPosts.isEmpty
                        ? Center(child: Text(context.tr(I18nKeys.noBookmarkedPosts)))
                        : ListPostWidget(bookmarkedPosts, postState.hasMore);
                  } else {
                    return Center(child: Text('Unknown Post State: $postState'));
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
