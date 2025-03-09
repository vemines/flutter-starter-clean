import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/user/domain/usecases/get_all_users_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late GetAllUsersUseCase usecase;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    usecase = GetAllUsersUseCase(mockUserRepository);
  });
  setUpAll(() {
    registerFallbackValue(tGetAllUsersWithExcludeParams);
  });

  test('should get all users from the repository', () async {
    // Arrange
    when(() => mockUserRepository.getAllUsers(any())).thenAnswer((_) async => Right(tUserEntities));

    // Act
    final result = await usecase(tGetAllUsersWithExcludeParams);

    // Assert
    expect(result, Right(tUserEntities));
    verify(() => mockUserRepository.getAllUsers(tGetAllUsersWithExcludeParams));
    verifyNoMoreInteractions(mockUserRepository);
  });
}
