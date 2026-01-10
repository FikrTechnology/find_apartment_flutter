part of 'splash_bloc.dart';

abstract class SplashEvent {
  const SplashEvent();
}

class CheckSplashStatusEvent extends SplashEvent {
  const CheckSplashStatusEvent();
}
