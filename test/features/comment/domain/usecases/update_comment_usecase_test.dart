import 'package:dartz/dartz.dart';
import 'package:flutter_starter_clean/features/comment/domain/usecases/update_comment_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../mocks.dart';

void main() {
  late UpdateCommentUseCase usecase;
  late MockCommentRepository mockCommentRepository;

  setUp(() {
    mockCommentRepository = MockCommentRepository();
    usecase = UpdateCommentUseCase(mockCommentRepository);
    registerFallbackValue(tUpdatedCommentEntity);
  });

  test('should return updated comment from the repository', () async {
    // Arrange
    when(
      () => mockCommentRepository.updateComment(any()),
    ).thenAnswer((_) async => Right(tUpdatedCommentEntity));

    // Act
    final result = await usecase(tCommentEntity);

    // Assert
    expect(result, Right(tUpdatedCommentEntity));
    verify(() => mockCommentRepository.updateComment(tCommentEntity));
    verifyNoMoreInteractions(mockCommentRepository);
  });
}
