import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/user_repository.dart';

class BookmarkPostUseCase implements UseCase<void, BookmarkPostParams> {
  final UserRepository repository;

  BookmarkPostUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(BookmarkPostParams params) async {
    return await repository.bookmarkPost(params);
  }
}

class BookmarkPostParams extends Equatable {
  final List<String> bookmarkedPostIds;
  final String postId;
  final String userId;

  const BookmarkPostParams({
    required this.postId,
    required this.bookmarkedPostIds,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, bookmarkedPostIds, userId];
}
