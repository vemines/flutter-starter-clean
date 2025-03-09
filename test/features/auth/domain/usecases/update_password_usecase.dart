import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/auth/domain/usecases/update_password_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late UpdatePasswordUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = UpdatePasswordUseCase(mockAuthRepository);
  });

  test('should call UpdatePassword from the repository', () async {
    // Arrange
    final params = UpdateUserPasswordParams(newPassword: 'new_password', userId: '1');
    when(
      () => mockAuthRepository.updateUserPassword(any()),
    ).thenAnswer((_) async => const Right(unit));

    // Act
    final result = await usecase(params);

    // Assert
    expect(result, const Right(unit));
    verify(() => mockAuthRepository.updateUserPassword(params));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
