import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/core/usecase/params.dart';
import 'package:flutter_starter_clean/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late LogoutUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutUseCase(mockAuthRepository);
  });

  test('should call logout from the repository', () async {
    // Arrange
    when(() => mockAuthRepository.logout()).thenAnswer((_) async => const Right(unit));

    // Act
    final result = await usecase(NoParams());

    // Assert
    expect(result, const Right(unit));
    verify(() => mockAuthRepository.logout());
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
