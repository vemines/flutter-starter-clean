import 'package:algoliasearch/algoliasearch_lite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_starter_clean/app/logs.dart';
import 'package:flutter_starter_clean/core/errors/exceptions.dart';
import 'package:flutter_starter_clean/core/errors/failures.dart';
import 'package:flutter_starter_clean/core/network/network_info.dart';
import 'package:flutter_starter_clean/core/services/algolia_service.dart';
import 'package:flutter_starter_clean/core/usecase/params.dart';
import 'package:flutter_starter_clean/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_starter_clean/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_starter_clean/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_starter_clean/features/auth/domain/usecases/get_logged_in_user_usecase.dart';
import 'package:flutter_starter_clean/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_starter_clean/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_starter_clean/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_starter_clean/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:flutter_starter_clean/features/comment/data/datasources/comment_remote_data_source.dart';
import 'package:flutter_starter_clean/features/comment/data/models/comment_model.dart';
import 'package:flutter_starter_clean/features/comment/domain/entities/comment_entity.dart';
import 'package:flutter_starter_clean/features/comment/domain/repositories/comment_repository.dart';
import 'package:flutter_starter_clean/features/comment/domain/usecases/add_comment_usecase.dart';
import 'package:flutter_starter_clean/features/comment/domain/usecases/delete_comment_usecase.dart';
import 'package:flutter_starter_clean/features/comment/domain/usecases/get_comments_by_post_id_usecase.dart';
import 'package:flutter_starter_clean/features/comment/domain/usecases/update_comment_usecase.dart';
import 'package:flutter_starter_clean/features/post/data/datasources/post_remote_data_source.dart';
import 'package:flutter_starter_clean/features/post/data/models/post_model.dart';
import 'package:flutter_starter_clean/features/post/domain/entities/post_entity.dart';
import 'package:flutter_starter_clean/features/post/domain/repositories/post_repository.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/create_post_usecase.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/delete_post_usecase.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/get_all_posts_usecase.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/get_bookmarked_posts_usecase.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/get_posts_by_user_id_usecase.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/get_post_by_id_usecase.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/search_posts_usecase.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/update_post_usecase.dart';
import 'package:flutter_starter_clean/features/user/data/datasources/user_remote_data_source.dart';
import 'package:flutter_starter_clean/features/user/data/models/user_detail_model.dart';
import 'package:flutter_starter_clean/features/user/data/models/user_model.dart';
import 'package:flutter_starter_clean/features/user/domain/entities/user_detail_entity.dart';
import 'package:flutter_starter_clean/features/user/domain/entities/user_entity.dart';
import 'package:flutter_starter_clean/features/user/domain/repositories/user_repository.dart';
import 'package:flutter_starter_clean/features/user/domain/usecases/bookmark_post_usecase.dart';
import 'package:flutter_starter_clean/features/user/domain/usecases/get_all_users_usecase.dart';
import 'package:flutter_starter_clean/features/user/domain/usecases/get_user_by_id_usecase.dart';
import 'package:flutter_starter_clean/features/user/domain/usecases/get_user_detail_usecase.dart';
import 'package:flutter_starter_clean/features/user/domain/usecases/update_friend_list_usecase.dart';
import 'package:flutter_starter_clean/features/user/domain/usecases/update_user_usecase.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAggregateQuery extends Mock implements AggregateQuery {}

class MockAggregateQuerySnapshot extends Mock implements AggregateQuerySnapshot {}

// Mock Classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockGetLoggedInUserUseCase extends Mock implements GetLoggedInUserUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockPostRemoteDataSource extends Mock implements PostRemoteDataSource {}

class MockPostRepository extends Mock implements PostRepository {}

class MockGetAllPostsUseCase extends Mock implements GetAllPostsUseCase {}

class MockGetPostByIdUseCase extends Mock implements GetPostByIdUseCase {}

class MockCreatePostUseCase extends Mock implements CreatePostUseCase {}

class MockUpdatePostUseCase extends Mock implements UpdatePostUseCase {}

class MockDeletePostUseCase extends Mock implements DeletePostUseCase {}

class MockSearchPostsUseCase extends Mock implements SearchPostsUseCase {}

class MockGetPostsByUserIdUseCase extends Mock implements GetPostsByUserIdUseCase {}

class MockGetBookmarkedPostsUseCase extends Mock implements GetBookmarkedPostsUseCase {}

class MockBookmarkPostUseCase extends Mock implements BookmarkPostUseCase {}

class MockUserRemoteDataSource extends Mock implements UserRemoteDataSource {}

class MockUserRepository extends Mock implements UserRepository {}

class MockGetAllUsersUseCase extends Mock implements GetAllUsersUseCase {}

class MockGetUserByIdUseCase extends Mock implements GetUserByIdUseCase {}

class MockGetUserDetailUseCase extends Mock implements GetUserDetailUseCase {}

class MockUpdateUserUseCase extends Mock implements UpdateUserUseCase {}

class MockUpdateFriendListUseCase extends Mock implements UpdateFriendListUseCase {}

class MockCommentRemoteDataSource extends Mock implements CommentRemoteDataSource {}

class MockCommentRepository extends Mock implements CommentRepository {}

class MockGetCommentsByPostIdUseCase extends Mock implements GetCommentsByPostIdUseCase {}

