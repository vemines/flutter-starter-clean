import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/comment/domain/usecases/delete_comment_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late DeleteCommentUseCase usecase;
  late MockCommentRepository mockCommentRepository;

  setUp(() {
    mockCommentRepository = MockCommentRepository();
    usecase = DeleteCommentUseCase(mockCommentRepository);
    registerFallbackValue(tCommentEntity);
  });
  test('should delete comment from the repository', () async {
    // Arrange
    when(
      () => mockCommentRepository.deleteComment(any()),
    ).thenAnswer((_) async => const Right(unit));

    // Act
    final result = await usecase(tCommentEntity);

    // Assert
    expect(result, const Right(unit));
    verify(() => mockCommentRepository.deleteComment(tCommentEntity));
    verifyNoMoreInteractions(mockCommentRepository);
  });
}
