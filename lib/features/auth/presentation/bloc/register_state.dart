part of 'register_bloc.dart';

abstract class RegisterState {
  const RegisterState();
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final User user;
  final String accessToken;

  const RegisterSuccess({required this.user, required this.accessToken});
}

class RegisterError extends RegisterState {
  final String message;

  const RegisterError(this.message);
}
