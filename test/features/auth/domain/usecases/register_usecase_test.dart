import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late RegisterUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = RegisterUseCase(mockAuthRepository);
    registerFallbackValue(tRegisterParams);
  });
  test('should get auth from the repository after register', () async {
    // Arrange
    when(() => mockAuthRepository.register(any())).thenAnswer((_) async => Right(tAuthEntity));

    // Act
    final result = await usecase(tRegisterParams);

    // Assert
    expect(result, Right(tAuthEntity));
    verify(() => mockAuthRepository.register(tRegisterParams));
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
