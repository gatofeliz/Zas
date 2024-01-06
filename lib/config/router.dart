import 'package:go_router/go_router.dart';
import 'package:zas/presentation/ui/register_screen.dart';
import 'package:zas/presentation/ui/widgets/navbar_widget.dart';
import '../presentation/ui/create_event.dart';
import '../presentation/ui/login_screen.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(path: '/register', builder: (context, state) => const RegisterPage()),
    GoRoute(path: '/principal', builder: (context, state) => const PrincipalScreen()),
    GoRoute(path: '/createEvent', builder: (context, state) => const CreateEvent()),
  ],
);