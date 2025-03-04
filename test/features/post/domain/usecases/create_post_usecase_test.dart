import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/create_post_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late CreatePostUseCase usecase;
  late MockPostRepository mockPostRepository;
  setUp(() {
    mockPostRepository = MockPostRepository();
    usecase = CreatePostUseCase(mockPostRepository);
    registerFallbackValue(tPostEntity);
    registerFallbackValue(tCreatePostParams);
  });
  test('should return created post from the repository', () async {
    // Arrange
    when(() => mockPostRepository.createPost(any())).thenAnswer((_) async => Right(tPostEntity));

    // Act
    final result = await usecase(tCreatePostParams);

    // Assert
    expect(result, Right(tPostEntity));
    verify(() => mockPostRepository.createPost(tCreatePostParams));
    verifyNoMoreInteractions(mockPostRepository);
  });
}
