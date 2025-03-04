import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/user/presentation/blocs/user_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late UserDetailBloc bloc;
  late MockLogService mockLogService;
  late MockGetUserDetailUseCase mockGetUserDetailUseCase;

  setUp(() {
    mockLogService = MockLogService();
    mockGetUserDetailUseCase = MockGetUserDetailUseCase();

    bloc = UserDetailBloc(
      getUserDetailUseCase: mockGetUserDetailUseCase,
      logService: mockLogService,
    );
  });

  setUpAll(() {
    registerFallbackValue(tUserIdParams);
  });

  tearDown(() {
    bloc.close();
  });

  test('initialState should be UserDetailInitial', () {
    expect(bloc.state, equals(UserDetailInitial()));
  });

  group('GetUserDetailEvent', () {
    blocTest<UserDetailBloc, UserDetailState>(
      'should emit [UserDetailLoaded] with user detail when successful',
      build: () {
        when(
          () => mockGetUserDetailUseCase(any()),
        ).thenAnswer((_) async => Right(tUserDetailEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(GetUserDetailEvent(userId: 'user1')),
      expect: () => [UserDetailLoaded(userDetail: tUserDetailEntity)],
    );

    blocTest<UserDetailBloc, UserDetailState>(
      'should emit [UserError] when getting user detail fails',
      build: () {
        when(() => mockGetUserDetailUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(GetUserDetailEvent(userId: 'user1')),
      expect: () => [UserDetailError(failure: tServerFailure)],
    );
  });
}
