import 'package:equatable/equatable.dart';

class UserDetailEntity extends Equatable {
  final int friends;
  final int posts;
  final int comments;

  const UserDetailEntity({required this.friends, required this.posts, required this.comments});

  @override
  List<Object?> get props => [friends, posts, comments];
}
