import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/enum.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../auth/domain/usecases/update_password_usecase.dart';
import '../../domain/usecases/bookmark_post_usecase.dart';
import '../../domain/usecases/get_all_users_usecase.dart';
import '../../domain/usecases/update_friend_list_usecase.dart';
import '../models/user_detail_model.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers(GetAllUsersWithExcludeParams params);
  Future<UserModel> getUserById(String id);
  Future<UserDetailModel> getUserDetail(String id);
  Future<UserModel> updateUser(UserModel user);
  Future<void> updateFriendList(UpdateFriendListParams params);
  Future<void> bookmarkPost(BookmarkPostParams params);
  Future<void> updateUserPassword(UpdateUserPasswordParams params);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UserModel>> getAllUsers(GetAllUsersWithExcludeParams params) async {
    try {
      final response = await dio.get(
        ApiEndpoints.users,
        queryParameters: {
          '_page': params.page,
          '_limit': params.limit,
          '_order': params.order.getString(),
          'exclude': params.excludeId,
        },
      );
      final data = response.data as List;
      return data.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getAllUsers(GetAllUsersWithExcludeParams params)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final response = await dio.get(ApiEndpoints.singleUser(id));
      return UserModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getUserById(String id)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<UserDetailModel> getUserDetail(String id) async {
    try {
      final response = await dio.get(ApiEndpoints.userDetail(id));
      return UserDetailModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getUserDetail(String id)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<UserModel> updateUser(UserModel user) async {
    try {
      final response = await dio.put(ApiEndpoints.singleUser(user.id), data: user.toJson());
      return UserModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'updateUser(UserModel user)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> updateUserPassword(UpdateUserPasswordParams params) async {
    try {
      await dio.patch(
        ApiEndpoints.singleUser(params.userId),
        data: {'password': params.newPassword},
      );
      return;
    } on DioException catch (e, s) {
      handleDioException(e, s, 'updateUserPassword(UpdateUserPasswordParam user)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> updateFriendList(UpdateFriendListParams params) async {
    try {
      await dio.patch(
        ApiEndpoints.userFriendList(params.userId),
        data: {'friendIds': params.friendIds},
      );
      return;
    } on DioException catch (e, s) {
      handleDioException(e, s, 'updateFriendList(String userId, List<int> friendIds)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> bookmarkPost(BookmarkPostParams params) async {
    try {
      await dio.patch(
        ApiEndpoints.bookmarkPost(userId: params.userId),
        data: {'postId': params.postId},
      );
      return;
    } on DioException catch (e, s) {
      handleDioException(e, s, 'updateFriendList(String userId, List<int> friendIds)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
