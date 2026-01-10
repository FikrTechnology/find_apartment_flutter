import 'package:flutter_bloc/flutter_bloc.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginInitial()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Validate email and password
      if (event.email.isEmpty || event.password.isEmpty) {
        emit(const LoginError('Email dan password tidak boleh kosong'));
        return;
      }

      if (!event.email.contains('@')) {
        emit(const LoginError('Email tidak valid'));
        return;
      }

      // Success
      emit(const LoginSuccess());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoading());

    try {
      // Simulate Google login
      await Future.delayed(const Duration(seconds: 2));
      emit(const LoginSuccess());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
