import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/locale.dart';
import '../../../../app/routes.dart';
import '../../../../core/extensions/scroll_controller.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../injection_container.dart';
import '../blocs/post_bloc.dart';
import '../widgets/list_post.dart';

class PostListPage extends StatefulWidget {
  const PostListPage({super.key});

  @override
  State<PostListPage> createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  final ScrollController _scrollController = ScrollController();
  late PostBloc _bloc;
  bool _loadingPosts = false;

  @override
  void initState() {
    super.initState();
    _bloc = sl<PostBloc>()..add(GetAllPostsEvent());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingPosts) return;

    if (_scrollController.isBottom) {
      _loadingPosts = true;
      _bloc.add(GetAllPostsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr(I18nKeys.posts)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              context.push(Paths.bookmarkedPost);
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: safeWrapContainer(
        context,
        _scrollController,
        BlocProvider<PostBloc>(
          create: (_) => _bloc,
          child: BlocBuilder<PostBloc, PostState>(
            builder: (_, state) {
              if (state is PostInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PostError) {
                return Center(child: Text(state.failure.message.toString()));
              } else if (state is PostsLoaded) {
                _loadingPosts = false;
                return ListPostWidget(state.posts, state.hasMore);
              }
              return Center(child: Text('Unknown State: $state'));
            },
          ),
        ),
      ),
    );
  }
}
