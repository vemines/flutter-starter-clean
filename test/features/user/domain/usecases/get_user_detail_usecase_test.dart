import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/user/domain/usecases/get_user_detail_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late GetUserDetailUseCase usecase;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    usecase = GetUserDetailUseCase(mockUserRepository);
    registerFallbackValue(tUserIdParams);
  });
  test('should get user detail from the repository', () async {
    // Arrange
    when(
      () => mockUserRepository.getUserDetail(any()),
    ).thenAnswer((_) async => Right(tUserDetailEntity));

    // Act
    final result = await usecase(tUserIdParams);

    // Assert
    expect(result, Right(tUserDetailEntity));
    verify(() => mockUserRepository.getUserDetail(tUserIdParams));
    verifyNoMoreInteractions(mockUserRepository);
  });
}
