//
// ignore_for_file: comment_references

import 'dart:async';

import 'package:ht_auth_client/ht_auth_client.dart';
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
  const HtAuthRepository({required HtAuthClient authClient})
      : _authClient = authClient;

  final HtAuthClient _authClient;

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
      return await _authClient.verifySignInCode(email, code);
    } on HtHttpException {
      rethrow; // Propagate client-level exceptions
    }
  }

  /// Signs in the user anonymously.
  ///
  /// Delegates to the underlying [HtAuthClient]'s method.
  ///
  /// Throws [HtHttpException] or its subtypes on failure, as propagated
  /// from the client.
  Future<User> signInAnonymously() async {
    try {
      return await _authClient.signInAnonymously();
    } on HtHttpException {
      rethrow; // Propagate client-level exceptions
    }
  }

  /// Signs out the current user (whether authenticated normally or anonymously).
  ///
  /// Delegates to the underlying [HtAuthClient]'s method.
  ///
  /// Throws [HtHttpException] or its subtypes on failure, as propagated
  /// from the client.
  Future<void> signOut() async {
    try {
      await _authClient.signOut();
    } on HtHttpException {
      rethrow; // Propagate client-level exceptions
    }
  }
}
