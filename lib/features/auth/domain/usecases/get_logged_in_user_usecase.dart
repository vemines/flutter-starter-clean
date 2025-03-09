import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetLoggedInUserUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  GetLoggedInUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.getLoggedInUser();
  }
}
