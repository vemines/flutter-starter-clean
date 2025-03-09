import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class GetPostsByUserIdUseCase implements UseCase<List<PostEntity>, GetPostsByUserIdParams> {
  final PostRepository repository;

  GetPostsByUserIdUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(GetPostsByUserIdParams params) async {
    return await repository.getPostsByUserId(params);
  }
}

class GetPostsByUserIdParams extends PaginationParams {
  final String userId;
  const GetPostsByUserIdParams({
    required this.userId,
    required super.page,
    required super.limit,
    super.order,
  });
}
