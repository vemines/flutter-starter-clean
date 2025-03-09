import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_starter_clean/core/errors/exceptions.dart';
import 'package:flutter_starter_clean/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_starter_clean/features/user/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../mocks.dart';

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockFirebaseAuth mockFirebaseAuth;
  late FirebaseFirestore mockFirebaseFirestore;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = FakeFirebaseFirestore();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();

    dataSource = AuthRemoteDataSourceImpl(
      firebaseAuth: mockFirebaseAuth,
      firestore: mockFirebaseFirestore,
    );
  });

  final tFirebaseAuthException = FirebaseAuthException(code: 'code');

  setUpAll(() {
    registerFallbackValue(tLoginParams);
    registerFallbackValue(tRegisterParams);
    registerFallbackValue(tUpdateUserPasswordParams);
  });

  group('login', () {
    test('should return UserModel on successful login', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: "email"),
          password: any(named: "password"),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn(tUserModel.id);
      when(() => mockUser.displayName).thenReturn(tUserModel.fullName);
      when(() => mockUser.email).thenReturn(tUserModel.email);
      when(() => mockUser.photoURL).thenReturn('avatar_url');

      await mockFirebaseFirestore
          .collection('users')
          .doc(tUserModel.id)
          .set(tUserModel.toFirebaseDoc());

      // Act
      final result = await dataSource.login(tLoginParams);

      // Assert
      expect(result, isA<UserModel>());
      expect(result.id, tUserModel.id);
      verify(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: tLoginParams.email,
          password: tLoginParams.password,
        ),
      ).called(1);
    });

    test('should create a new user document if it doesnt exist and return UserModel', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: "email"),
          password: any(named: "password"),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn(tUserModel.id);
      when(() => mockUser.displayName).thenReturn(tLoginParams.email.split('@')[0]);
      when(() => mockUser.email).thenReturn(tUserModel.email);
      when(() => mockUser.photoURL).thenReturn('avatar_url');

      // Act
      final result = await dataSource.login(tLoginParams);

      // Assert
      expect(result, isA<UserModel>());

      // Verify that the user document now exists.
      final docSnapshot = await mockFirebaseFirestore.collection('users').doc(tUserModel.id).get();
      expect(docSnapshot.exists, isTrue);
      expect(
        docSnapshot.data()!['fullName'],
        tLoginParams.email.split('@')[0],
      ); // Corrected assertion
    });

    test('should throw InvalidCredentialsException for auth failures', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: "email"),
          password: any(named: "password"),
        ),
      ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      // Act & Assert
      expect(() => dataSource.login(tLoginParams), throwsA(isA<InvalidCredentialsException>()));
    });

    test('should throw ServerException for other failures', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.signInWithEmailAndPassword(
          email: any(named: "email"),
          password: any(named: "password"),
        ),
      ).thenThrow(tFirebaseAuthException);

      // Act & Assert
      expect(() => dataSource.login(tLoginParams), throwsA(isA<ServerException>()));
    });
  });
  group('register', () {
    test('should return UserModel on successful registration', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: "email"),
          password: any(named: "password"),
        ),
      ).thenAnswer((_) async => mockUserCredential);

      when(() => mockUserCredential.user).thenReturn(mockUser);

      when(() => mockUser.uid).thenReturn(tUserModel.id);

      // Act
      final result = await dataSource.register(tRegisterParams);

      // Assert
      expect(result, isA<UserModel>());
      verify(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: tRegisterParams.email,
          password: tRegisterParams.password,
        ),
      ).called(1);
      // Verify user document creation in Firestore.
      final docSnapshot = await mockFirebaseFirestore.collection('users').doc(tUserModel.id).get();
      expect(docSnapshot.exists, isTrue);
    });

    test('should throw ServerException for auth failures', () async {
      // Arrange
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: "email"),
          password: any(named: "password"),
        ),
      ).thenThrow(FirebaseAuthException(code: 'weak-password'));

      // Act & Assert
      expect(() => dataSource.register(tRegisterParams), throwsA(isA<ServerException>()));
    });
    test('should throw ServerException on Firestore errors', () async {
      when(
        () => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: any(named: "email"),
          password: any(named: "password"),
        ),
      ).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn(tUserEntity.id);

      when(
        () => mockFirebaseFirestore.collection('user').doc(mockUserCredential.user!.uid).set(any()),
      ).thenThrow(tFirebaseException);

      expect(() => dataSource.register(tRegisterParams), throwsA(isA<ServerException>()));
    });
  });

  group('updateUserPassword', () {
    test('should update user password successfully', () async {
      // Arrange
      when(
        () => mockUser.updatePassword(tUpdateUserPasswordParams.newPassword),
      ).thenAnswer((_) async {});

      // Act
      await dataSource.updateUserPassword(tUpdateUserPasswordParams);

      // Assert
      verify(
        () => mockFirebaseAuth.currentUser!.updatePassword(tUpdateUserPasswordParams.newPassword),
      ).called(1);
    });

    test('should throw ServerException for auth failures', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.updatePassword(any())).thenThrow(tFirebaseAuthException);

      // Act & Assert
      expect(
        () => dataSource.updateUserPassword(tUpdateUserPasswordParams),
        throwsA(isA<ServerException>()),
      );
    });
  });
  group('logout', () {
    test('should sign out successfully', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act
      await dataSource.logout();

      // Assert
      verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('should throw ServerException for sign-out failures', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut()).thenThrow(tFirebaseAuthException);

      // Act & Assert
      expect(() => dataSource.logout(), throwsA(isA<ServerException>()));
    });
  });
}
