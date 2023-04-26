import 'package:go_router/go_router.dart';

import '../dashboard/page.dart';
import '../dashboard/view_model_builder.dart';
import '../sign_in/page.dart';
import '../sign_in/view_model_builder.dart';
import '../utils/builders.dart';
import 'route_names.dart';

class AppRouter {
  final config = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: AppRouteNames.signIn,
        builder: (_, __) => AppRouteBuilder(
          dependenciesBuilder: SignInPageViewModelBuilder(),
          builder: (_, viewModel) {
            return SignInPage(viewModel);
          },
        ),
      ),
      GoRoute(
        path: '/dashboard',
        name: AppRouteNames.dashboard,
        builder: (_, __) => AppRouteBuilder(
          dependenciesBuilder: DashboardPageViewModelBuilder(),
          builder: (_, viewModel) {
            return DashboardPage(viewModel);
          },
        ),
      ),
    ],
  );
}
