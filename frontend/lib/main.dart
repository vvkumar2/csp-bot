import 'package:flutter/material.dart';
import 'package:frontend/firebase_api.dart';
import 'package:frontend/screens/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/screens/navbar.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/screens/dashboard.dart';
import 'package:frontend/screens/splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseApi().initNotifications();
  await dotenv.load(fileName: "lib/.env");
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return MaterialApp(
        title: 'PutProfit',
        theme: ThemeData().copyWith(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color.fromARGB(255, 16, 17, 17),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
          ),
        ),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            if (userSnapshot.hasData) {
              if (user == null) {
                return const SplashScreen();
              }
              return const NavbarScreen();
            }
            return const AuthScreen();
          },
        ));
  }
}
