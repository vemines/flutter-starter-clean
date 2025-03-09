import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../user/data/models/user_model.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/update_password_usecase.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(LoginParams params);
  Future<UserModel> register(RegisterParams params);
  Future<void> updateUserPassword(UpdateUserPasswordParams params);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  AuthRemoteDataSourceImpl({required this.firestore, required this.firebaseAuth});

  @override
  Future<UserModel> login(LoginParams params) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );
      if (userCredential.user == null) throw ServerException(message: "No user in userCredential");
      final user = userCredential.user!;
      final userDoc = await firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        final userModel = UserModel.newUser(
          id: user.uid,
          fullName: user.displayName ?? params.email.split('@')[0],
          email: params.email,
        );
        await firestore.collection('users').doc(user.uid).set(userModel.toFirebaseDoc());

        return userModel;
      }

      return UserModel.fromFirestore(userDoc);
    } catch (e, s) {
      handleFirebaseException(e, s, 'login');
    }
  }

  @override
  Future<UserModel> register(RegisterParams params) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      if (userCredential.user == null) throw ServerException(message: "No user in userCredential");
      final user = userCredential.user!;

      final userModel = UserModel.newUser(
        id: user.uid,
        fullName: user.displayName ?? params.email.split('@')[0],
        email: params.email,
      );
      await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirebaseDoc());

      return userModel;
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'register');
    }
  }

  @override
  Future<void> updateUserPassword(UpdateUserPasswordParams params) async {
    try {
      if (firebaseAuth.currentUser == null) return;
      await firebaseAuth.currentUser!.updatePassword(params.newPassword);
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'updateUserPassword');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e, s) {
      throw handleFirebaseException(e, s, 'logout');
    }
  }
}
