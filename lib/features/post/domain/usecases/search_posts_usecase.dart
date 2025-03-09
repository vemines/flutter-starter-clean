import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/algolia_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/post_entity.dart';
import '../repositories/post_repository.dart';

class SearchPostsUseCase implements UseCase<List<PostEntity>, PaginationSearchPostParams> {
  final PostRepository repository;

  SearchPostsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PostEntity>>> call(PaginationSearchPostParams params) async {
    return await repository.searchPosts(params);
  }
}

class PaginationSearchPostParams extends PaginationParams {
  final String search;
  final AlgoliaService algoliaService;

  const PaginationSearchPostParams({
    required super.page,
    required super.limit,
    required this.search,
    required this.algoliaService,
    super.order,
  });

  @override
  List<Object?> get props => [page, limit, search];
}
