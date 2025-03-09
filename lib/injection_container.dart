import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/logs.dart';
import 'core/constants/env.dart';
import 'core/network/network_info.dart';
import 'core/services/algolia_service.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_logged_in_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/update_password_usecase.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/comment/data/datasources/comment_remote_data_source.dart';
import 'features/comment/data/repositories/comment_repository_impl.dart';
import 'features/comment/domain/repositories/comment_repository.dart';
import 'features/comment/domain/usecases/add_comment_usecase.dart';
import 'features/comment/domain/usecases/delete_comment_usecase.dart';
import 'features/comment/domain/usecases/get_comments_by_post_id_usecase.dart';
import 'features/comment/domain/usecases/update_comment_usecase.dart';
import 'features/comment/presentation/blocs/comment_bloc.dart';
import 'features/post/data/datasources/post_remote_data_source.dart';
import 'features/post/data/repositories/post_repository_impl.dart';
import 'features/post/domain/repositories/post_repository.dart';
import 'features/post/domain/usecases/create_post_usecase.dart';
import 'features/post/domain/usecases/delete_post_usecase.dart';
import 'features/post/domain/usecases/get_all_posts_usecase.dart';
import 'features/post/domain/usecases/get_bookmarked_posts_usecase.dart';
import 'features/post/domain/usecases/get_post_by_id_usecase.dart';
import 'features/post/domain/usecases/get_posts_by_user_id_usecase.dart';
import 'features/post/domain/usecases/search_posts_usecase.dart';
import 'features/post/domain/usecases/update_post_usecase.dart';
import 'features/post/presentation/blocs/post_bloc.dart';
import 'features/user/data/datasources/user_remote_data_source.dart';
import 'features/user/data/repositories/user_repository_impl.dart';
import 'features/user/domain/repositories/user_repository.dart';
import 'features/user/domain/usecases/bookmark_post_usecase.dart';
import 'features/user/domain/usecases/get_all_users_usecase.dart';
import 'features/user/domain/usecases/get_user_by_id_usecase.dart';
import 'features/user/domain/usecases/get_user_detail_usecase.dart';
import 'features/user/domain/usecases/update_friend_list_usecase.dart';
import 'features/user/domain/usecases/update_user_usecase.dart';
import 'features/user/presentation/blocs/user_bloc.dart';
import 'features/user/presentation/blocs/user_detail_bloc.dart';

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
      algoliaService: sl(),
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
  sl.registerFactory(() => UserDetailBloc(getUserDetailUseCase: sl(), logService: sl()));
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
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
      firebaseAuth: sl(),
      userRemoteDataSource: sl(),
    ),
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
  final firestore = FirebaseFirestore.instance..useFirestoreEmulator('localhost', 8080);

  sl.registerLazySingleton(() => firestore);

  final auth = FirebaseAuth.instance;
  await auth.useAuthEmulator('localhost', 9099);
  sl.registerLazySingleton(() => auth);

  // Initialize Algolia
  final algoliaClient = SearchClient(appId: ALGOLIA_APP_ID, apiKey: ALGOLIA_ADMIN_KEY);
  final alogoliaService = AlgoliaServiceImpl(searchClient: algoliaClient);
  // Register Algolia instance
  sl.registerSingleton<AlgoliaService>(alogoliaService);
}
