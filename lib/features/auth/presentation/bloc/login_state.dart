part of 'login_bloc.dart';

abstract class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  final User user;
  final String accessToken;

  const LoginSuccess({required this.user, required this.accessToken});
}

class LoginError extends LoginState {
  final String message;

  const LoginError(this.message);
}
