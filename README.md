# ht_auth_repository

![coverage: percentage](https://img.shields.io/badge/coverage-100-green)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: PolyForm Free Trial](https://img.shields.io/badge/License-PolyForm%20Free%20Trial-blue)](https://polyformproject.org/licenses/free-trial/1.0.0)

A repository package that provides an abstraction layer over authentication operations. It wraps an `HtAuthClient` implementation, offering a clean interface for authentication flows, ensuring standardized exception propagation, and handling authentication token persistence using `HtKVStorageService`.

## Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  ht_auth_repository: any # Use the latest version
```

## Features

-   Abstracts authentication logic from the UI/business logic layers.
-   Provides methods for a complete authentication lifecycle:
    -   `authStateChanges`: Stream of user authentication state.
    -   `getCurrentUser`: Retrieves the current authenticated user.
    -   `requestSignInCode`: Initiates email+code sign-in.
    -   `verifySignInCode`: Verifies the code, saves the auth token, and returns the user.
    -   `signInAnonymously`: Signs in anonymously, saves the auth token, and returns the user.
    -   `signOut`: Signs out the user and clears the auth token.
-   Manages authentication token persistence internally using `HtKVStorageService`.
    -   Exposes `saveAuthToken(String token)`, `getAuthToken()`, and `clearAuthToken()` for direct token manipulation if needed, but these are typically handled by the main auth flow methods.
-   Propagates standardized `HtHttpException`s from the underlying client and `StorageException`s from the storage service.

## Usage

Instantiate `HtAuthRepository` by providing implementations of `HtAuthClient` and `HtKVStorageService`:

```dart
import 'package:ht_auth_client/ht_auth_client.dart';
import 'package:ht_auth_repository/ht_auth_repository.dart';
import 'package:ht_kv_storage_service/ht_kv_storage_service.dart';

// Assume ConcreteAuthClient is an implementation of HtAuthClient
final authClient = ConcreteAuthClient(...);

// Assume ConcreteKVStorageService is an implementation of HtKVStorageService
final storageService = ConcreteKVStorageService(...);

final authRepository = HtAuthRepository(
  authClient: authClient,
  storageService: storageService,
);

// Example usage:
authRepository.authStateChanges.listen((user) {
  // Handle auth state changes
});

try {
  await authRepository.requestSignInCode('test@example.com');
  // Handle success
} on InvalidInputException catch (e) {
  // Handle invalid email
} catch (e) {
  // Handle other errors
}

// Example usage:
try {
  final user = await authRepository.verifySignInCode('test@example.com', '123456');
  // User is signed in, token is saved automatically.
  print('User signed in: ${user.id}');
} on AuthenticationException catch (e) {
  // Handle invalid code
} on StorageException catch (e) {
  // Handle failure to save token
} catch (e) {
  // Handle other errors
}

// Example of anonymous sign-in:
try {
  final anonUser = await authRepository.signInAnonymously();
  // User is signed in anonymously, token is saved automatically.
  print('Anonymous user signed in: ${anonUser.id}');
} catch (e) {
  // Handle errors
}

// Example of sign-out:
try {
  await authRepository.signOut();
  // User is signed out, token is cleared automatically.
  print('User signed out.');
} catch (e) {
  // Handle errors
}

// Direct token access (e.g., for HTTP client interceptors):
Future<String?> getTokenForHttpClient() async {
  final token = await authRepository.getAuthToken();
  print('Retrieved token for HTTP client: $token');
  return token;
}
```

## License

This package is licensed under the [PolyForm Free Trial](LICENSE). Please review the terms before use.
