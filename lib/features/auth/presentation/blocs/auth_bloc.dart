import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/logs.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/params.dart';
import '../../../user/domain/entities/user_entity.dart';
import '../../domain/usecases/get_logged_in_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GetLoggedInUserUseCase getLoggedInUserUseCase;
  final LogoutUseCase logoutUseCase;
  final UpdatePasswordUseCase updatePasswordUseCase;
  final LogService logService;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.getLoggedInUserUseCase,
    required this.logoutUseCase,
    required this.updatePasswordUseCase,
    required this.logService,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<RegisterEvent>(_onRegister);
    on<GetLoggedInUserEvent>(_onGetLoggedInUser);
    on<LogoutEvent>(_onLogout);
    on<UpdatePasswordEvent>(_onUpdateUserPassword);
  }

  Future<void> _onUpdateUserPassword(UpdatePasswordEvent event, Emitter<AuthState> emit) async {
    final result = await updatePasswordUseCase(
      UpdateUserPasswordParams(userId: event.userId, newPassword: event.newPassword),
    );

    result.fold(
      (failure) {
        logService.w(
          '$failure occur at _onGetUserById(GetUserByIdEvent event, Emitter<UserState> emit)',
        );
        emit(AuthError(failure: failure));
      },
      (_) {
        emit(AuthInitial());
      },
    );
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(event.params);
    emit(_mapResultToAuthLoaded(result, '_onLogin(LoginEvent event, Emitter<AuthState> emit)'));
  }

  Future<void> _onRegister(RegisterEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUseCase(event.params);
    emit(
      _mapResultToAuthLoaded(result, '_onRegister(RegisterEvent event, Emitter<AuthState> emit)'),
    );
  }

  Future<void> _onGetLoggedInUser(GetLoggedInUserEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getLoggedInUserUseCase(NoParams());
    emit(
      _mapResultToAuthLoaded(
        result,
        '_onGetLoggedInUser(GetLoggedInUserEvent event, Emitter<AuthState> emit)',
      ),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await logoutUseCase(NoParams());
    result.fold((failure) {
      logService.w('$failure occur at _onLogout(LogoutEvent event, Emitter<AuthState> emit)');
      emit(AuthError(failure: failure));
    }, (_) => emit(AuthInitial()));
  }

  AuthState _mapResultToAuthLoaded(Either<Failure, UserEntity> result, String errorAt) {
    return result.fold(
      (failure) {
        if (errorAt.contains('GetLoggedInUserEvent')) {
          return AuthInitial();
        }
        logService.w('$failure occur at $errorAt');
        return AuthError(failure: failure);
      },
      (auth) {
        return AuthLoaded(auth: auth);
      },
    );
  }
}
