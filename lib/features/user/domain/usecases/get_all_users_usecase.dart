import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetAllUsersUseCase implements UseCase<List<UserEntity>, GetAllUsersWithExcludeParams> {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(GetAllUsersWithExcludeParams params) async {
    return await repository.getAllUsers(params);
  }
}

class GetAllUsersWithExcludeParams extends PaginationParams {
  final String excludeId;
  const GetAllUsersWithExcludeParams({
    required this.excludeId,
    required super.page,
    required super.limit,
    super.order,
  });
}
