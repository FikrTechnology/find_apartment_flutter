part of 'register_bloc.dart';

abstract class RegisterEvent {
  const RegisterEvent();
}

class RegisterWithEmailEvent extends RegisterEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String password;

  const RegisterWithEmailEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.password,
  });
}
