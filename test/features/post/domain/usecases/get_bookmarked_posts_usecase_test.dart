import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/get_post_by_id_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late GetPostByIdUseCase usecase;
  late MockPostRepository mockPostRepository;

  setUp(() {
    mockPostRepository = MockPostRepository();
    usecase = GetPostByIdUseCase(mockPostRepository);
    registerFallbackValue(tPostIdParams);
  });

  test('should get post by id from the repository', () async {
    // Arrange
    when(() => mockPostRepository.getPostById(any())).thenAnswer((_) async => Right(tPostEntity));

    // Act
    final result = await usecase(tPostIdParams);

    // Assert
    expect(result, Right(tPostEntity));
    verify(() => mockPostRepository.getPostById(tPostIdParams));
    verifyNoMoreInteractions(mockPostRepository);
  });
}
