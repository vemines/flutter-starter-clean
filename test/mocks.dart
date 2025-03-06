import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_starter_clean/app/logs.dart';
import 'package:flutter_starter_clean/core/errors/exceptions.dart';
import 'package:flutter_starter_clean/core/errors/failures.dart';
import 'package:flutter_starter_clean/core/network/network_info.dart';
import 'package:flutter_starter_clean/core/usecase/params.dart';
import 'package:flutter_starter_clean/features/datasources/auth/auth_local_data_source.dart';
import 'package:flutter_starter_clean/features/datasources/auth/auth_remote_data_source.dart';
import 'package:flutter_starter_clean/features/models/auth/auth_model.dart';
import 'package:flutter_starter_clean/features/entities/auth/auth_entity.dart';
import 'package:flutter_starter_clean/features/repositories/auth/auth_repository.dart';
import 'package:flutter_starter_clean/features/usecases/auth/get_logged_in_user_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/auth/login_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/auth/logout_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/auth/register_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/auth/update_password_usecase.dart';
import 'package:flutter_starter_clean/features/datasources/comment/comment_remote_data_source.dart';
import 'package:flutter_starter_clean/features/models/comment/comment_model.dart';
import 'package:flutter_starter_clean/features/entities/comment/comment_entity.dart';
import 'package:flutter_starter_clean/features/repositories/comment/comment_repository.dart';
import 'package:flutter_starter_clean/features/usecases/comment/add_comment_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/comment/delete_comment_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/comment/get_comments_by_post_id_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/comment/update_comment_usecase.dart';
import 'package:flutter_starter_clean/features/datasources/post/post_remote_data_source.dart';
import 'package:flutter_starter_clean/features/models/post/post_model.dart';
import 'package:flutter_starter_clean/features/entities/post/post_entity.dart';
import 'package:flutter_starter_clean/features/repositories/post/post_repository.dart';
import 'package:flutter_starter_clean/features/usecases/post/create_post_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/post/delete_post_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/post/get_all_posts_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/post/get_bookmarked_posts_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/post/get_posts_by_user_id_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/post/get_post_by_id_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/post/search_posts_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/post/update_post_usecase.dart';
import 'package:flutter_starter_clean/features/datasources/user/user_remote_data_source.dart';
import 'package:flutter_starter_clean/features/models/user/user_detail_model.dart';
import 'package:flutter_starter_clean/features/models/user/user_model.dart';
import 'package:flutter_starter_clean/features/entities/user/user_detail_entity.dart';
import 'package:flutter_starter_clean/features/entities/user/user_entity.dart';
import 'package:flutter_starter_clean/features/repositories/user/user_repository.dart';
import 'package:flutter_starter_clean/features/usecases/user/bookmark_post_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/user/get_all_users_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/user/get_user_by_id_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/user/get_user_detail_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/user/update_friend_list_usecase.dart';
import 'package:flutter_starter_clean/features/usecases/user/update_user_usecase.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock Classes
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

// Mock Variables

final datetime = DateTime.now();

// Auth
final tAuthEntity = AuthEntity(
  id: "1",
  fullName: 'Test User',
  userName: 'testuser',
  email: 'test@example.com',
);
final tAuthModel = AuthModel.fromEntity(tAuthEntity);
final tSecret = 'test_secret';
final tRegisterParams = RegisterParams(
  userName: 'testuser',
  password: 'password',
  email: 'test@example.com',
);
final tLoginParams = LoginParams(
  email: tRegisterParams.userName,
  password: tRegisterParams.password,
);
final tUpdateUserPasswordParams = UpdateUserPasswordParams(
  newPassword: "new",
  userId: tAuthEntity.id,
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
final tPostModels = [tPostModel, tPostModel];
final tPostEntities = [tPostEntity, tPostEntity];
final tPostIdParams = IdParams(id: tPostEntity.id);
final tPaginationParams = PaginationParams(page: 1, limit: 10);
final tQuery = 'test';
final tPaginationWithSearchParams = PaginationSearchPostParams(page: 1, limit: 10, search: tQuery);
final tGetPostsByUserIdParams = GetPostsByUserIdParams(userId: "1", page: 1, limit: 10);
final tCreatePostParams = CreatePostParams(
  userId: "1",
  body: tPostEntity.body,
  title: tPostEntity.title,
);

// User
final tUserEntity = UserEntity(
  id: "1",
  fullName: 'Test User',
  userName: 'testuser',
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
final tBookmarkedIds = ["1", "2", "3"];
final tUserIdParams = IdParams(id: tUserEntity.id);
final tListBookmarkPostIdParams = ListIdParams(ids: tUserEntity.bookmarksId);
final tBookmarkPostParams = BookmarkPostParams(
  postId: tPostEntity.id,
  bookmarkedPostIds: tUserEntity.bookmarksId,
  userId: tUserEntity.id,
);
final tUpdateFriendListParams = UpdateFriendListParams(
  userId: tUserEntity.id,
  friendIds: tFriendIds,
);
final tGetAllUsersWithExcludeParams = GetAllUsersWithExcludeParams(
  excludeId: "1",
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
final tGetCommentsParams = GetCommentsParams(postId: tPostEntity.id, page: 1, limit: 10, skip: 0);

final tServerException = ServerException(message: 'ServerException', statusCode: -1);
final tServerFailure = tServerException.toFailure();
final tNoInternetFailure = NoInternetFailure();

final tNoParams = NoParams();
