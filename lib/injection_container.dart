// lib/injection_container.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/logs.dart';
import 'core/network/network_info.dart';

import 'features/datasources/auth/auth_local_data_source.dart';
import 'features/datasources/auth/auth_remote_data_source.dart';
import 'features/datasources/comment/comment_remote_data_source.dart';
import 'features/datasources/post/post_remote_data_source.dart';
import 'features/datasources/user/user_remote_data_source.dart';
import 'features/repositories/auth/auth_repository.dart';
import 'features/repositories/comment/comment_repository.dart';
import 'features/repositories/post/post_repository.dart';
import 'features/repositories/user/user_repository.dart';
import 'features/usecases/auth/get_logged_in_user_usecase.dart';
import 'features/usecases/auth/login_usecase.dart';
import 'features/usecases/auth/logout_usecase.dart';
import 'features/usecases/auth/register_usecase.dart';
import 'features/usecases/auth/update_password_usecase.dart';
import 'features/usecases/comment/add_comment_usecase.dart';
import 'features/usecases/comment/delete_comment_usecase.dart';
import 'features/usecases/comment/get_comments_by_post_id_usecase.dart';
import 'features/usecases/comment/update_comment_usecase.dart';
import 'features/usecases/post/create_post_usecase.dart';
import 'features/usecases/post/delete_post_usecase.dart';
import 'features/usecases/post/get_all_posts_usecase.dart';
import 'features/usecases/post/get_bookmarked_posts_usecase.dart';
import 'features/usecases/post/get_post_by_id_usecase.dart';
import 'features/usecases/post/get_posts_by_user_id_usecase.dart';
import 'features/usecases/post/search_posts_usecase.dart';
import 'features/usecases/post/update_post_usecase.dart';
import 'features/usecases/user/bookmark_post_usecase.dart';
import 'features/usecases/user/get_all_users_usecase.dart';
import 'features/usecases/user/get_user_by_id_usecase.dart';
import 'features/usecases/user/get_user_detail_usecase.dart';
import 'features/usecases/user/update_friend_list_usecase.dart';
import 'features/usecases/user/update_user_usecase.dart';
import 'features/blocs/auth/auth_bloc.dart';
import 'features/blocs/comment/comment_bloc.dart';
import 'features/blocs/post/post_bloc.dart';
import 'features/blocs/user/user_bloc.dart';
import 'features/blocs/user/user_detail_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features
  // Bloc
  sl.registerLazySingleton(
    () => AuthBloc(
      loginUseCase: sl(),
      registerUseCase: sl(),
      getLoggedInUserUseCase: sl(),
      logoutUseCase: sl(),
      updatePasswordUseCase: sl(),
      logService: sl(),
    ),
  );
  sl.registerFactory(
    () => PostBloc(
      getAllPosts: sl(),
      getPostById: sl(),
      createPost: sl(),
      updatePost: sl(),
      deletePost: sl(),
      searchPosts: sl(),
      getBookmarkedPosts: sl(),
      getPostsByUserIdUseCase: sl(),
      logService: sl(),
    ),
  );
  sl.registerFactory(
    () => UserBloc(
      getAllUsersUseCase: sl(),
      getUserByIdUseCase: sl(),
      updateUserUseCase: sl(),
      updateFriendListUseCase: sl(),
      bookmarkPostUseCase: sl(),
      logService: sl(),
    ),
  );
  sl.registerLazySingleton(() => UserDetailBloc(getUserDetailUseCase: sl(), logService: sl()));
  sl.registerFactory(
    () => CommentBloc(
      addComment: sl(),
      deleteComment: sl(),
      getCommentsByPostId: sl(),
      updateComment: sl(),
      logService: sl(),
    ),
  );

  // Use cases
  // -- Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetLoggedInUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePasswordUseCase(sl()));

  // -- Post
  sl.registerLazySingleton(() => GetAllPostsUseCase(sl()));
  sl.registerLazySingleton(() => GetPostByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePostUseCase(sl()));
  sl.registerLazySingleton(() => DeletePostUseCase(sl()));
  sl.registerLazySingleton(() => SearchPostsUseCase(sl()));
  sl.registerLazySingleton(() => GetBookmarkedPostsUseCase(sl()));
  sl.registerLazySingleton(() => GetPostsByUserIdUseCase(sl()));

  // -- User
  sl.registerLazySingleton(() => BookmarkPostUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUsersUseCase(sl()));
  sl.registerLazySingleton(() => GetUserDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateFriendListUseCase(sl()));

  // -- Comment
  sl.registerLazySingleton(() => GetCommentsByPostIdUseCase(sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCommentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firestore: sl(), firebaseAuth: sl()),
  ); // Add firebaseAuth
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(secureStorage: sl()));
  sl.registerLazySingleton<PostRemoteDataSource>(() => PostRemoteDataSourceImpl(firestore: sl()));
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(firestore: sl()));
  sl.registerLazySingleton<CommentRemoteDataSource>(
    () => CommentRemoteDataSourceImpl(firestore: sl()),
  );
  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnection());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  final logService = await LogService.instance();
  sl.registerLazySingleton<LogService>(() => logService);

  //Firebase
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance); // Register FirebaseAuth
}
