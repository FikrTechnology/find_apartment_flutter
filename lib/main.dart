import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/app_router.dart';
import 'core/api/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/bloc/splash_bloc.dart';
import 'features/auth/presentation/bloc/login_bloc.dart';
import 'features/auth/presentation/bloc/register_bloc.dart';
import 'features/property/presentation/bloc/property_bloc.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SplashBloc(),
        ),
        BlocProvider(
          create: (context) => LoginBloc(apiClient: apiClient),
        ),
        BlocProvider(
          create: (context) => RegisterBloc(apiClient: apiClient),
        ),
        BlocProvider(
          create: (context) => PropertyBloc(apiClient: apiClient),
        ),
      ],
      child: MaterialApp.router(
        title: 'Find Apartment',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
