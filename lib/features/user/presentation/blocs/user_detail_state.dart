part of 'user_detail_bloc.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object> get props => [];
}

class UserDetailInitial extends UserDetailState {
  const UserDetailInitial();
}

class UserDetailLoaded extends UserDetailState {
  final UserDetailEntity userDetail;

  const UserDetailLoaded({required this.userDetail});

  @override
  List<Object> get props => [userDetail];
}

class UserDetailError extends UserDetailState {
  final Failure failure;

  const UserDetailError({required this.failure});

  @override
  List<Object> get props => [failure];
}
