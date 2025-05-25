# ht_auth_repository

![coverage: percentage](https://img.shields.io/badge/coverage-100-green)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: PolyForm Free Trial](https://img.shields.io/badge/License-PolyForm%20Free%20Trial-blue)](https://polyformproject.org/licenses/free-trial/1.0.0)

A repository package that provides an abstraction layer over authentication operations. It wraps an `HtAuthClient` implementation, offering a clean interface for authentication flows and ensuring standardized exception propagation.

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
-   Propagates standardized `HtHttpException`s from the underlying client.

## Usage

Instantiate `HtAuthRepository` by providing an implementation of `HtAuthClient`:

```dart
import 'package:ht_auth_client/ht_auth_client.dart';
import 'package:ht_auth_repository/ht_auth_repository.dart';

// Assume ConcreteAuthClient is an implementation of HtAuthClient
final authClient = ConcreteAuthClient(...);
final authRepository = HtAuthRepository(authClient: authClient);

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
```

## License

This package is licensed under the [PolyForm Free Trial](LICENSE). Please review the terms before use.
