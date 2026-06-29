import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserProfileService {
  UserProfileService._();

  static final UserProfileService instance = UserProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String fallbackName(User? user) {
    if (user == null) return 'Без имени';

    final displayName = user.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    if (user.isAnonymous) {
      return 'Гость';
    }

    return 'Без имени';
  }

  Future<void> ensureUserProfile(User user, {required String provider}) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final existingUser = await userRef.get();

    if (existingUser.exists) {
      await userRef.set({
        'email': user.email,
        'displayName': user.displayName,
        'isAnonymous': user.isAnonymous,
        'lastLoginAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    final baseUsername = _buildBaseUsername(user);
    final safeUsername = await _reserveUniqueUsername(
      uid: user.uid,
      baseUsername: baseUsername,
    );

    await userRef.set({
      'uid': user.uid,
      'username': safeUsername,
      'usernameLower': safeUsername.toLowerCase(),
      'email': user.email,
      'displayName': user.displayName,
      'provider': provider,
      'isAnonymous': user.isAnonymous,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _buildBaseUsername(User user) {
    final fromDisplayName = user.displayName?.trim();
    if (fromDisplayName != null && fromDisplayName.isNotEmpty) {
      return _sanitizeUsername(fromDisplayName);
    }

    final email = user.email?.trim();
    if (email != null && email.isNotEmpty) {
      return _sanitizeUsername(email.split('@').first);
    }

    return 'guest_${user.uid.substring(0, 6)}';
  }

  String _sanitizeUsername(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9а-яё._-]+', caseSensitive: false), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    if (normalized.length < 3) return 'user_$normalized';
    if (normalized.length > 24) return normalized.substring(0, 24);
    return normalized;
  }

  Future<String> _reserveUniqueUsername({
    required String uid,
    required String baseUsername,
  }) async {
    final base = baseUsername.toLowerCase();

    final candidates = <String>[
      base,
      '${base}_${uid.substring(0, 6)}',
      '${base}_${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
    ];

    for (final candidate in candidates) {
      final usernameRef = _firestore.collection('usernames').doc(candidate);

      try {
        final reserved = await _firestore.runTransaction<bool>((transaction) async {
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
