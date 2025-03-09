import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/user/domain/entities/user_entity.dart';
import 'package:flutter_starter_clean/features/user/presentation/blocs/user_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late UserBloc bloc;
  late MockGetAllUsersUseCase mockGetAllUsersUseCase;
  late MockGetUserByIdUseCase mockGetUserByIdUseCase;
  late MockUpdateUserUseCase mockUpdateUserUseCase;
  late MockUpdateFriendListUseCase mockUpdateFriendListUseCase;
  late MockLogService mockLogService;
  late MockBookmarkPostUseCase mockBookmarkPostUseCase;

  setUp(() {
    mockGetAllUsersUseCase = MockGetAllUsersUseCase();
    mockGetUserByIdUseCase = MockGetUserByIdUseCase();
    mockUpdateUserUseCase = MockUpdateUserUseCase();
    mockUpdateFriendListUseCase = MockUpdateFriendListUseCase();
    mockBookmarkPostUseCase = MockBookmarkPostUseCase();
    mockLogService = MockLogService();

    bloc = UserBloc(
      getAllUsersUseCase: mockGetAllUsersUseCase,
      getUserByIdUseCase: mockGetUserByIdUseCase,
      updateUserUseCase: mockUpdateUserUseCase,
      updateFriendListUseCase: mockUpdateFriendListUseCase,
      bookmarkPostUseCase: mockBookmarkPostUseCase,
      logService: mockLogService,
    );
  });

  setUpAll(() {
    registerFallbackValue(tUserEntity);
    registerFallbackValue(tGetAllUsersWithExcludeParams);
    registerFallbackValue(tUserIdParams);
    registerFallbackValue(tBookmarkPostParams);
    registerFallbackValue(tUpdateFriendListParams);
  });

  tearDown(() {
    bloc.close();
  });

  test('initialState should be UserInitial', () {
    expect(bloc.state, equals(UserInitial()));
  });

  group('GetAllUsersEvent', () {
    final tUsers = [tUserEntity, tUserEntity];

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UsersLoaded] when data is gotten successfully',
      build: () {
        when(() => mockGetAllUsersUseCase(any())).thenAnswer((_) async => Right(tUsers));
        return bloc;
      },
      act: (bloc) => bloc.add(GetAllUsersEvent(exclude: "1")),
      expect: () => [UsersLoaded(users: tUsers, hasMore: false)],
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UsersLoaded] with hasMore false when empty list',
      build: () {
        when(
          () => mockGetAllUsersUseCase(any()),
        ).thenAnswer((_) async => const Right(<UserEntity>[]));
        return bloc;
      },
      act: (bloc) => bloc.add(GetAllUsersEvent(exclude: "1")),
      expect: () => [const UsersLoaded(users: [], hasMore: false)],
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserError] when getting data fails',
      build: () {
        when(() => mockGetAllUsersUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(GetAllUsersEvent(exclude: "1")),
      expect: () => [UserError(failure: tServerFailure)],
    );
  });

  group('GetUserByIdEvent', () {
    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserLoaded] when get user by id is successful',
      build: () {
        when(() => mockGetUserByIdUseCase(any())).thenAnswer((_) async => Right(tUserEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(GetUserByIdEvent(id: tUserEntity.id)),
      expect: () => [UserLoading(), UserLoaded(user: tUserEntity)],
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserError] when get user by id fails',
      build: () {
        when(() => mockGetUserByIdUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(GetUserByIdEvent(id: tUserEntity.id)),
      expect: () => [UserLoading(), UserError(failure: tServerFailure)],
    );
  });

  group('UpdateUserEvent', () {
    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserLoaded] when update user is successful',
      build: () {
        when(() => mockUpdateUserUseCase(any())).thenAnswer((_) async => Right(tUserEntity));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateUserEvent(user: tUserEntity)),
      expect: () => [UserLoading(), UserLoaded(user: tUserEntity)],
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserError] when update user fails',
      build: () {
        when(() => mockUpdateUserUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateUserEvent(user: tUserEntity)),
      expect: () => [UserLoading(), UserError(failure: tServerFailure)],
    );
  });

  group('UpdateFriendListEvent', () {
    final updatedFriendIds = ['friend4', 'friend5'];
    blocTest<UserBloc, UserState>(
      'should emit [UserLoaded] with updated friend list when successful',
      build: () {
        when(() => mockUpdateFriendListUseCase(any())).thenAnswer((_) async => const Right(unit));
        return bloc;
      },
      seed: () => UserLoaded(user: tUserEntity),
      act:
          (bloc) =>
              bloc.add(UpdateFriendListEvent(userId: tUserEntity.id, friendIds: updatedFriendIds)),
      expect: () => [UserLoaded(user: tUserEntity.copyWith(friendsId: updatedFriendIds))],
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserError] when updating friend list fails',
      build: () {
        when(
          () => mockUpdateFriendListUseCase(any()),
        ).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act:
          (bloc) => bloc.add(
            UpdateFriendListEvent(
              userId: tUpdateFriendListParams.userId,
              friendIds: tUpdateFriendListParams.friendIds,
            ),
          ),
      expect: () => [UserError(failure: tServerFailure)],
    );
  });

  group('BookmarkPostEvent', () {
    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserLoaded] after bookmarking',
      build: () {
        when(() => mockBookmarkPostUseCase(any())).thenAnswer((_) async => const Right(unit));
        when(() => mockGetUserByIdUseCase(any())).thenAnswer((_) async => Right(tUserEntity));
        return bloc;
      },
      act:
          (bloc) => bloc.add(
            BookmarkPostEvent(
              userId: tBookmarkPostParams.userId,
              postId: tBookmarkPostParams.postId,
              bookmarkedPostIds: tBookmarkPostParams.bookmarkedPostIds,
            ),
          ),
      expect: () => [UserLoaded(user: tUserEntity)],
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserError] when bookmarking fails',
      build: () {
        when(() => mockBookmarkPostUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act:
          (bloc) => bloc.add(
            BookmarkPostEvent(
              userId: tBookmarkPostParams.userId,
              postId: tBookmarkPostParams.postId,
              bookmarkedPostIds: tBookmarkPostParams.bookmarkedPostIds,
            ),
          ),
      expect: () => [UserError(failure: tServerFailure)],
    );

    blocTest<UserBloc, UserState>(
      'should emit [UserLoading, UserError] when getting user details fails',
      build: () {
        when(() => mockBookmarkPostUseCase(any())).thenAnswer((_) async => const Right(unit));
        when(() => mockGetUserByIdUseCase(any())).thenAnswer((_) async => Left(tServerFailure));
        return bloc;
      },
      act:
          (bloc) => bloc.add(
            BookmarkPostEvent(
              userId: tBookmarkPostParams.userId,
              postId: tBookmarkPostParams.postId,
              bookmarkedPostIds: tBookmarkPostParams.bookmarkedPostIds,
            ),
          ),
      expect: () => [UserError(failure: tServerFailure)],
    );
  });
}
