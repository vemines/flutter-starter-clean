import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user_detail_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/bookmark_post_usecase.dart';
import '../../domain/usecases/get_all_users_usecase.dart';
import '../../domain/usecases/update_friend_list_usecase.dart';
import '../datasources/user_remote_data_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers(
    GetAllUsersWithExcludeIdParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final users = await remoteDataSource.getAllUsers(params);
        return Right(users);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(IdParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getUserById(params.id);
        return Right(user);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UserEntity user) async {
    if (await networkInfo.isConnected) {
      try {
        final updatedUser = await remoteDataSource.updateUser(UserModel.fromEntity(user));
        return Right(updatedUser);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateFriendList(UpdateFriendListParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateFriendList(params);

        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> bookmarkPost(BookmarkPostParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.bookmarkPost(params);
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, UserDetailEntity>> getUserDetail(IdParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final user = await remoteDataSource.getUserDetail(params.id);
        return Right(user);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }
}
