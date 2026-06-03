import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel/data/models/user.dart' as app;

enum UserRole { guest, user, admin }

class AuthProvider with ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UserRole _role = UserRole.guest;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  app.User? _currentUser;

  UserRole get role => _role;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  app.User? get currentUser => _currentUser;
  String get currentUid => _auth.currentUser?.uid ?? '';

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(fb.User? firebaseUser) async {
    if (firebaseUser == null) {
      _isAuthenticated = false;
      _role = UserRole.guest;
      _currentUser = null;
      notifyListeners();
      return;
    }

    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _currentUser = app.User.fromMap({...doc.data()!, 'uid': doc.id});
        _role = _currentUser!.role == 'admin' ? UserRole.admin : UserRole.user;
      } else {
        _role = UserRole.user;
        _currentUser = app.User(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? '',
          email: firebaseUser.email ?? '',
          phone: '',
          role: 'user',
          createdAt: DateTime.now(),
        );
      }
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = true;
      _role = UserRole.user;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Read role from Firestore
      final doc = await _db.collection('users').doc(credential.user!.uid).get();
      if (doc.exists) {
        _currentUser = app.User.fromMap({...doc.data()!, 'uid': doc.id});
        _role = _currentUser!.role == 'admin' ? UserRole.admin : UserRole.user;
      } else {
        _role = UserRole.user;
      }
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginAsAdmin(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Verify admin role
      final doc = await _db.collection('users').doc(credential.user!.uid).get();
      if (!doc.exists || doc.data()?['role'] != 'admin') {
        await _auth.signOut();
        _errorMessage = 'No tienes permisos de administrador';
        _isAuthenticated = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentUser = app.User.fromMap({...doc.data()!, 'uid': doc.id});
      _role = UserRole.admin;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user!.updateDisplayName(name);

      // Create Firestore user document
      final userData = app.User(
        uid: credential.user!.uid,
        name: name,
        email: email.trim(),
        phone: phone,
        role: 'user',
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(credential.user!.uid).set(userData.toMap());

      _currentUser = userData;
      _role = UserRole.user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Error inesperado: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _isAuthenticated = false;
    _role = UserRole.guest;
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'invalid-email':
        return 'Correo electrónico no válido';
      case 'too-many-requests':
        return 'Demasiados intentos. Inténtalo más tarde';
      default:
        return 'Error de autenticación: $code';
    }
  }
}
