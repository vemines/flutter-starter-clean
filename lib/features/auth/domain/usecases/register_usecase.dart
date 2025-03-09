import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    String? validate = _validateParam(params);
    if (validate != null) return Left(InvalidInputFailure(message: validate));

    return await repository.register(params);
  }
}

class RegisterParams extends Equatable {
  final String fullname;
  final String password;
  final String email;

  const RegisterParams({required this.fullname, required this.password, required this.email});

  @override
  List<Object> get props => [fullname, password, email];
}

String? _validateParam(RegisterParams params) {
  if (params.fullname.length < 6) return 'Fullname must be at least 6 characters.';

  if (params.email.isEmpty || !params.email.contains('@')) return 'Invalid email address.';

  if (params.password.length < 6) return 'Password must be at least 6 characters.';

  return null;
}
