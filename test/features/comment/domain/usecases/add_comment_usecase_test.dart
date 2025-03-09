import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/comment/domain/usecases/add_comment_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late AddCommentUseCase usecase;
  late MockCommentRepository mockCommentRepository;

  setUp(() {
    mockCommentRepository = MockCommentRepository();
    usecase = AddCommentUseCase(mockCommentRepository);
    registerFallbackValue(tAddCommentParams);
  });

  test('should add a comment to the repository', () async {
    // Arrange
    when(
      () => mockCommentRepository.addComment(any()),
    ).thenAnswer((_) async => Right(tCommentEntity));

    // Act
    final result = await usecase(tAddCommentParams);

    // Assert
    expect(result, Right(tCommentEntity));
    verify(() => mockCommentRepository.addComment(tAddCommentParams));
    verifyNoMoreInteractions(mockCommentRepository);
  });
}
