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
-   Provides methods mirroring `HtAuthClient`:
    -   `authStateChanges`
    -   `getCurrentUser`
    -   `requestSignInCode`
    -   `verifySignInCode`
    -   `signInAnonymously`
    -   `signOut`
    -   `saveAuthToken(String token)`
    -   `getAuthToken()`
    -   `clearAuthToken()`
-   Propagates standardized `HtHttpException`s from the underlying client.

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

// Example token handling:
Future<void> handleSuccessfulLogin(String token) async {
  await authRepository.saveAuthToken(token);
  print('Auth token saved.');
}

Future<String?> getTokenForHttpClient() async {
  final token = await authRepository.getAuthToken();
  print('Retrieved token: $token');
  return token;
}

Future<void> handleSignOut() async {
  await authRepository.clearAuthToken();
  print('Auth token cleared.');
}
```

## License

This package is licensed under the [PolyForm Free Trial](LICENSE). Please review the terms before use.
