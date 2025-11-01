import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/legacy.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authStreamProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final userDataProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final authState = ref.watch(authStreamProvider);
  final user = authState.hasValue ? authState.value : null;

  if (user != null) {
    return ref
        .watch(firestoreProvider)
        .collection('users')
        .doc(user.uid)
        .snapshots();
  }
  return Stream.value(null);
});

final applicationStatusProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final authState = ref.watch(authStreamProvider);
  final user = authState.hasValue ? authState.value : null;

  if (user != null) {
    return ref
        .watch(firestoreProvider)
        .collection('applications')
        .doc(user.uid)
        .snapshots();
  }
  return Stream.value(null);
});

final pendingApplicationsProvider = StreamProvider<QuerySnapshot>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('applications')
      .where('status', isEqualTo: 'pending')
      .snapshots();
});

final pendingListingsProvider = StreamProvider<QuerySnapshot>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('listings')
      .where('isVerified', isEqualTo: false)
      .snapshots();
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}
