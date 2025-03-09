import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/comment/domain/usecases/get_comments_by_post_id_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late GetCommentsByPostIdUseCase usecase;
  late MockCommentRepository mockCommentRepository;

  setUp(() {
    mockCommentRepository = MockCommentRepository();
    usecase = GetCommentsByPostIdUseCase(mockCommentRepository);
    registerFallbackValue(tGetCommentsParams);
  });

  test('should get comments by post ID from the repository', () async {
    // Arrange
    when(
      () => mockCommentRepository.getCommentsByPostId(any()),
    ).thenAnswer((_) async => Right(tCommentEntities));

    // Act
    final result = await usecase(tGetCommentsParams);

    // Assert
    expect(result, Right(tCommentEntities));
    verify(() => mockCommentRepository.getCommentsByPostId(tGetCommentsParams));
    verifyNoMoreInteractions(mockCommentRepository);
  });
}
