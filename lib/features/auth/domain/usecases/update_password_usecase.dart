import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase implements UseCase<void, UpdateUserPasswordParams> {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateUserPasswordParams params) async {
    return await repository.updateUserPassword(params);
  }
}

class UpdateUserPasswordParams {
  final String userId;
  final String newPassword;

  UpdateUserPasswordParams({required this.newPassword, required this.userId});
}
