import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_detail_entity.dart';
import '../repositories/user_repository.dart';

class GetUserDetailUseCase implements UseCase<UserDetailEntity, IdParams> {
  final UserRepository repository;

  GetUserDetailUseCase(this.repository);

  @override
  Future<Either<Failure, UserDetailEntity>> call(IdParams params) async {
    return await repository.getUserDetail(params);
  }
}
