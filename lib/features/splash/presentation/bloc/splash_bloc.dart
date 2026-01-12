import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/session_service.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final SessionService _sessionService = SessionService();
  final Logger _logger = Logger();

  SplashBloc() : super(const SplashInitial()) {
    on<CheckSplashStatusEvent>(_onCheckSplashStatus);
  }

  Future<void> _onCheckSplashStatus(
    CheckSplashStatusEvent event,
    Emitter<SplashState> emit,
  ) async {
    _logger.i('Checking splash status and session...');
    emit(const SplashLoading());
    
    try {
      await Future.delayed(const Duration(seconds: 3));
      
      final isSessionActive = await _sessionService.isSessionActive();
      _logger.i('Session active: $isSessionActive');
      
      if (isSessionActive) {
        final userName = await _sessionService.getUserName();
        _logger.i('User session found: $userName');
        emit(const SplashCompleted(isLoggedIn: true));
      } else {
        _logger.i('No active session found');
        emit(const SplashCompleted(isLoggedIn: false));
      }
    } catch (e) {
      _logger.e('Error checking session: $e');
      emit(const SplashCompleted(isLoggedIn: false));
    }
  }
}
