import 'package:flutter_bloc/flutter_bloc.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(const RegisterInitial()) {
    on<RegisterWithEmailEvent>(_onRegisterWithEmail);
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmailEvent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(const RegisterLoading());

    try {
      // Validate inputs
      if (event.firstName.isEmpty ||
          event.lastName.isEmpty ||
          event.email.isEmpty ||
          event.phone.isEmpty ||
          event.password.isEmpty) {
        emit(const RegisterError('Semua field harus diisi'));
        return;
      }

      // Validate email
      if (!_isValidEmail(event.email)) {
        emit(const RegisterError('Email tidak valid'));
        return;
      }

      // Validate password length
      if (event.password.length < 8) {
        emit(const RegisterError('Password minimal 8 karakter'));
        return;
      }

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Success
      emit(const RegisterSuccess());
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
