part of 'login_bloc.dart';

abstract class LoginEvent {
  const LoginEvent();
}

class LoginWithEmailEvent extends LoginEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginWithEmailEvent({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });
}

class LoginWithGoogleEvent extends LoginEvent {
  const LoginWithGoogleEvent();
}
