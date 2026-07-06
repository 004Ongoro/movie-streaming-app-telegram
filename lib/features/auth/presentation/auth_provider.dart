import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({this.status = AuthStatus.initial, this.user, this.error});
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _init();
  }

  void _init() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      state = AuthState(
        status: session != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
        user: session?.user,
      );
    });
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      state = AuthState(
        status: AuthStatus.authenticated,
        user: session.user,
      );
    }
  }

  Future<String?> signIn(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null;
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, error: e.message);
      return e.message;
    } catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, error: e.toString());
      return e.toString();
    }
  }

  Future<String?> signUp(String email, String password) async {
    state = const AuthState(status: AuthStatus.loading);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user != null && user.emailConfirmedAt != null) {
        state = AuthState(status: AuthStatus.authenticated, user: user);
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
      return null;
    } on AuthException catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, error: e.message);
      return e.message;
    } catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, error: e.toString());
      return e.toString();
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
