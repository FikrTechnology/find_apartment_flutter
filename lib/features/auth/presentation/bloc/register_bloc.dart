import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/models/auth_models.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final ApiClient apiClient;
  final Logger _logger = Logger();

  RegisterBloc({required this.apiClient}) : super(const RegisterInitial()) {
    on<RegisterWithEmailEvent>(_onRegisterWithEmail);
  }

  Future<void> _onRegisterWithEmail(
    RegisterWithEmailEvent event,
    Emitter<RegisterState> emit,
  ) async {
    _logger.i('RegisterWithEmailEvent triggered for: ${event.email}');
    emit(const RegisterLoading());

    try {
      _logger.d('Validating register inputs...');
      // Validate inputs
      if (event.firstName.isEmpty ||
          event.lastName.isEmpty ||
          event.email.isEmpty ||
          event.phone.isEmpty ||
          event.password.isEmpty) {
        _logger.w('Register validation failed: Missing required fields');
        emit(const RegisterError('Semua field harus diisi'));
        return;
      }

      // Validate email
      if (!_isValidEmail(event.email)) {
        _logger.w('Register validation failed: Invalid email format');
        emit(const RegisterError('Email tidak valid'));
        return;
      }

      // Validate password length
      if (event.password.length < 8) {
        _logger.w('Register validation failed: Password too short');
        emit(const RegisterError('Password minimal 8 karakter'));
        return;
      }

      _logger.i('All validations passed, calling register API...');
      // Call API
      final request = RegisterRequest(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        email: event.email,
        password: event.password,
      );

      final response = await apiClient.register(request);

      _logger.i('Register success, user: ${response.data.user.name}');
      // Success
      emit(RegisterSuccess(user: response.data.user, accessToken: response.data.accessToken));
    } catch (e) {
      _logger.e('Register error: $e');
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
