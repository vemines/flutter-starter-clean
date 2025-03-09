import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/post/domain/usecases/get_all_posts_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late GetAllPostsUseCase usecase;
  late MockPostRepository mockPostRepository;

  setUp(() {
    mockPostRepository = MockPostRepository();
    usecase = GetAllPostsUseCase(mockPostRepository);
    registerFallbackValue(tPaginationParams);
  });

  test('should get all posts from the repository', () async {
    // Arrange
    when(() => mockPostRepository.getAllPosts(any())).thenAnswer((_) async => Right(tPostEntities));

    // Act
    final result = await usecase(tPaginationParams);

    // Assert
    expect(result, Right(tPostEntities));
    verify(() => mockPostRepository.getAllPosts(tPaginationParams));
    verifyNoMoreInteractions(mockPostRepository);
  });
}
