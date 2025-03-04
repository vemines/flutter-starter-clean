import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/logs.dart';
import '../../../../core/constants/pagination.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/bookmark_post_usecase.dart';
import '../../domain/usecases/get_all_users_usecase.dart';
import '../../domain/usecases/get_user_by_id_usecase.dart';
import '../../domain/usecases/update_friend_list_usecase.dart';
import '../../domain/usecases/update_user_usecase.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetAllUsersUseCase getAllUsersUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final UpdateFriendListUseCase updateFriendListUseCase;
  final BookmarkPostUseCase bookmarkPostUseCase;
  final LogService logService;

  UserBloc({
    required this.getAllUsersUseCase,
    required this.getUserByIdUseCase,
    required this.updateUserUseCase,
    required this.updateFriendListUseCase,
    required this.bookmarkPostUseCase,
    required this.logService,
  }) : super(UserInitial()) {
    on<GetAllUsersEvent>(_onGetAllUsers);
    on<GetUserByIdEvent>(_onGetUserById);
    on<UpdateUserEvent>(_onUpdateUser);
    on<UpdateFriendListEvent>(_onUpdateFriendList);
    on<BookmarkPostEvent>(_onBookmarkPostUsers);
  }

  final _allUsersPS = PaginationStorage();

  Future<void> _onGetAllUsers(GetAllUsersEvent event, Emitter<UserState> emit) async {
    final results = await getAllUsersUseCase(
      GetAllUsersWithExcludeParams(
        excludeId: event.exclude,
        page: _allUsersPS.currentPage,
        limit: _allUsersPS.limit,
      ),
    );

    results.fold(
      (failure) {
        logService.w(
          '$failure occur at _onGetAllUsers(GetAllUsersEvent event, Emitter<UserState> emit)',
        );
        emit(UserError(failure: failure));
      },
      (users) {
        if (users.isEmpty) {
          _allUsersPS.hasMore = false;
          if (state is UsersLoaded) {
            emit((state as UsersLoaded).copyWith(hasMore: false));
            return;
          } else {
            emit(UsersLoaded(users: [], hasMore: false));
            return;
          }
        }
        if (_allUsersPS.currentPage == 1 && users.length < _allUsersPS.limit) {
          _allUsersPS.hasMore = false;
        }
        _allUsersPS.currentPage++;

        if (state is UsersLoaded) {
          emit((state as UsersLoaded).copyWith(users: users));
          return;
        } else {
          emit(UsersLoaded(users: users, hasMore: _allUsersPS.hasMore));
          return;
        }
      },
    );
  }

  Future<void> _onGetUserById(GetUserByIdEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    final result = await getUserByIdUseCase(IdParams(id: event.id));
    emit(
      result.fold((failure) {
        logService.w(
          '$failure occur at _onGetUserById(GetUserByIdEvent event, Emitter<UserState> emit)',
        );
        return UserError(failure: failure);
      }, (user) => UserLoaded(user: user)),
    );
  }

  Future<void> _onUpdateUser(UpdateUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    final result = await updateUserUseCase(event.user);
    emit(
      result.fold((failure) {
        logService.w(
          '$failure occur at _onUpdateUser(UpdateUserEvent event, Emitter<UserState> emit)',
        );
        return UserError(failure: failure);
      }, (user) => UserLoaded(user: user)),
    );
  }

  Future<void> _onUpdateFriendList(UpdateFriendListEvent event, Emitter<UserState> emit) async {
    final result = await updateFriendListUseCase(
      UpdateFriendListParams(userId: event.userId, friendIds: event.friendIds),
    );
    result.fold(
      (failure) {
        logService.w(
          '$failure occur at _onUpdateFriendList(UpdateFriendListEvent event, Emitter<UserState> emit)',
        );
        emit(UserError(failure: failure));
      },
      (_) => {
        if (state is UserLoaded)
          {emit(UserLoaded(user: (state as UserLoaded).user.copyWith(friendsId: event.friendIds)))},
      },
    );
  }

  Future<void> _onBookmarkPostUsers(BookmarkPostEvent event, Emitter<UserState> emit) async {
    final result = await bookmarkPostUseCase(
      BookmarkPostParams(
        postId: event.postId,
        bookmarkedPostIds: event.bookmarkedPostIds,
        userId: event.userId,
      ),
    );

    await result.fold(
      (failure) {
        logService.w(
          '$failure occur at _onBookmarkPostUsers(BookmarkPostEvent event, Emitter<UserState> emit)',
        );
        emit(UserError(failure: failure));
      },
      (_) async {
        await _bookmarkPost(event.userId, emit);
      },
    );
  }

  Future<void> _bookmarkPost(String userId, Emitter<UserState> emit) async {
    final result = await getUserByIdUseCase(IdParams(id: userId));
    emit(
      result.fold((failure) {
        logService.w('$failure occur at _getUserById(String userId, Emitter<UserState> emit)');
        return UserError(failure: failure);
      }, (user) => UserLoaded(user: user)),
    );
  }
}
