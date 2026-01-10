import 'package:flutter_bloc/flutter_bloc.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitial()) {
    on<CheckSplashStatusEvent>(_onCheckSplashStatus);
  }

  Future<void> _onCheckSplashStatus(
    CheckSplashStatusEvent event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    
    // Simulate initialization delay
    await Future.delayed(const Duration(seconds: 3));
    
    // After splash delay, navigate to home
    emit(const SplashCompleted());
  }
}
