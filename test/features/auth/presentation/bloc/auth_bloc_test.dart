import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late AuthBloc bloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockGetLoggedInUserUseCase mockGetLoggedInUserUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockUpdatePasswordUseCase mockUpdatePasswordUseCase;
  late MockLogService mockLogService;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockGetLoggedInUserUseCase = MockGetLoggedInUserUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockUpdatePasswordUseCase = MockUpdatePasswordUseCase();
    mockLogService = MockLogService();

    bloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      getLoggedInUserUseCase: mockGetLoggedInUserUseCase,
      logoutUseCase: mockLogoutUseCase,
      updatePasswordUseCase: mockUpdatePasswordUseCase,
      logService: mockLogService,
    );
    registerFallbackValue(tNoParams);
    registerFallbackValue(tLoginParams);
    registerFallbackValue(tRegisterParams);
    registerFallbackValue(tUpdateUserPasswordParams);
  });

  tearDown(() {
    bloc.close();
  });

  test('initialState should be AuthInitial', () {
    expect(bloc.state, equals(AuthInitial()));
  });

  group('LoginEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthLoaded] when login is successful',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer((_) async => Right(tUserEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(LoginEvent(params: tLoginParams)),
      expect: () => [AuthLoading(), AuthLoaded(auth: tUserEntity)],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockLoginUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(LoginEvent(params: tLoginParams)),
      expect: () => [AuthLoading(), AuthError(failure: tServerFailure)],
    );
  });

  group('RegisterEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthLoaded] when register is successful',
      build: () {
        when(() => mockRegisterUseCase(any())).thenAnswer((_) async => Right(tUserEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(RegisterEvent(params: tRegisterParams)),
      expect: () => [AuthLoading(), AuthLoaded(auth: tUserEntity)],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when register fails',
      build: () {
        when(() => mockRegisterUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(RegisterEvent(params: tRegisterParams)),
      expect: () => [AuthLoading(), AuthError(failure: tServerFailure)],
    );
  });

  group('GetLoggedInUserEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthLoaded] when get logged in user is successful',
      build: () {
        when(() => mockGetLoggedInUserUseCase(any())).thenAnswer((_) async => Right(tUserEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(GetLoggedInUserEvent()),
      expect: () => [AuthLoading(), AuthLoaded(auth: tUserEntity)],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthInitial] when get logged in user fails',
      build: () {
        when(() => mockGetLoggedInUserUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(GetLoggedInUserEvent()),
      expect: () => [AuthLoading(), AuthInitial()],
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthInitial] when logout is successful',
      build: () {
        when(() => mockLogoutUseCase(any())).thenAnswer((_) async => Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [AuthLoading(), AuthInitial()],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthLoading, AuthError] when logout fails',
      build: () {
        when(() => mockLogoutUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(LogoutEvent()),
      expect: () => [AuthLoading(), AuthError(failure: tServerFailure)],
    );
  });

  group('UpdatePasswordEvent', () {
    blocTest<AuthBloc, AuthState>(
      'should emit [AuthInitial] after successfully updating the password',
      build: () {
        when(() => mockUpdatePasswordUseCase(any())).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdatePasswordEvent(newPassword: 'new_password', userId: '1')),
      expect: () => [AuthInitial()],
    );

    blocTest<AuthBloc, AuthState>(
      'should emit [AuthError] when updating the password fails',
      build: () {
        when(() => mockUpdatePasswordUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdatePasswordEvent(newPassword: 'new_password', userId: '1')),
      expect: () => [AuthError(failure: tServerFailure)],
    );
  });
}
