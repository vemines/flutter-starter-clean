import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/locale.dart';
import '../../../../app/routes.dart';
import '../../../../core/extensions/build_content_extensions.dart';
import '../../../../core/extensions/num_extension.dart';
import '../../../../core/extensions/scroll_controller.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../core/widgets/has_more_incaditor.dart';
import '../../../../core/widgets/layout.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';
import '../blocs/user_bloc.dart';
import '../widgets/user_profile.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final ScrollController _scrollController = ScrollController();
  late UserBloc _userInfoBloc;
  late UserBloc _userListBloc;
  bool _isUpdatingFriendList = false;
  bool _isLoadingUserList = false;

  @override
  void initState() {
    super.initState();
    _userInfoBloc =
        sl<UserBloc>()..add(GetUserByIdEvent(id: (sl<AuthBloc>().state as AuthLoaded).auth.id));
    _userListBloc = sl<UserBloc>();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _userInfoBloc.close();
    _userListBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(I18nKeys.users)), centerTitle: true),
      body: safeWrapContainer(
        context,
        _scrollController,
        border: Border.all(color: context.colorScheme.outline),
        BlocProvider(
          create: (context) => _userInfoBloc,
          child: BlocBuilder<UserBloc, UserState>(
            builder: (_, userInfoState) {
              if (userInfoState is UserLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (userInfoState is UserError) {
                return Center(child: Text('Error: ${userInfoState.failure.message}'));
              } else if (userInfoState is UserLoaded) {
                _loadUserList();

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    UserProfile(user: userInfoState.user),
                    24.sbH(),

                    BlocProvider(
                      create: (context) => _userListBloc,
                      child: BlocBuilder<UserBloc, UserState>(
                        builder: (_, userListState) {
                          if (userListState is UserInitial) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (userListState is UserError) {
                            return Center(child: Text('Error: ${userListState.failure.message}'));
                          } else if (userListState is UsersLoaded) {
                            _isUpdatingFriendList = false;
                            _isLoadingUserList = false;

                            final hasMore = userListState.hasMore;

                            return _buildListUsers(hasMore, userListState, userInfoState, context);
                          } else {
                            return Center(child: Text('Unknown User List State: $userListState'));
                          }
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return Center(child: Text('Unknown User Info State: $userInfoState'));
              }
            },
          ),
        ),
      ),
    );
  }

  void _loadUserList() {
    if (_isLoadingUserList) return;
    _isLoadingUserList = true;

    if (_userInfoBloc.state is UserLoaded) {
      _userListBloc.add(GetAllUsersEvent(exclude: (_userInfoBloc.state as UserLoaded).user.id));
    }
  }

  void _onScroll() {
    if (_scrollController.isBottom && _userInfoBloc.state is UserLoaded) {
      _loadUserList();
    }
  }

  void _onAddFriend(String userId) {
    if (_isUpdatingFriendList) return;

    _isUpdatingFriendList = true;

    if (_userInfoBloc.state is UserLoaded) {
      final user = (_userInfoBloc.state as UserLoaded).user;
      final friendListId = List<String>.from(user.friendsId);
      if (friendListId.contains(userId)) {
        friendListId.remove(userId);
      } else {
        friendListId.add(userId);
      }
      _userInfoBloc.add(UpdateFriendListEvent(userId: user.id, friendIds: friendListId));
    }
  }

  ListView _buildListUsers(
    bool hasMore,
    UsersLoaded userListState,
    UserLoaded userInfoState,
    BuildContext context,
  ) {
    return ListView.separated(
      itemCount: userListState.users.length + 1,
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, index) {
        if (index == userListState.users.length) {
          return hasMoreWidget(context, hasMore);
        }

        final user = userListState.users[index];
        final isFriend = userInfoState.user.friendsId.contains(user.id);
        return ListTile(
          leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.avatar)),
          title: Text(user.fullName),
          subtitle: Text(user.email),
          onTap: () {
            context.push('${Paths.userProfile}/${user.id}');
          },
          trailing:
              isFriend
                  ? FilledButton(
                    onPressed: () => _onAddFriend(user.id),
                    child: Text(context.tr(I18nKeys.removeFriends)),
                  )
                  : ElevatedButton(
                    onPressed: () => _onAddFriend(user.id),
                    child: Text(context.tr(I18nKeys.addFriends)),
                  ),
        );
      },
      separatorBuilder: (_, _) => Padding(padding: 4.eiHori, child: Divider()),
    );
  }
}
