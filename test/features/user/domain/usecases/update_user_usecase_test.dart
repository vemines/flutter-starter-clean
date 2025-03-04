import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/user/domain/usecases/update_user_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late UpdateUserUseCase usecase;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    usecase = UpdateUserUseCase(mockUserRepository);
  });

  setUpAll(() {
    registerFallbackValue(tUserEntity);
  });

  test('should return updated user from the repository', () async {
    // Arrange
    when(() => mockUserRepository.updateUser(any())).thenAnswer((_) async => Right(tUserModel));

    // Act
    final result = await usecase(tUserEntity);

    // Assert
    expect(result, Right(tUserModel));
    verify(() => mockUserRepository.updateUser(tUserEntity));
    verifyNoMoreInteractions(mockUserRepository);
  });
}
