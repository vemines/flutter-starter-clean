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
    registerFallbackValue(tAuthModel);
  });

  final String kCachedAuth = AuthLocalDataSourceImpl.kCachedAuth;

  group('cacheAuth', () {
    test('should call FlutterSecureStorage to cache the data', () async {
      // Arrange
      when(
        () => mockFlutterSecureStorage.write(
          key: kCachedAuth,
          value: json.encode(tAuthModel.toJson()),
        ),
      ).thenAnswer((_) async => {});

      // Act
      await dataSource.cacheAuth(tAuthModel);

      // Assert
      verify(
        () => mockFlutterSecureStorage.write(
          key: kCachedAuth,
          value: json.encode(tAuthModel.toJson()),
        ),
      );
    });
  });

  group('getCachedAuth', () {
    test('should return AuthModel from SharedPreferences when there is one in the cache', () async {
      // Arrange
      when(
        () => mockFlutterSecureStorage.read(key: kCachedAuth),
      ).thenAnswer((_) async => jsonEncode(tAuthModel.toJson()));

      // Act
      final result = await dataSource.getCachedAuth();

      // Assert
      verify(() => mockFlutterSecureStorage.read(key: kCachedAuth));
      expect(result, equals(tAuthModel));
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
      await dataSource.clearCachedAuth();

      // Assert
      verify(() => mockFlutterSecureStorage.delete(key: kCachedAuth));
    });
  });
}
