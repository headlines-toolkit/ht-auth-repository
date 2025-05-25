// ignore_for_file: prefer_const_constructors
// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:ht_auth_client/ht_auth_client.dart';
import 'package:ht_auth_repository/ht_auth_repository.dart';
import 'package:ht_shared/ht_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock HtAuthClient
class MockHtAuthClient extends Mock implements HtAuthClient {}

// Mock User
class MockUser extends Mock implements User {}

void main() {
  group('HtAuthRepository', () {
    late HtAuthClient mockAuthClient;
    late HtAuthRepository authRepository;

    setUp(() {
      mockAuthClient = MockHtAuthClient();
      authRepository = HtAuthRepository(authClient: mockAuthClient);
    });

    test('can be instantiated', () {
      expect(authRepository, isNotNull);
    });

    group('authStateChanges', () {
      test('returns the authStateChanges stream from the client', () {
        final streamController = StreamController<User?>();
        when(() => mockAuthClient.authStateChanges)
            .thenAnswer((_) => streamController.stream);

        expect(authRepository.authStateChanges,
            equals(streamController.stream));

        streamController.close();
      });
    });

    group('getCurrentUser', () {
      test('delegates to client and returns user on success', () async {
        final mockUser = MockUser();
        when(() => mockAuthClient.getCurrentUser())
            .thenAnswer((_) async => mockUser);

        final user = await authRepository.getCurrentUser();

        expect(user, equals(mockUser));
        verify(() => mockAuthClient.getCurrentUser()).called(1);
      });

      test('delegates to client and re-throws HtHttpException on failure',
          () async {
        final exception = NetworkException();
        when(() => mockAuthClient.getCurrentUser()).thenThrow(exception);

        expect(
          () => authRepository.getCurrentUser(),
          throwsA(equals(exception)),
        );
        verify(() => mockAuthClient.getCurrentUser()).called(1);
      });
    });

    group('requestSignInCode', () {
      test('delegates to client on success', () async {
        const email = 'test@example.com';
        when(() => mockAuthClient.requestSignInCode(email))
            .thenAnswer((_) async => Future.value());

        await authRepository.requestSignInCode(email);

        verify(() => mockAuthClient.requestSignInCode(email)).called(1);
      });

      test('delegates to client and re-throws HtHttpException on failure',
          () async {
        const email = 'test@example.com';
        final exception = InvalidInputException('Invalid email');
        when(() => mockAuthClient.requestSignInCode(email))
            .thenThrow(exception);

        expect(
          () => authRepository.requestSignInCode(email),
          throwsA(equals(exception)),
        );
        verify(() => mockAuthClient.requestSignInCode(email)).called(1);
      });
    });

    group('verifySignInCode', () {
      test('delegates to client and returns user on success', () async {
        const email = 'test@example.com';
        const code = '123456';
        final mockUser = MockUser();
        when(() => mockAuthClient.verifySignInCode(email, code))
            .thenAnswer((_) async => mockUser);

        final user = await authRepository.verifySignInCode(email, code);

        expect(user, equals(mockUser));
        verify(() => mockAuthClient.verifySignInCode(email, code)).called(1);
      });

      test('delegates to client and re-throws HtHttpException on failure',
          () async {
        const email = 'test@example.com';
        const code = '123456';
        final exception = AuthenticationException('Invalid code');
        when(() => mockAuthClient.verifySignInCode(email, code))
            .thenThrow(exception);

        expect(
          () => authRepository.verifySignInCode(email, code),
          throwsA(equals(exception)),
        );
        verify(() => mockAuthClient.verifySignInCode(email, code)).called(1);
      });
    });

    group('signInAnonymously', () {
      test('delegates to client and returns user on success', () async {
        final mockUser = MockUser();
        when(() => mockAuthClient.signInAnonymously())
            .thenAnswer((_) async => mockUser);

        final user = await authRepository.signInAnonymously();

        expect(user, equals(mockUser));
        verify(() => mockAuthClient.signInAnonymously()).called(1);
      });

      test('delegates to client and re-throws HtHttpException on failure',
          () async {
        final exception = ServerException('Server error');
        when(() => mockAuthClient.signInAnonymously()).thenThrow(exception);

        expect(
          () => authRepository.signInAnonymously(),
          throwsA(equals(exception)),
        );
        verify(() => mockAuthClient.signInAnonymously()).called(1);
      });
    });

    group('signOut', () {
      test('delegates to client on success', () async {
        when(() => mockAuthClient.signOut())
            .thenAnswer((_) async => Future.value());

        await authRepository.signOut();

        verify(() => mockAuthClient.signOut()).called(1);
      });

      test('delegates to client and re-throws HtHttpException on failure',
          () async {
        final exception = OperationFailedException('Sign out failed');
        when(() => mockAuthClient.signOut()).thenThrow(exception);

        expect(
          () => authRepository.signOut(),
          throwsA(equals(exception)),
        );
        verify(() => mockAuthClient.signOut()).called(1);
      });
    });
  });
}
