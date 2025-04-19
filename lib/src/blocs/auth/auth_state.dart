abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {}

class Unauthenticated extends AuthState {
  final String? message;
  Unauthenticated({this.message});
}

class GoogleAuthLoading extends AuthState {}

class ForgotPasswordEmailSent extends AuthState {}

class ForgotPasswordError extends AuthState {
  final String message;
  ForgotPasswordError(this.message);
}

class ForgotPasswordLoading extends AuthState {}
