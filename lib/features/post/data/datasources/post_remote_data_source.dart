import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/api_mapping.dart';
import '../../../../core/constants/enum.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/usecase/params.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/get_posts_by_user_id_usecase.dart';
import '../../domain/usecases/search_posts_usecase.dart';
import '../models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getAllPosts(PaginationParams params);
  Future<List<PostModel>> getPostsByUserId(GetPostsByUserIdParams params);
  Future<PostModel> getPostById(String id);
  Future<PostModel> createPost(CreatePostParams params);
  Future<PostModel> updatePost(PostModel post);
  Future<void> deletePost(String id);
  Future<List<PostModel>> searchPosts(PaginationSearchPostParams params);
  Future<List<PostModel>> getPostsByIds(ListIdParams params);
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final Dio dio;

  PostRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PostModel>> getAllPosts(PaginationParams params) async {
    try {
      final response = await dio.get(
        ApiEndpoints.posts,
        queryParameters: {
          '_page': params.page,
          '_limit': params.limit,
          '_sort': 'updatedAt',
          '_order': params.order.getString(),
        },
      );
      List<dynamic> data = response.data;
      return data.map((e) => PostModel.fromJson(e)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getAllPosts(PaginationParams params)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<PostModel> getPostById(String id) async {
    try {
      final response = await dio.get(ApiEndpoints.singlePost(id));
      return PostModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getPostById(String id)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<PostModel> createPost(CreatePostParams params) async {
    try {
      final response = await dio.post(
        ApiEndpoints.posts,
        data: {
          PostApiMap.kUserId: params.userId,
          PostApiMap.kTitle: params.title,
          PostApiMap.kBody: params.body,
        },
      );
      return PostModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'createPost(PostModel post)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<PostModel> updatePost(PostModel post) async {
    try {
      final response = await dio.put(ApiEndpoints.singlePost(post.id), data: post.toJson());
      return PostModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'updatePost(PostModel post)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      await dio.delete(ApiEndpoints.singlePost(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'deletePost(String id)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<PostModel>> searchPosts(PaginationSearchPostParams params) async {
    try {
      final response = await dio.get(
        ApiEndpoints.posts,
        queryParameters: {
          'q': params.search,
          '_page': params.page,
          '_limit': params.limit,
          '_sort': 'updatedAt',
          '_order': params.order.getString(),
        },
      );
      final List<dynamic> data = response.data;
      return data.map((e) => PostModel.fromJson(e)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'searchPosts(PaginationWithSearchParams params)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<PostModel>> getPostsByIds(ListIdParams params) async {
    try {
      final response = await dio.get(ApiEndpoints.posts, queryParameters: {'id': params.ids});
      final List<dynamic> data = response.data;
      return data.map((e) => PostModel.fromJson(e)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getPostsByIds(List<int> ids)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<PostModel>> getPostsByUserId(GetPostsByUserIdParams params) async {
    try {
      final response = await dio.get(
        ApiEndpoints.userPosts(userId: params.userId),
        queryParameters: {
          '_page': params.page,
          '_limit': params.limit,
          '_sort': 'updatedAt',
          '_order': params.order.getString(),
        },
      );
      List<dynamic> data = response.data;
      return data.map((e) => PostModel.fromJson(e)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getAllUserPosts(GetAllUserPostsParams params)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
