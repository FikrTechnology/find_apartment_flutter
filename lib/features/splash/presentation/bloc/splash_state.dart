part of 'splash_bloc.dart';

abstract class SplashState {
  const SplashState();
}

class SplashInitial extends SplashState {
  const SplashInitial();
}

class SplashLoading extends SplashState {
  const SplashLoading();
}

class SplashCompleted extends SplashState {
  const SplashCompleted();
}

class SplashError extends SplashState {
  final String message;
  const SplashError(this.message);
}
