// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../user/data/datasources/user_remote_data_source.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final NetworkInfo networkInfo;
  final FirebaseAuth firebaseAuth;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.userRemoteDataSource,
    required this.networkInfo,
    required this.firebaseAuth,
  });

  @override
  Future<Either<Failure, UserEntity>> login(LoginParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAuth = await remoteDataSource.login(params);

        //Cache user
        await localDataSource.cacheAuth(remoteAuth);
        return Right(remoteAuth);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    }
    return Left(NoInternetFailure());
  }

  @override
  Future<Either<Failure, UserEntity>> register(RegisterParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAuth = await remoteDataSource.register(params);
        //Cache user
        await localDataSource.cacheAuth(remoteAuth);
        return Right(remoteAuth);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    }
    return Left(NoInternetFailure());
  }

  @override
  Future<Either<Failure, UserEntity>> getLoggedInUser() async {
    //Try get from cache
    final localAuth = await localDataSource.getCachedAuth();
    if (localAuth != null) {
      return Right(localAuth);
    }

    if (await networkInfo.isConnected) {
      try {
        final user = firebaseAuth.currentUser; // Use FirebaseAuth
        if (user == null) return Left(UnauthenticatedFailure());

        final userModel = await userRemoteDataSource.getUserById(user.uid);

        await localDataSource.cacheAuth(userModel);
        return Right(userModel);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.logout();
        await localDataSource.logout();
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    }
    return Left(NoInternetFailure());
  }

  @override
  Future<Either<Failure, void>> updateUserPassword(UpdateUserPasswordParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateUserPassword(params);

        return logout();
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }
}
