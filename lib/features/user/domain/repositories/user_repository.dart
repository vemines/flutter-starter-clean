import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_detail_entity.dart';
import '../entities/user_entity.dart';
import '../usecases/bookmark_post_usecase.dart';
import '../usecases/get_all_users_usecase.dart';
import '../usecases/update_friend_list_usecase.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getAllUsers(GetAllUsersWithExcludeParams params);
  Future<Either<Failure, UserEntity>> getUserById(IdParams params);
  Future<Either<Failure, UserDetailEntity>> getUserDetail(IdParams params);
  Future<Either<Failure, UserEntity>> updateUser(UserEntity userEntity);
  Future<Either<Failure, void>> updateFriendList(UpdateFriendListParams params);
  Future<Either<Failure, void>> bookmarkPost(BookmarkPostParams params);
}
