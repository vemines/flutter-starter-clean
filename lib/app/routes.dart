import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/pages/not_found_page.dart';
import '../features/blocs/auth/auth_bloc.dart';
import '../features/pages/auth/login_page.dart';
import '../features/pages/auth/register_page.dart';
import '../features/pages/post/bookmarked_posts_page.dart';
import '../features/pages/post/post_detail_page.dart';
import '../features/pages/home/home_page.dart';
import '../features/pages/user/user_profile_page.dart';
import '../injection_container.dart';

class Paths {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot_password';
  static const String settings = '/settings';
  static const String home = '/home';
  static const String bookmarkedPost = '/posts/bookmarked';

  // routes have params
  static const String userProfile = '/user_profile';
  static const String postDetail = '/post_detail';
}

final routes = GoRouter(
  initialLocation: sl<AuthBloc>().state is AuthLoaded ? Paths.home : Paths.login,
  redirect: (context, state) {
    List<String> exclude = [Paths.register];

    final authBloc = sl<AuthBloc>();
    if (authBloc.state is AuthInitial) authBloc.add(GetLoggedInUserEvent());
    final isAuthenticated = authBloc.state is AuthLoaded;

    if (exclude.contains(state.uri.path)) return null;

    final isLoginPage = state.uri.path == Paths.login;
    return isAuthenticated && !isLoginPage ? null : Paths.login;
  },
  routes: [
    GoRoute(
      path: '${Paths.postDetail}/:postId',
      builder: (context, state) {
        final postIdParameters = state.pathParameters['postId'];
        final postId = postIdParameters ?? '';
        if (postId.isEmpty) return NotFoundPage();

        return PostDetailPage(postId: postId);
      },
    ),
    GoRoute(
      path: Paths.bookmarkedPost,
      builder: (context, state) {
        return BookmarkedPostsPage();
      },
    ),
    GoRoute(path: Paths.login, builder: (context, state) => const LoginPage()),
    GoRoute(path: Paths.home, builder: (context, state) => const HomePage()),
    GoRoute(path: Paths.register, builder: (context, state) => const RegisterPage()),
    GoRoute(
      path: Paths.forgotPassword,
      builder: (context, state) => const Scaffold(body: Center(child: Text('Forgot Password'))),
    ),

    GoRoute(
      path: '${Paths.userProfile}/:userId',
      builder: (context, state) {
        final userIdParameters = state.pathParameters['userId'];
        final userId = userIdParameters ?? '';
        if (userId.isEmpty) return NotFoundPage();

        return UserProfilePage(userId: userId);
      },
    ),

    GoRoute(
      path: Paths.settings,
      builder: (context, state) => const Scaffold(body: Center(child: Text('Settings'))),
    ),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);
