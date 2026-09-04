import 'package:flutter/material.dart';

import 'screens/app_navigation_screen.dart';
import 'screens/sign_in_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // LOAD SAVED THEME BEFORE APP STARTS
  // ============================================================

  await ThemeController.instance.load();

  runApp(
    const BillingExpenseManagerApp(),
  );
}

class BillingExpenseManagerApp
    extends StatelessWidget {
  const BillingExpenseManagerApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    // ==========================================================
    // LISTEN TO THE GLOBAL THEME CONTROLLER
    // ==========================================================

    return ValueListenableBuilder<ThemeMode>(
      valueListenable:
          ThemeController.instance.themeMode,

      builder: (
        context,
        currentThemeMode,
        child,
      ) {
        return MaterialApp(
          debugShowCheckedModeBanner:
              false,

          title:
              "Billing Expense Manager",

          // ====================================================
          // LIGHT THEME
          // ====================================================

          theme:
              AppTheme.lightTheme,

          // ====================================================
          // DARK THEME
          // ====================================================

          darkTheme:
              AppTheme.darkTheme,

          // ====================================================
          // ACTIVE THEME
          //
          // This changes immediately whenever Settings changes
          // ThemeController.instance.themeMode.
          // ====================================================

          themeMode:
              currentThemeMode,

          // ====================================================
          // STARTUP
          // ====================================================

          home:
              const AuthStartupScreen(),
        );
      },
    );
  }
}

// ============================================================
// AUTH STARTUP SCREEN
// ============================================================

class AuthStartupScreen
    extends StatefulWidget {
  const AuthStartupScreen({
    super.key,
  });

  @override
  State<AuthStartupScreen>
      createState() =>
          _AuthStartupScreenState();
}

class _AuthStartupScreenState
    extends State<AuthStartupScreen> {

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _checkAuthentication();
  }

  // ============================================================
  // CHECK AUTHENTICATION
  // ============================================================

  Future<void>
      _checkAuthentication() async {

    final loggedIn =
        await ApiService.isLoggedIn();

    if (!mounted) {
      return;
    }

    // ==========================================================
    // AUTHENTICATED USER
    // ==========================================================

    if (loggedIn) {
      Navigator.pushReplacement(
        context,

        MaterialPageRoute(
          builder: (_) =>
              const AppNavigationScreen(),
        ),
      );

      return;
    }

    // ==========================================================
    // NOT AUTHENTICATED
    // ==========================================================

    Navigator.pushReplacement(
      context,

      MaterialPageRoute(
        builder: (_) =>
            const SignInScreen(),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return const Scaffold(
      body:
          Center(
        child:
            CircularProgressIndicator(),
      ),
    );
  }
}