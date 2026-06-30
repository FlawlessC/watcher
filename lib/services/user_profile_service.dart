import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserProfileService {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String fallbackName(User? user) {
    if (user == null) return 'Без имени';

    if (user.isAnonymous) {
      return 'Гость';
    }

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Без имени';
  }

  Future<void> ensureUserProfile(User user, {required String provider}) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final countersRef = _firestore.collection('config').doc('counters');

    await _firestore.runTransaction((transaction) async {
      final existingUser = await transaction.get(userRef);

      if (existingUser.exists) {
        transaction.set(userRef, {
          'email': user.email,
          'provider': provider,
          'isAnonymous': user.isAnonymous,
          'lastLoginAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        return;
      }

      final countersSnap = await transaction.get(countersRef);
      final countersData = countersSnap.data();

      final currentNumber =
          (countersData?['lastAccountNumber'] as int?) ?? 100000;
      final accountNumber = currentNumber + 1;

      transaction.set(countersRef, {
        'lastAccountNumber': accountNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final baseUsername = user.isAnonymous
          ? 'guest$accountNumber'
          : _buildBaseUsername(user);

      final safeUsername = _sanitizeUsername(baseUsername);
      final displayName = user.isAnonymous
          ? 'Гость $accountNumber'
          : _buildDisplayName(user, safeUsername);

      final usernameRef =
          _firestore.collection('usernames').doc(safeUsername.toLowerCase());

      transaction.set(usernameRef, {
        'uid': user.uid,
        'username': safeUsername,
        'accountNumber': accountNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(userRef, {
        'uid': user.uid,
        'accountNumber': accountNumber,
        'username': safeUsername,
        'usernameLower': safeUsername.toLowerCase(),
        'displayName': displayName,
        'email': user.email,
        'provider': provider,
        'isAnonymous': user.isAnonymous,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }).catchError((e) async {
      debugPrint('ENSURE USER PROFILE ERROR: $e');

      if (!user.isAnonymous) {
        final fallbackUsername = await _reserveUniqueUsername(
          uid: user.uid,
          baseUsername: _buildBaseUsername(user),
        );

        await userRef.set({
          'uid': user.uid,
          'username': fallbackUsername,
          'usernameLower': fallbackUsername.toLowerCase(),
          'displayName': _buildDisplayName(user, fallbackUsername),
          'email': user.email,
          'provider': provider,
          'isAnonymous': user.isAnonymous,
          'photoUrl': user.photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  String _buildBaseUsername(User user) {
    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return _sanitizeUsername(email.split('@').first);
    }

    final fromDisplayName = user.displayName?.trim();
    if (fromDisplayName != null && fromDisplayName.isNotEmpty) {
      return _sanitizeUsername(fromDisplayName);
    }

    return 'user';
  }

  String _buildDisplayName(User user, String username) {
    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return username;
  }

  String _sanitizeUsername(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9а-яё._-]+', caseSensitive: false), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    if (normalized.isEmpty) return 'user';
    if (normalized.length < 3) return 'user_$normalized';
    if (normalized.length > 24) return normalized.substring(0, 24);
    return normalized;
  }

  Future<String> _reserveUniqueUsername({
    required String uid,
    required String baseUsername,
  }) async {
    final base = _sanitizeUsername(baseUsername).toLowerCase();

    final candidates = <String>[
      base,
      '${base}_${uid.substring(0, 6)}',
      '${base}_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    ];

    for (final candidate in candidates) {
      final usernameRef = _firestore.collection('usernames').doc(candidate);

      try {
        final reserved =
            await _firestore.runTransaction<bool>((transaction) async {
          final snapshot = await transaction.get(usernameRef);

          if (snapshot.exists) {
            final data = snapshot.data();
            if (data?['uid'] == uid) return true;
            return false;
          }

          transaction.set(usernameRef, {
            'uid': uid,
            'username': candidate,
            'createdAt': FieldValue.serverTimestamp(),
          });

          return true;
        });

        if (reserved) return candidate;
      } catch (e) {
        debugPrint('USERNAME RESERVE ERROR: $e');
      }
    }

    return '${base}_${uid.substring(0, 8)}';
  }
}