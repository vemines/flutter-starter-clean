import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class CreatePostUseCase implements UseCase<PostEntity, CreatePostParams> {
  final PostRepository repository;

  CreatePostUseCase(this.repository);

  @override
  Future<Either<Failure, PostEntity>> call(CreatePostParams params) async {
    return await repository.createPost(params);
  }
}

class CreatePostParams extends Equatable {
  final String userId;
  final String title;
  final String body;

  const CreatePostParams({required this.userId, required this.title, required this.body});

  @override
  List<Object?> get props => [userId, title, body];
}
