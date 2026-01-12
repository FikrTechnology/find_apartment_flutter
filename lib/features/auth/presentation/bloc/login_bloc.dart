import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/models/login_models.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/services/remember_me_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final ApiClient apiClient;
  final SessionService sessionService = SessionService();
  final RememberMeService rememberMeService = RememberMeService();
  final Logger _logger = Logger();

  LoginBloc({required this.apiClient}) : super(const LoginInitial()) {
    on<LoginWithEmailEvent>(_onLoginWithEmail);
    on<LoginWithGoogleEvent>(_onLoginWithGoogle);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoginWithEmail(
    LoginWithEmailEvent event,
    Emitter<LoginState> emit,
  ) async {
    _logger.i('LoginWithEmailEvent triggered for: ${event.email}');
    emit(const LoginLoading());

    try {
      _logger.d('Validating login inputs...');
      if (event.email.isEmpty || event.password.isEmpty) {
        _logger.w('Login validation failed: Missing email or password');
        emit(const LoginError('Email dan password tidak boleh kosong'));
        return;
      }

      if (!event.email.contains('@')) {
        _logger.w('Login validation failed: Invalid email format');
        emit(const LoginError('Email tidak valid'));
        return;
      }

      _logger.i('All validations passed, calling login API...');
      final request = LoginRequest(
        email: event.email,
        password: event.password,
      );

      final response = await apiClient.login(request);

      _logger.i('Login success, user: ${response.data.user.name}');
      
      await sessionService.saveSession(
        token: response.data.accessToken,
        userId: response.data.user.id.toString(),
        userName: response.data.user.name,
        userEmail: response.data.user.email,
      );
      _logger.i('Session saved successfully');

      if (event.rememberMe) {
        await rememberMeService.saveCredentials(
          email: event.email,
          password: event.password,
          rememberMe: true,
        );
        _logger.i('Credentials saved with remember me enabled');
      } else {
        await rememberMeService.clearCredentials();
        _logger.i('Credentials cleared');
      }

      emit(LoginSuccess(user: response.data.user, accessToken: response.data.accessToken));
    } catch (e) {
      _logger.e('Login error: $e');
      emit(LoginError(e.toString()));
    }
  }

  Future<void> _onLoginWithGoogle(
    LoginWithGoogleEvent event,
    Emitter<LoginState> emit,
  ) async {
    _logger.i('LoginWithGoogleEvent triggered');
    emit(const LoginLoading());

    try {
      _logger.d('Google login not implemented yet');
      // TODO: Implement Google login
      await Future.delayed(const Duration(seconds: 2));
      emit(const LoginError('Google login not implemented yet'));
    } catch (e) {
      _logger.e('Google login error: $e');
      emit(LoginError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<LoginState> emit,
  ) async {
    _logger.i('LogoutEvent triggered');
    try {
      await sessionService.clearSession();
      _logger.i('Session cleared - Remember me credentials preserved');
      emit(const LoginInitial());
    } catch (e) {
      _logger.e('Logout error: $e');
      emit(LoginError(e.toString()));
    }
  }
}
