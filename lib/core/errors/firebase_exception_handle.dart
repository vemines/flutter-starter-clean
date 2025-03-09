part of 'exceptions.dart';

Never handleFirebaseException(Object e, StackTrace s, String methodName) {
  if (e is FirebaseAuthException) {
    handleFirebaseAuthException(e, s, methodName);
  }

  if (e is FirebaseException) {
    throw ServerException(
      message: 'Firebase Error at $methodName: ${e.message ?? ''}',
      stackTrace: s,
    );
  }
  throw ServerException(message: 'Error at $methodName: $e ', stackTrace: s);
}

Never handleFirebaseAuthException(Object e, StackTrace s, String methodName) {
  if (e is FirebaseAuthException) {
    if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'weak-password') {
      throw InvalidCredentialsException(message: e.code);
    }
    throw ServerException(
      message: 'Firebase Auth Error occur in $methodName: ${e.code}: ${e.message ?? ''}',
      stackTrace: s,
    );
  }
  throw ServerException(message: 'Error occur in $methodName: $e ', stackTrace: s);
}
