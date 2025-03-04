part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final LoginParams params;
  const LoginEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class RegisterEvent extends AuthEvent {
  final RegisterParams params;
  const RegisterEvent({required this.params});

  @override
  List<Object> get props => [params];
}

class GetLoggedInUserEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}

class UpdatePasswordEvent extends AuthEvent {
  final String userId;
  final String newPassword;

  const UpdatePasswordEvent({required this.newPassword, required this.userId});
}
