//
// ignore_for_file: comment_references

import 'dart:async';

import 'package:ht_auth_client/ht_auth_client.dart';
import 'package:ht_kv_storage_service/ht_kv_storage_service.dart';
import 'package:ht_shared/ht_shared.dart';

/// {@template ht_auth_repository}
/// A repository that manages authentication operations.
///
/// This repository acts as an abstraction layer over an [HtAuthClient],
/// providing a consistent interface for authentication flows and
/// propagating standardized exceptions.
/// {@endtemplate}
class HtAuthRepository {
  /// {@macro ht_auth_repository}
  ///
  /// Requires an instance of [HtAuthClient] to handle the actual
  /// authentication operations.
  const HtAuthRepository({
    required HtAuthClient authClient,
    required HtKVStorageService storageService,
  }) : _authClient = authClient,
       _storageService = storageService;

  final HtAuthClient _authClient;
  final HtKVStorageService _storageService;

  /// Stream emitting the current authenticated [User] or `null`.
  ///
  /// Delegates to the underlying [HtAuthClient]'s stream.
  Stream<User?> get authStateChanges => _authClient.authStateChanges;

  /// Retrieves the currently authenticated [User], if any.
  ///
  /// Delegates to the underlying [HtAuthClient]'s method.
  ///
  /// Throws [HtHttpException] or its subtypes on failure, as propagated
  /// from the client.
  Future<User?> getCurrentUser() async {
    try {
      return await _authClient.getCurrentUser();
    } on HtHttpException {
      rethrow; // Propagate client-level exceptions
    }
    // Catch-all for unexpected errors is generally avoided here,
    // relying on the client's defined exceptions.
  }

  /// Initiates the sign-in/sign-up process using the email+code flow.
  ///
  /// Delegates to the underlying [HtAuthClient]'s method.
  ///
  /// Throws [HtHttpException] or its subtypes on failure, as propagated
  /// from the client.
  Future<void> requestSignInCode(String email) async {
    try {
      await _authClient.requestSignInCode(email);
    } on HtHttpException {
      rethrow; // Propagate client-level exceptions
    }
  }

  /// Verifies the email code provided by the user and completes sign-in/sign-up.
  ///
  /// Delegates to the underlying [HtAuthClient]'s method.
  ///
  /// Throws [HtHttpException] or its subtypes on failure, as propagated
  /// from the client.
  Future<User> verifySignInCode(String email, String code) async {
    try {
      final authResponse = await _authClient.verifySignInCode(email, code);
      // authResponse is AuthSuccessResponse
      final token = authResponse.token;
      final user = authResponse.user;
      await saveAuthToken(token);
      return user;
    } on HtHttpException {
      rethrow; // Propagate client-level exceptions
    } on StorageException {
      rethrow; // Propagate storage exceptions during token save
    }
  }

  /// Signs in the user anonymously.
  ///
  /// Delegates to the underlying [HtAuthClient]'s method.
  /// After successful sign-in, saves the token and returns the user.
  ///
  /// Throws [HtHttpException] or its subtypes on failure, as propagated
  /// from the client.
  /// Throws [StorageException] if saving the token fails.
  Future<User> signInAnonymously() async {
    try {
      final authResponse = await _authClient.signInAnonymously();
      // authResponse is AuthSuccessResponse
      final token = authResponse.token;
      final user = authResponse.user;
      await saveAuthToken(token);
      return user;
    } on HtHttpException {
      rethrow; // Propagate client-level exceptions
    } on StorageException {
      rethrow; // Propagate storage exceptions during token save
    }
  }

  /// Signs out the current user (whether authenticated normally or anonymously).
  ///
  /// Delegates to the underlying [HtAuthClient]'s method.
  /// After successful sign-out, clears the authentication token from storage.
  ///
  /// Throws [HtHttpException] or its subtypes on failure, as propagated
  /// from the client.
  /// Throws [StorageException] if clearing the token fails.
  Future<void> signOut() async {
    try {
      await _authClient.signOut();
      await clearAuthToken();
    } on HtHttpException {
      rethrow; // Propagate client-level exceptions
    } on StorageException {
      rethrow; // Propagate storage exceptions during token clear
    }
  }

  /// Saves the authentication token to storage.
  ///
  /// Throws [StorageWriteException] if the write operation fails.
  Future<void> saveAuthToken(String token) async {
    try {
      await _storageService.writeString(
        key: StorageKey.authToken.stringValue,
        value: token,
      );
    } on StorageWriteException {
      rethrow;
    }
  }

  /// Retrieves the authentication token from storage.
  ///
  /// Returns `null` if the token is not found.
  /// Throws [StorageReadException] if the read operation fails for other reasons.
  /// Throws [StorageTypeMismatchException] if the stored value is not a string.
  Future<String?> getAuthToken() async {
    try {
      return await _storageService.readString(
        key: StorageKey.authToken.stringValue,
      );
    } on StorageReadException {
      rethrow;
    } on StorageTypeMismatchException {
      rethrow;
    }
  }

  /// Clears the authentication token from storage.
  ///
  /// Throws [StorageDeleteException] if the delete operation fails.
  Future<void> clearAuthToken() async {
    try {
      await _storageService.delete(key: StorageKey.authToken.stringValue);
    } on StorageDeleteException {
      rethrow;
    }
  }
}
