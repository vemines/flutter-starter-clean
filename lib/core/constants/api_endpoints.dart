class ApiEndpoints {
  static String login = '/login';
  static String register = '/register';
  static String verify = '/verify';
  static String users = '/users';
  static String posts = '/posts';
  static String comments = '/comments';

  static String getCommentsByPostId({required String postId}) => '$posts/$postId/comments';
  static String userFriendList(String userId) => '$users/$userId/friends';
  static String singleComment(String id) => '$comments/$id';
  static String singlePost(String id) => '$posts/$id';
  static String singleUser(String id) => '$users/$id';
  static String userDetail(String id) => '$users/$id/details';
  static String bookmarkPost({required String userId}) => '$users/$userId/bookmark';
  static String userPosts({required String userId}) => '$users/$userId/posts';
}