class MockAddCommentUseCase extends Mock implements AddCommentUseCase {}

class MockUpdateCommentUseCase extends Mock implements UpdateCommentUseCase {}

class MockDeleteCommentUseCase extends Mock implements DeleteCommentUseCase {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockInternetConnection extends Mock implements InternetConnection {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockLogService extends Mock implements LogService {}

class MockUpdatePasswordUseCase extends Mock implements UpdatePasswordUseCase {}

class MockAlgoliaService extends Mock implements AlgoliaService {}

// Mock Variables
final datetime = DateTime.now();

// Auth
final tRegisterParams = RegisterParams(
  fullname: 'testuser',
  password: 'password',
  email: 'test@example.com',
);
final tLoginParams = LoginParams(email: tRegisterParams.email, password: tRegisterParams.password);
final tUpdateUserPasswordParams = UpdateUserPasswordParams(
  newPassword: "new",
  userId: tUserEntity.id,
);

// Post
final tPostEntity = PostEntity(
  id: "1",
  userId: tUserEntity.id,
  title: "Test",
  body: "body",
  imageUrl: "imageUrl",
  createdAt: datetime,
  updatedAt: datetime,
);
final tPostEntityUpdate = tPostEntity.copyWith(body: 'updated Body');
final tPostModel = PostModel.fromEntity(tPostEntity);
final tUpdatedPostModel = tPostModel.copyWith(body: "Updated body");
final tPostModels = [tPostModel, tPostModel];
final tPostEntities = [tPostEntity, tPostEntity];
final tPostIdParams = IdParams(id: tPostEntity.id);
final tPaginationParams = PaginationParams(page: 1, limit: 10);
final tQuery = 'test';
final tAlgoliaService = MockAlgoliaService();
final tPaginationWithSearchParams = PaginationSearchPostParams(
  page: 1,
  limit: 10,
  search: tQuery,
  algoliaService: tAlgoliaService,
);
final tGetPostsByUserIdParams = GetPostsByUserIdParams(userId: "1", page: 1, limit: 10);
final tCreatePostParams = CreatePostParams(
  userId: tUserEntity.id,
  body: tPostEntity.body,
  title: tPostEntity.title,
);
final tSearchClient = SearchClient(appId: "123", apiKey: '123');

// User
final tUserEntity = UserEntity(
  id: "1",
  fullName: 'Test User',
  email: 'test@example.com',
  avatar: 'avatar_url',
  cover: 'cover_url',
  about: 'about_me',
  bookmarksId: tBookmarkedIds,
  friendsId: tFriendIds,
  createdAt: datetime,
  updatedAt: datetime,
);
final tUserModel = UserModel.fromEntity(tUserEntity);
final tUpdateUserModel = tUserModel.copyWith(fullName: 'Updated Name');
final tUpdateUserEntity = tUserEntity.copyWith(fullName: 'Updated Name');
final tUserModels = [tUserModel, tUserModel];
final tUserEntities = [tUserEntity, tUserEntity];
final tFriendIds = ["2", "3"];
final tBookmarkedIds = ["2", "3"];
final tUserIdParams = IdParams(id: tUserEntity.id);
final tListBookmarkPostIdParams = ListIdParams(ids: tUserEntity.bookmarksId);
final tBookmarkPostParams = BookmarkPostParams(
  postId: tPostEntity.id,
  bookmarkedPostIds: tUserEntity.bookmarksId,
  userId: tUserEntity.id,
);
final tBookmarkPostParams2 = BookmarkPostParams(
  postId: '2',
  bookmarkedPostIds: tUserEntity.bookmarksId,
  userId: tUserEntity.id,
);
final tUpdateFriendListParams = UpdateFriendListParams(
  userId: tUserEntity.id,
  friendIds: tFriendIds,
);
final tGetAllUsersWithExcludeParams = GetAllUsersWithExcludeIdParams(
  excludeId: tUserEntity.id,
  page: 1,
  limit: 10,
);
final tUserDetailEntity = UserDetailEntity(friends: 1, posts: 1, comments: 1);
final tUserDetailModel = UserDetailModel.fromEntity(tUserDetailEntity);

// Comment
final tCommentEntity = CommentEntity(
  id: "1",
  postId: tPostEntity.id,
  user: tUserEntity,
  body: 'Test comment',
  createdAt: datetime,
  updatedAt: datetime,
);
final tUpdatedCommentEntity = tCommentEntity.copyWith(body: 'Updated comment');
final tCommentModel = CommentModel.fromEntity(tCommentEntity);
final tUpdatedCommentModel = tCommentModel.copyWith(body: 'Updated comment');
final tCommentModels = [tCommentModel, tCommentModel];
final tCommentEntities = [tCommentEntity, tCommentEntity];
final tAddCommentParams = AddCommentParams(
  postId: tPostEntity.id,
  userId: tUserEntity.id,
  body: 'Test Body',
);
//
final tGetCommentsParams = GetCommentsParams(postId: tPostEntity.id, page: 1, limit: 10);

final tServerException = ServerException(
  message: 'ServerException',
  stackTrace: StackTrace.current,
);
final tServerFailure = tServerException.toFailure();
final tNoInternetFailure = NoInternetFailure();
final tNoParams = NoParams();
final tFirebaseException = FirebaseException(plugin: 'plugin');
