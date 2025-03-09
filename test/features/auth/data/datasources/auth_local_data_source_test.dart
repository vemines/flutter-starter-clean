import 'package:flutter_starter_clean/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'dart:convert';

import '../../../../mocks.dart';

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockFlutterSecureStorage mockFlutterSecureStorage;

  setUp(() {
    mockFlutterSecureStorage = MockFlutterSecureStorage();
    dataSource = AuthLocalDataSourceImpl(secureStorage: mockFlutterSecureStorage);
    registerFallbackValue(tUserModel);
  });

  final String kCachedAuth = AuthLocalDataSourceImpl.kCachedAuth;

  group('cacheAuth', () {
    test('should call FlutterSecureStorage to cache the data', () async {
      // Arrange
      when(
        () => mockFlutterSecureStorage.write(
          key: kCachedAuth,
          value: json.encode(tUserModel.toJson()),
        ),
      ).thenAnswer((_) async => {});

      // Act
      await dataSource.cacheAuth(tUserModel);

      // Assert
      verify(
        () => mockFlutterSecureStorage.write(
          key: kCachedAuth,
          value: json.encode(tUserModel.toJson()),
        ),
      );
    });
  });

  group('getCachedAuth', () {
    test('should return UserModel from SharedPreferences when there is one in the cache', () async {
      // Arrange
      when(
        () => mockFlutterSecureStorage.read(key: kCachedAuth),
      ).thenAnswer((_) async => jsonEncode(tUserModel.toJson()));

      // Act
      final result = await dataSource.getCachedAuth();

      // Assert
      verify(() => mockFlutterSecureStorage.read(key: kCachedAuth));
      expect(result, equals(tUserModel));
    });

    test('should return null when there is no cached value', () async {
      // Arrange
      when(() => mockFlutterSecureStorage.read(key: kCachedAuth)).thenAnswer((_) async => null);

      // Act
      final result = await dataSource.getCachedAuth();

      // Assert
      verify(() => mockFlutterSecureStorage.read(key: kCachedAuth));
      expect(result, isNull);
    });
  });

  group('clearCachedAuth', () {
    test('should call SharedPreferences to remove the cached data', () async {
      // Arrange
      when(() => mockFlutterSecureStorage.delete(key: kCachedAuth)).thenAnswer((_) async => {});

      // Act
      await dataSource.logout();

      // Assert
      verify(() => mockFlutterSecureStorage.delete(key: kCachedAuth));
    });
  });
}
