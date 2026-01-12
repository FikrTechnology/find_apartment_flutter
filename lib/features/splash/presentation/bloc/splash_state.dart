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
  final bool isLoggedIn;
  const SplashCompleted({this.isLoggedIn = false});
}

class SplashError extends SplashState {
  final String message;
  const SplashError(this.message);
}
