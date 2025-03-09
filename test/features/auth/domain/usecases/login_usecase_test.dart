import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
    registerFallbackValue(tLoginParams);
  });

  test('should get auth from the repository', () async {
    // Arrange
    when(() => mockAuthRepository.login(any())).thenAnswer((_) async => Right(tUserEntity));

    // Act
    final result = await usecase(tLoginParams);

    // Assert
    expect(result, Right(tUserEntity));
    verify(() => mockAuthRepository.login(tLoginParams));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
