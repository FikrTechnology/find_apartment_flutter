import 'package:go_router/go_router.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/home/presentation/pages/search_result_page.dart';
import '../features/home/presentation/pages/all_search_result_page.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String searchResultRoute = '/search-result';
  static const String allSearchResultRoute = '/all-search-result';

  static final GoRouter router = GoRouter(
    initialLocation: splashRoute,
    routes: [
      GoRoute(
        path: splashRoute,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: loginRoute,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: registerRoute,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: homeRoute,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: searchResultRoute,
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? '';
          return SearchResultPage(initialQuery: query);
        },
      ),
      GoRoute(
        path: allSearchResultRoute,
        builder: (context, state) {
          final query = state.uri.queryParameters['q'] ?? 'Apartment';
          return AllSearchResultPage(query: query);
        },
      ),
    ],
  );
}
