import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/logs.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/params.dart';
import '../../domain/entities/user_detail_entity.dart';
import '../../domain/usecases/get_user_detail_usecase.dart';

part 'user_detail_event.dart';
part 'user_detail_state.dart';

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final GetUserDetailUseCase getUserDetailUseCase;
  final LogService logService;

  UserDetailBloc({required this.getUserDetailUseCase, required this.logService})
    : super(UserDetailInitial()) {
    on<GetUserDetailEvent>(_onGetUserDetail);
  }

  Future<void> _onGetUserDetail(GetUserDetailEvent event, Emitter<UserDetailState> emit) async {
    final result = await getUserDetailUseCase(IdParams(id: event.userId));
    emit(
      result.fold((failure) {
        logService.w(
          '$failure occur at _onGetUserById(GetUserByIdEvent event, Emitter<UserState> emit)',
        );
        return UserDetailError(failure: failure);
      }, (userDetail) => UserDetailLoaded(userDetail: userDetail)),
    );
  }
}
