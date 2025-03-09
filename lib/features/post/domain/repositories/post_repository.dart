import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/post_entity.dart';
import '../usecases/create_post_usecase.dart';
import '../usecases/get_posts_by_user_id_usecase.dart';
import '../usecases/search_posts_usecase.dart';

abstract class PostRepository {
  Future<Either<Failure, List<PostEntity>>> getAllPosts(PaginationParams params);
  Future<Either<Failure, List<PostEntity>>> getPostsByUserId(GetPostsByUserIdParams params);
  Future<Either<Failure, PostEntity>> getPostById(IdParams params);
  Future<Either<Failure, PostEntity>> createPost(CreatePostParams params);
  Future<Either<Failure, PostEntity>> updatePost(PostEntity post);
  Future<Either<Failure, void>> deletePost(PostEntity post);
  Future<Either<Failure, List<PostEntity>>> searchPosts(PaginationSearchPostParams params);
  Future<Either<Failure, List<PostEntity>>> getBookmarkedPosts(ListIdParams params);
}
