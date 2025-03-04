import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/locale.dart';
import '../../../../core/extensions/num_extension.dart';
import '../../../../core/extensions/scroll_controller.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../../../post/domain/entities/post_entity.dart';
import '../../../post/domain/usecases/create_post_usecase.dart';
import '../../../post/presentation/blocs/post_bloc.dart';
import '../../../post/presentation/widgets/list_post.dart';
import '../../domain/entities/user_detail_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../blocs/user_bloc.dart';
import '../blocs/user_detail_bloc.dart';
import '../widgets/user_profile.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _fullname = TextEditingController();
  final _aboutMe = TextEditingController();
  final _email = TextEditingController();

  late UserBloc _userBloc;
  late UserDetailBloc _userDetailBloc;
  late PostBloc _postBloc;
  final ScrollController _scrollController = ScrollController();

  final _title = TextEditingController();
  final _body = TextEditingController();

  bool _isLoading = false;
  bool _hasMorePost = true;
  String _postsNum = '0';
  String _commentsNum = '0';
  String _friendsNum = '0';

  @override
  void initState() {
    super.initState();
    _userBloc = sl<UserBloc>()..add(GetUserByIdEvent(id: widget.userId));
    _userDetailBloc = sl<UserDetailBloc>();
    _postBloc = sl<PostBloc>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _fullname.dispose();
    _email.dispose();
    _aboutMe.dispose();

    _title.dispose();
    _body.dispose();

    _userBloc.close();
    _userDetailBloc.close();
    _postBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _isMyProfile()
              ? AppBar(
                title: Text(context.tr(I18nKeys.myProfile)),
                centerTitle: true,
                actions: [IconButton(icon: Icon(Icons.edit), onPressed: _showUpdateUserDialog)],
              )
              : AppBar(title: Text(context.tr(I18nKeys.userProfile)), centerTitle: true),
      body: safeWrapContainer(
        context,
        _scrollController,
        MultiBlocProvider(
          providers: [
            BlocProvider<UserBloc>(create: (BuildContext context) => _userBloc),
            BlocProvider<PostBloc>(create: (BuildContext context) => _postBloc),
            BlocProvider<UserDetailBloc>(create: (BuildContext context) => _userDetailBloc),
          ],
          child: BlocBuilder<UserBloc, UserState>(
            bloc: _userBloc,
            builder: (_, userState) {
              if (userState is UserLoading || userState is UserInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (userState is UserError) {
                return Center(child: Text('Error: ${userState.failure.message}'));
              } else if (userState is UserLoaded) {
                final user = userState.user;
                _loadingDetailsAndPost(user.id);
                _updateUserInputController(user);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserProfile(context, user),
                    BlocListener(
                      bloc: _userDetailBloc,
                      listener: (_, userDetailState) {
                        if (userDetailState is UserDetailLoaded) {
                          UserDetailEntity userDetail = userDetailState.userDetail;

                          setState(() {
                            _postsNum = userDetail.posts.toShortString;
                            _commentsNum = userDetail.comments.toShortString;
                            _friendsNum = userDetail.friends.toShortString;
                          });
                        }
                      },
                      child: Center(
                        child: SizedBox(
                          width: 350,
                          height: 100,
                          child: Column(
                            children: [
                              Expanded(
                                child: _buildStatusRow(
                                  context,
                                  posts: 'Posts',
                                  comments: 'Comments',
                                  friends: 'Friends',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              Divider(height: 2),
                              Expanded(
                                child: _buildStatusRow(
                                  context,
                                  posts: _postsNum,
                                  comments: _commentsNum,
                                  friends: _friendsNum,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildUserDetail(user),
                    BlocBuilder<PostBloc, PostState>(
                      builder: (_, postState) {
                        if (postState is PostInitial) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (postState is PostError) {
                          return Center(child: Text('Error: ${postState.failure.message}'));
                        } else if (postState is PostsLoaded) {
                          _isLoading = false;
                          _hasMorePost = postState.hasMore;
                          return ListPostWidget(
                            postState.posts,
                            postState.hasMore,
                            isEditable: _isMyProfile(),
                            onDeletePostCallback: _showDeletePostDialog,
                            onEditPostCallback: _showPostDialog,
                          );
                        }
                        return Center(child: Text('Unknow Post State: $postState'));
                      },
                    ),
                  ],
                );
              }
              return Center(child: Text('Unknow User State: $userState'));
            },
          ),
        ),
      ),
      floatingActionButton:
          _isMyProfile()
              ? FloatingActionButton(
                onPressed: () => _showPostDialog(null),
                tooltip: 'Create Post',
                child: Icon(Icons.add),
              )
              : null,
    );
  }

  void _onScroll() {
    if (_isLoading) return;
    if (!_hasMorePost) return;

    if (_scrollController.isBottom &&
        _userBloc.state is UserLoaded &&
        _postBloc.state is PostsLoaded) {
      _isLoading = true;
      _postBloc.add(GetPostsByUserIdEvent(userId: (_userBloc.state as UserLoaded).user.id));
    }
  }

  void _showDeletePostDialog(PostEntity post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: SizedBox(
            width: 500,
            child: Text(
              'Are you sure you want to delete this post?\nPost: ${post.id} -- ${post.title}',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                _postBloc.add(DeletePostEvent(post: post));
                Navigator.of(context).pop();
              },
              child: const Text('Delete Post'),
            ),
          ],
        );
      },
    );
  }

  void _showPostDialog(PostEntity? post) {
    bool isCreate = post == null;

    if (isCreate) {
      _title.text = '';
      _body.text = '';
    } else {
      _title.text = post.title;
      _body.text = post.body;
    }
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isCreate ? 'Create Post' : 'Update Post'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  maxLines: 1,
                  decoration: const InputDecoration(label: Text('Post Title')),
                ),
                16.sbH(),
                TextFormField(
                  controller: _body,
                  maxLines: 4,
                  decoration: const InputDecoration(label: Text('Post Body')),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (_userBloc.state is UserLoaded) {
                  final userId = (_userBloc.state as UserLoaded).user.id;
                  if (isCreate) {
                    _postBloc.add(
                      CreatePostEvent(
                        params: CreatePostParams(
                          userId: userId,
                          title: _title.text,
                          body: _body.text,
                        ),
                      ),
                    );
                    _userDetailBloc.add(GetUserDetailEvent(userId: userId));
                    _loadingDetailsAndPost(userId);
                  } else {
                    PostEntity updatedPost = post.copyWith(body: _body.text, title: _title.text);
                    _postBloc.add(UpdatePostEvent(post: updatedPost));
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text(isCreate ? 'Create Post' : 'Update Post'),
            ),
          ],
        );
      },
    );
  }

  bool _isMyProfile() {
    final userId = (sl<AuthBloc>().state as AuthLoaded).auth.id;
    if (userId == widget.userId) return true;
    return false;
  }

  void _loadingDetailsAndPost(String userId) {
    if (_isLoading) return;
    if (!_hasMorePost) return;
    _isLoading = true;
    _hasMorePost = false;

    _postBloc.add(GetPostsByUserIdEvent(userId: userId));
    _userDetailBloc.add(GetUserDetailEvent(userId: userId));
  }

  void _updateUserInputController(UserEntity user) {
    _aboutMe.text = user.about;
    _fullname.text = user.fullName;
    _email.text = user.email;
  }

  void _showUpdateUserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update User'),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fullname,
                  decoration: const InputDecoration(
                    hintText: 'Update your Fullname',
                    label: Text('Fullname'),
                  ),
                ),
                16.sbH(),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    hintText: 'Update your Email',
                    label: Text('Email'),
                  ),
                ),
                16.sbH(),
                TextFormField(
                  controller: _aboutMe,
                  decoration: const InputDecoration(
                    hintText: 'Update About Me',
                    label: Text('About Me'),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (_userBloc.state is UserLoaded) {
                  final user = (_userBloc.state as UserLoaded).user;
                  final updatedUser = user.copyWith(
                    email: _email.text,
                    fullName: _fullname.text,
                    about: _aboutMe.text,
                  );
                  _userBloc.add(UpdateUserEvent(user: updatedUser));
                }
                Navigator.of(context).pop();
              },
              child: const Text('Update User'),
            ),
          ],
        );
      },
    );
  }

  Row _buildStatusRow(
    BuildContext context, {
    required String posts,
    required String comments,
    required String friends,
    required TextStyle style,
  }) {
    final dividerColor = Theme.of(context).dividerColor;
    return Row(
      children: [
        Expanded(child: Center(child: Text(posts, style: TextStyle(fontSize: 16)))),
        Container(width: 1, height: 50, color: dividerColor),
        Expanded(child: Center(child: Text(comments, style: TextStyle(fontSize: 16)))),
        Container(width: 1, height: 50, color: dividerColor),
        Expanded(child: Center(child: Text(friends, style: TextStyle(fontSize: 16)))),
      ],
    );
  }

  Padding _buildUserDetail(UserEntity user) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About me', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          SizedBox(height: 10),
          Text(user.about),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.email),
              SizedBox(width: 10),
              Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 20),
              Text(user.email),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.calendar_month),
              SizedBox(width: 10),
              Text('Date Create:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 20),
              Text(user.createdAt.toIso8601String()),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.update),
              SizedBox(width: 10),
              Text('Lastest update:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 20),
              Text(user.updatedAt.toIso8601String()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, UserEntity user) {
    return SizedBox(
      height: 400, // Adjust overall height as needed
      child: Stack(
        children: [
          // Cover image
          UserProfile(user: user, isDetail: true),

          Positioned(
            top: 330,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                user.fullName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
