import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class GetAllUsersUseCase implements UseCase<List<UserEntity>, GetAllUsersWithExcludeIdParams> {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(GetAllUsersWithExcludeIdParams params) async {
    return await repository.getAllUsers(params);
  }
}

class GetAllUsersWithExcludeIdParams extends PaginationParams {
  final String excludeId;
  const GetAllUsersWithExcludeIdParams({
    required this.excludeId,
    required super.page,
    required super.limit,
    super.order,
  });
}
