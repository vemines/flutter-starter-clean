import '../../../../core/constants/api_mapping.dart';
import '../../../../core/utils/num_utils.dart';
import '../../domain/entities/user_detail_entity.dart';

class UserDetailModel extends UserDetailEntity {
  const UserDetailModel({required super.friends, required super.posts, required super.comments});

  factory UserDetailModel.fromJson(Map<String, dynamic> json) {
    return UserDetailModel(
      friends: intParse(value: json[UserDetailApiMap.kFriends].toString()),
      posts: intParse(value: json[UserDetailApiMap.kPosts].toString()),
      comments: intParse(value: json[UserDetailApiMap.kComments].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      UserDetailApiMap.kFriends: friends,
      UserDetailApiMap.kPosts: posts,
      UserDetailApiMap.kComments: comments,
    };
  }

  factory UserDetailModel.fromEntity(UserDetailEntity userDetail) {
    return UserDetailModel(
      friends: userDetail.friends,
      posts: userDetail.posts,
      comments: userDetail.comments,
    );
  }
}
