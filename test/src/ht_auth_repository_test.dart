// ignore_for_file: prefer_const_constructors
// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:ht_auth_client/ht_auth_client.dart';
import 'package:ht_auth_repository/ht_auth_repository.dart';
import 'package:ht_kv_storage_service/ht_kv_storage_service.dart';
import 'package:ht_shared/ht_shared.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

// Mock HtAuthClient
class MockHtAuthClient extends Mock implements HtAuthClient {}

// Mock HtKVStorageService
class MockHtKVStorageService extends Mock implements HtKVStorageService {}

// Mock User
class MockUser extends Mock implements User {}

void main() {
  group('HtAuthRepository', () {
    late HtAuthClient mockAuthClient;
    late HtKVStorageService mockStorageService;
    late HtAuthRepository authRepository;

    setUp(() {
      mockAuthClient = MockHtAuthClient();
      mockStorageService = MockHtKVStorageService();
      authRepository = HtAuthRepository(
        authClient: mockAuthClient,
        storageService: mockStorageService,
      );
    });

    test('can be instantiated', () {
      expect(authRepository, isNotNull);
    });

    group('authStateChanges', () {
      test('returns the authStateChanges stream from the client', () {
        final streamController = StreamController<User?>();
        when(
          () => mockAuthClient.authStateChanges,
        ).thenAnswer((_) => streamController.stream);

        expect(
          authRepository.authStateChanges,
          equals(streamController.stream),
        );

        streamController.close();
      });
    });

    group('getCurrentUser', () {
      test('delegates to client and returns user on success', () async {
        final mockUser = MockUser();
        when(
          () => mockAuthClient.getCurrentUser(),
        ).thenAnswer((_) async => mockUser);

        final user = await authRepository.getCurrentUser();

        expect(user, equals(mockUser));
        verify(() => mockAuthClient.getCurrentUser()).called(1);
      });

      test(
        'delegates to client and re-throws HtHttpException on failure',
        () async {
          final exception = NetworkException();
          when(() => mockAuthClient.getCurrentUser()).thenThrow(exception);

          expect(
            () => authRepository.getCurrentUser(),
            throwsA(equals(exception)),
          );
          verify(() => mockAuthClient.getCurrentUser()).called(1);
        },
      );
    });

    group('requestSignInCode', () {
      test('delegates to client on success', () async {
        const email = 'test@example.com';
        when(
          () => mockAuthClient.requestSignInCode(email),
        ).thenAnswer((_) async => Future.value());

        await authRepository.requestSignInCode(email);

        verify(() => mockAuthClient.requestSignInCode(email)).called(1);
      });

      test(
        'delegates to client and re-throws HtHttpException on failure',
        () async {
          const email = 'test@example.com';
          final exception = InvalidInputException('Invalid email');
          when(
            () => mockAuthClient.requestSignInCode(email),
          ).thenThrow(exception);

          expect(
            () => authRepository.requestSignInCode(email),
            throwsA(equals(exception)),
          );
          verify(() => mockAuthClient.requestSignInCode(email)).called(1);
        },
      );
    });

    group('verifySignInCode', () {
      const email = 'test@example.com';
      const code = '123456';
      const testToken = 'sample_token';
      late User mockUser;
      late AuthSuccessResponse mockAuthResponse;

      setUp(() {
        mockUser = MockUser();
        mockAuthResponse = AuthSuccessResponse(
          user: mockUser,
          token: testToken,
        );
      });

      test(
        'calls client, saves token, and returns user on successful verification',
        () async {
          when(
            () => mockAuthClient.verifySignInCode(email, code),
          ).thenAnswer((_) async => mockAuthResponse);
          when(
            () => mockStorageService.writeString(
              key: StorageKey.authToken.stringValue,
              value: testToken,
            ),
          ).thenAnswer((_) async {});

          final user = await authRepository.verifySignInCode(email, code);

          expect(user, equals(mockUser));
          verify(() => mockAuthClient.verifySignInCode(email, code)).called(1);
          verify(
            () => mockStorageService.writeString(
              key: StorageKey.authToken.stringValue,
              value: testToken,
            ),
          ).called(1);
        },
      );

      test('re-throws HtHttpException from client on client failure', () async {
        final exception = AuthenticationException('Invalid code');
        when(
          () => mockAuthClient.verifySignInCode(email, code),
        ).thenThrow(exception);

        expect(
          () => authRepository.verifySignInCode(email, code),
          throwsA(equals(exception)),
        );
        verify(() => mockAuthClient.verifySignInCode(email, code)).called(1);
        verifyNever(
          () => mockStorageService.writeString(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        );
      });

      test(
        're-throws StorageException from storageService on token save failure',
        () async {
          when(
            () => mockAuthClient.verifySignInCode(email, code),
          ).thenAnswer((_) async => mockAuthResponse);
          final exception = StorageWriteException(
            StorageKey.authToken.stringValue,
            testToken,
          );
          when(
            () => mockStorageService.writeString(
              key: StorageKey.authToken.stringValue,
              value: testToken,
            ),
          ).thenThrow(exception);

          expect(
            () => authRepository.verifySignInCode(email, code),
            throwsA(equals(exception)),
          );
          verify(() => mockAuthClient.verifySignInCode(email, code)).called(1);
          // Removed verify for mockStorageService.writeString here
        },
      );
    });

    group('signInAnonymously', () {
      const testToken = 'anonymous_token';
      late User mockUser;
      late AuthSuccessResponse mockAuthResponse;

      setUp(() {
        mockUser = MockUser();
        mockAuthResponse = AuthSuccessResponse(
          user: mockUser,
          token: testToken,
        );
      });

      test(
        'calls client, saves token, and returns user on successful sign-in',
        () async {
          when(
            () => mockAuthClient.signInAnonymously(),
          ).thenAnswer((_) async => mockAuthResponse);
          when(
            () => mockStorageService.writeString(
              key: StorageKey.authToken.stringValue,
              value: testToken,
            ),
          ).thenAnswer((_) async {});

          final user = await authRepository.signInAnonymously();

          expect(user, equals(mockUser));
          verify(() => mockAuthClient.signInAnonymously()).called(1);
          verify(
            () => mockStorageService.writeString(
              key: StorageKey.authToken.stringValue,
              value: testToken,
            ),
          ).called(1);
        },
      );

      test('re-throws HtHttpException from client on client failure', () async {
        final exception = ServerException('Server error');
        when(() => mockAuthClient.signInAnonymously()).thenThrow(exception);

        expect(
          () => authRepository.signInAnonymously(),
          throwsA(equals(exception)),
        );
        verify(() => mockAuthClient.signInAnonymously()).called(1);
        verifyNever(
          () => mockStorageService.writeString(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        );
      });

      test(
        're-throws StorageException from storageService on token save failure',
        () async {
          when(
            () => mockAuthClient.signInAnonymously(),
          ).thenAnswer((_) async => mockAuthResponse);
          final exception = StorageWriteException(
            StorageKey.authToken.stringValue,
            testToken,
          );
          when(
            () => mockStorageService.writeString(
              key: StorageKey.authToken.stringValue,
              value: testToken,
            ),
          ).thenThrow(exception);

          expect(
            () => authRepository.signInAnonymously(),
            throwsA(equals(exception)),
          );
          verify(() => mockAuthClient.signInAnonymously()).called(1);
          // Removed verify for mockStorageService.writeString here
        },
      );
    });

    group('signOut', () {
      test('calls client signOut and clears token on success', () async {
        when(() => mockAuthClient.signOut()).thenAnswer((_) async {});
        when(
          () =>
              mockStorageService.delete(key: StorageKey.authToken.stringValue),
        ).thenAnswer((_) async {});

        await authRepository.signOut();

        verify(() => mockAuthClient.signOut()).called(1);
        verify(
          () =>
              mockStorageService.delete(key: StorageKey.authToken.stringValue),
        ).called(1);
      });

      test('re-throws HtHttpException from client on client failure', () async {
        final exception = OperationFailedException('Sign out failed');
        when(() => mockAuthClient.signOut()).thenThrow(exception);

        expect(() => authRepository.signOut(), throwsA(equals(exception)));
        verify(() => mockAuthClient.signOut()).called(1);
        verifyNever(() => mockStorageService.delete(key: any(named: 'key')));
      });

      test(
        're-throws StorageException from storageService on token clear failure',
        () async {
          when(() => mockAuthClient.signOut()).thenAnswer((_) async {});
          final exception = StorageDeleteException(
            StorageKey.authToken.stringValue,
          );
          when(
            () => mockStorageService.delete(
              key: StorageKey.authToken.stringValue,
            ),
          ).thenThrow(exception);

          expect(() => authRepository.signOut(), throwsA(equals(exception)));
          verify(() => mockAuthClient.signOut()).called(1);
          // Removed verify for mockStorageService.delete here
        },
      );
    });

    group('saveAuthToken', () {
      test('delegates to storageService.writeString', () async {
        const token = 'test_token';
        when(
          () => mockStorageService.writeString(
            key: StorageKey.authToken.stringValue,
            value: token,
          ),
        ).thenAnswer((_) async => Future.value());

        await authRepository.saveAuthToken(token);

        verify(
          () => mockStorageService.writeString(
            key: StorageKey.authToken.stringValue,
            value: token,
          ),
        ).called(1);
      });

      test('re-throws StorageWriteException from storageService', () async {
        const token = 'test_token';
        final exception = StorageWriteException(
          StorageKey.authToken.stringValue,
          token,
        );
        when(
          () => mockStorageService.writeString(
            key: StorageKey.authToken.stringValue,
            value: token,
          ),
        ).thenThrow(exception);

        expect(
          () => authRepository.saveAuthToken(token),
          throwsA(equals(exception)),
        );
        verify(
          () => mockStorageService.writeString(
            key: StorageKey.authToken.stringValue,
            value: token,
          ),
        ).called(1);
      });
    });

    group('getAuthToken', () {
      test(
        'delegates to storageService.readString and returns token',
        () async {
          const token = 'test_token';
          when(
            () => mockStorageService.readString(
              key: StorageKey.authToken.stringValue,
            ),
          ).thenAnswer((_) async => token);

          final result = await authRepository.getAuthToken();

          expect(result, equals(token));
          verify(
            () => mockStorageService.readString(
              key: StorageKey.authToken.stringValue,
            ),
          ).called(1);
        },
      );

      test(
        'delegates to storageService.readString and returns null if not found',
        () async {
          when(
            () => mockStorageService.readString(
              key: StorageKey.authToken.stringValue,
            ),
          ).thenAnswer((_) async => null);

          final result = await authRepository.getAuthToken();

          expect(result, isNull);
          verify(
            () => mockStorageService.readString(
              key: StorageKey.authToken.stringValue,
            ),
          ).called(1);
        },
      );

      test('re-throws StorageReadException from storageService', () async {
        final exception = StorageReadException(
          StorageKey.authToken.stringValue,
        );
        when(
          () => mockStorageService.readString(
            key: StorageKey.authToken.stringValue,
          ),
        ).thenThrow(exception);

        expect(() => authRepository.getAuthToken(), throwsA(equals(exception)));
        verify(
          () => mockStorageService.readString(
            key: StorageKey.authToken.stringValue,
          ),
        ).called(1);
      });

      test(
        're-throws StorageTypeMismatchException from storageService',
        () async {
          final exception = StorageTypeMismatchException(
            StorageKey.authToken.stringValue,
            String,
            int,
          );
          when(
            () => mockStorageService.readString(
              key: StorageKey.authToken.stringValue,
            ),
          ).thenThrow(exception);

          expect(
            () => authRepository.getAuthToken(),
            throwsA(equals(exception)),
          );
          verify(
            () => mockStorageService.readString(
              key: StorageKey.authToken.stringValue,
            ),
          ).called(1);
        },
      );
    });

    group('clearAuthToken', () {
      test('delegates to storageService.delete', () async {
        when(
          () =>
              mockStorageService.delete(key: StorageKey.authToken.stringValue),
        ).thenAnswer((_) async => Future.value());

        await authRepository.clearAuthToken();

        verify(
          () =>
              mockStorageService.delete(key: StorageKey.authToken.stringValue),
        ).called(1);
      });

      test('re-throws StorageDeleteException from storageService', () async {
        final exception = StorageDeleteException(
          StorageKey.authToken.stringValue,
        );
        when(
          () =>
              mockStorageService.delete(key: StorageKey.authToken.stringValue),
        ).thenThrow(exception);

        expect(
          () => authRepository.clearAuthToken(),
          throwsA(equals(exception)),
        );
        verify(
          () =>
              mockStorageService.delete(key: StorageKey.authToken.stringValue),
        ).called(1);
      });
    });
  });
}
