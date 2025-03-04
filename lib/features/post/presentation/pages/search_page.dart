import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/locale.dart';
import '../../../../core/extensions/scroll_controller.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../injection_container.dart';
import '../blocs/post_bloc.dart';
import '../widgets/list_post.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late PostBloc _bloc;
  bool _loadingPost = false;

  @override
  void initState() {
    _bloc = sl<PostBloc>();
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _search.dispose();
    _bloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_loadingPost) return;

    if (_scrollController.isBottom && _search.text.isNotEmpty) {
      _loadingPost = true;
      _bloc.add(SearchPostsEvent(query: _search.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(I18nKeys.search)), centerTitle: true),
      body: safeWrapContainer(
        context,
        _scrollController,
        BlocProvider<PostBloc>(
          create: (_) => _bloc,
          child: Column(
            children: [
              _buildSearchField(_bloc),
              BlocBuilder<PostBloc, PostState>(
                builder: (context, state) {
                  if (state is PostInitial) {
                    return Center(child: Text(context.tr(I18nKeys.enterSearchTerms)));
                  } else if (state is PostError) {
                    return Center(child: Text(state.failure.message.toString()));
                  } else if (state is PostsLoaded) {
                    _loadingPost = false;
                    return ListPostWidget(state.posts, state.hasMore);
                  }
                  return Center(child: Text('Unknown State: $state'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildSearchField(PostBloc bloc) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _search,
        decoration: InputDecoration(
          labelText: context.tr(I18nKeys.search),
          suffixIcon: IconButton(icon: const Icon(Icons.clear), onPressed: () => _search.clear()),
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            // Perform the search
            onPressed: () => bloc.add(SearchPostsEvent(query: _search.text)),
          ),
        ),
        onSubmitted: (value) => bloc.add(SearchPostsEvent(query: value)),
      ),
    );
  }
}
