import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/user_repository.dart';

class UpdateFriendListUseCase implements UseCase<void, UpdateFriendListParams> {
  final UserRepository repository;

  UpdateFriendListUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateFriendListParams params) async {
    return await repository.updateFriendList(params);
  }
}

class UpdateFriendListParams extends Equatable {
  final String userId;
  final List<String> friendIds;

  const UpdateFriendListParams({required this.userId, required this.friendIds});

  @override
  List<Object?> get props => [userId, friendIds];
}
