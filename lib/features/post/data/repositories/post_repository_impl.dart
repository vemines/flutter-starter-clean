import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/get_posts_by_user_id_usecase.dart';
import '../../domain/usecases/search_posts_usecase.dart';
import '../datasources/post_remote_data_source.dart';
import '../models/post_model.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<PostEntity>>> getAllPosts(PaginationParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final posts = await remoteDataSource.getAllPosts(params);
        return Right(posts);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, PostEntity>> getPostById(IdParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePost = await remoteDataSource.getPostById(params.id);
        return Right(remotePost);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, PostEntity>> createPost(CreatePostParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePost = await remoteDataSource.createPost(params);
        return Right(remotePost);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, PostEntity>> updatePost(PostEntity post) async {
    if (await networkInfo.isConnected) {
      try {
        final postModel = PostModel.fromEntity(post);
        final remotePost = await remoteDataSource.updatePost(postModel);
        return Right(remotePost);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(PostEntity post) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deletePost(post.id);
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> searchPosts(PaginationSearchPostParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final posts = await remoteDataSource.searchPosts(params);
        return Right(posts);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getBookmarkedPosts(ListIdParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final posts = await remoteDataSource.getPostsByIds(params);
        return Right(posts);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<PostEntity>>> getPostsByUserId(GetPostsByUserIdParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final posts = await remoteDataSource.getPostsByUserId(params);
        return Right(posts);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return Left(NoInternetFailure());
    }
  }
}
