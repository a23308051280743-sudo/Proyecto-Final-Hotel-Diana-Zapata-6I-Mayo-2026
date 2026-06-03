import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'data/services/firestore_service.dart';
import 'features/auth/auth_provider.dart' show AuthProvider, UserRole;
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/home_public.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/admin_login_screen.dart';
import 'features/home/home_guest.dart';
import 'features/rooms/room_catalog_screen.dart';
import 'features/rooms/room_detail_screen.dart';
import 'features/reservations/create_reservation_screen.dart';
import 'features/reservations/my_reservations_screen.dart';
import 'features/reservations/reservation_detail_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/admin/screens/admin_dashboard.dart';
import 'features/admin/screens/rooms_admin_screen.dart';
import 'features/admin/screens/reservations_admin_screen.dart';
import 'features/admin/screens/users_admin_screen.dart';
import 'features/admin/screens/services_admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider(create: (_) => FirestoreService()),
      ],
      child: const HotelApp(),
    ),
  );
}

class HotelApp extends StatefulWidget {
  const HotelApp({super.key});

  @override
  State<HotelApp> createState() => _HotelAppState();
}

class _HotelAppState extends State<HotelApp> {
  GoRouter? _router;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_router == null) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      _router = GoRouter(
        initialLocation: '/',
        refreshListenable: auth,
        redirect: (context, state) {
          final isAuthenticated = auth.isAuthenticated;
          final loc = state.matchedLocation;
          final isPublicRoute = loc == '/' || loc == '/home-public' || loc == '/login' || loc == '/register' || loc == '/admin-login';

          if (!isAuthenticated && !isPublicRoute) {
            return '/login';
          }

          if (isAuthenticated && isPublicRoute) {
            return auth.role == UserRole.admin ? '/admin' : '/home';
          }

          return null;
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SplashScreen(),
          ),
          GoRoute(
            path: '/home-public',
            builder: (context, state) => const HomePublic(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const RegisterScreen(),
          ),
          GoRoute(
            path: '/admin-login',
            builder: (context, state) => const AdminLoginScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeGuest(),
          ),
          GoRoute(
            path: '/rooms',
            builder: (context, state) => const RoomCatalogScreen(),
          ),
          GoRoute(
            path: '/rooms/:id',
            builder: (context, state) => RoomDetailScreen(roomId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/reservations/new',
            builder: (context, state) => CreateReservationScreen(roomId: state.uri.queryParameters['roomId'] ?? ''),
          ),
          GoRoute(
            path: '/reservations',
            builder: (context, state) => const MyReservationsScreen(),
          ),
          GoRoute(
            path: '/reservations/:id',
            builder: (context, state) => ReservationDetailScreen(reservationId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboard(),
          ),
          GoRoute(
            path: '/admin/rooms',
            builder: (context, state) => const RoomsAdminScreen(),
          ),
          GoRoute(
            path: '/admin/reservations',
            builder: (context, state) => const ReservationsAdminScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const UsersAdminScreen(),
          ),
          GoRoute(
            path: '/admin/services',
            builder: (context, state) => const ServicesAdminScreen(),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router!,
      title: 'Hotel Luxury Moonsea',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
    );
  }
}
