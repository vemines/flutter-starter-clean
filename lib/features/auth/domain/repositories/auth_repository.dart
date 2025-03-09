import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../usecases/login_usecase.dart';
import '../usecases/register_usecase.dart';
import '../usecases/update_password_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(LoginParams params);
  Future<Either<Failure, UserEntity>> register(RegisterParams params);
  Future<Either<Failure, UserEntity>> getLoggedInUser();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> updateUserPassword(UpdateUserPasswordParams params);
}
