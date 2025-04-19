import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:macro_global_test_app/src/service/storage_service.dart';

import '../../service/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc(this.authService) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
  }

  void _onForgotPasswordRequested(ForgotPasswordRequested event, Emitter<AuthState> emit) async {
    emit(ForgotPasswordLoading());
    try {
      if (event.email.isEmpty || !event.email.contains('@')) {
        emit(ForgotPasswordError("Please enter a valid email address."));
        return;
      }

      try {
        await authService.sendPasswordResetEmail(event.email);
        emit(ForgotPasswordEmailSent());
      } catch (firebaseError) {
        emit(ForgotPasswordError("Failed to send reset email. ${firebaseError.toString()}"));
      }
    } catch (e) {
      emit(ForgotPasswordError("An unexpected error occurred. ${e.toString()}"));
    }
  }

  void _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authService.signInWithEmail(event.email, event.password);
      if (user != null) {
        final snapshot = await authService.getUserProfile(user.uid);
        final data = snapshot.data();

        if (data != null) {
          await StorageService.saveUser(
            user.uid,
            data['name'] ?? user,
            data['email'] ?? user.email,
            phone: data['phone'] ?? user.phoneNumber,
          );
        }

        emit(Authenticated());
      } else {
        emit(Unauthenticated(message: 'Invalid credentials'));
      }
    } catch (e) {
      emit(Unauthenticated(message: e.toString()));
    }
  }

  void _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await StorageService.clearUser();
    await authService.signOut();
    emit(Unauthenticated());
  }

  void _onGoogleSignInRequested(GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(GoogleAuthLoading());
    try {
      final user = await authService.signInWithGoogle();
      if (user != null) {
        final snapshot = await authService.getUserProfile(user.uid);
        final data = snapshot.data();

        if (data != null) {
          await StorageService.saveUser(
            user.uid,
            data['name'] ?? '',
            data['email'] ?? user.email ?? '',
            phone: data['phone'] ?? '',
          );
        }

        emit(Authenticated());
      } else {
        emit(Unauthenticated(message: 'Google Sign-In failed'));
      }
    } catch (e) {
      emit(Unauthenticated(message: e.toString()));
    }
  }

  void _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authService.signUpWithEmail(
        event.email,
        event.password,
        event.name,
        event.phone,
      );
      if (user != null) {
        await StorageService.saveUser(user.uid, event.name, user.email ?? '', phone: event.phone);
        emit(Authenticated());
      } else {
        emit(Unauthenticated(message: 'Sign-up failed'));
      }
    } catch (e) {
      emit(Unauthenticated(message: e.toString()));
    }
  }
}
