import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/update_post_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late UpdatePostUseCase usecase;
  late MockPostRepository mockPostRepository;
  setUp(() {
    mockPostRepository = MockPostRepository();
    usecase = UpdatePostUseCase(mockPostRepository);
    registerFallbackValue(tPostEntityUpdate);
  });
  test('should return updated post from the repository', () async {
    // Arrange
    when(
      () => mockPostRepository.updatePost(any()),
    ).thenAnswer((_) async => Right(tPostEntityUpdate));

    // Act
    final result = await usecase(tPostEntityUpdate);

    // Assert
    expect(result, Right(tPostEntityUpdate));
    verify(() => mockPostRepository.updatePost(tPostEntityUpdate));
    verifyNoMoreInteractions(mockPostRepository);
  });
}
