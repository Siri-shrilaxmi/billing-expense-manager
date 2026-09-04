import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'app_navigation_screen.dart';
import 'sign_up_screen.dart';

class SignInScreen
    extends StatefulWidget {
  const SignInScreen({
    super.key,
  });

  @override
  State<SignInScreen>
      createState() =>
          _SignInScreenState();
}

class _SignInScreenState
    extends State<SignInScreen> {

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController
      emailController =
          TextEditingController();

  final TextEditingController
      passwordController =
          TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool loading =
      false;

  bool obscurePassword =
      true;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // ============================================================
  // SIGN IN
  // ============================================================

  Future<void> signin() async {
    final email =
        emailController.text.trim();

    final password =
        passwordController.text;

    if (email.isEmpty ||
        password.isEmpty) {
      _showMessage(
        "Email and password are required.",
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ApiService.signin(
        email: email,
        password: password,
      );

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const AppNavigationScreen(),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        e.toString().replaceFirst(
              "Exception: ",
              "",
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
      ),
    );
  }

  // ============================================================
  // BRAND HEADER
  // ============================================================

  Widget _buildBrandHeader(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration:
              BoxDecoration(
            color:
                colorScheme.primary,
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    colorScheme.primary
                        .withValues(
                  alpha: 0.22,
                ),
                blurRadius: 24,
                offset:
                    const Offset(
                  0,
                  10,
                ),
              ),
            ],
          ),
          child:
              Icon(
            Icons.receipt_long_rounded,
            size: 40,
            color:
                colorScheme.onPrimary,
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        Text(
          "Welcome back",
          textAlign:
              TextAlign.center,
          style:
              theme.textTheme.headlineMedium
                  ?.copyWith(
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        Text(
          "Sign in to continue managing your bills and expenses.",
          textAlign:
              TextAlign.center,
          style:
              theme.textTheme.bodyMedium
                  ?.copyWith(
            color:
                colorScheme
                    .onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Scaffold(
      appBar:
          AppBar(
        automaticallyImplyLeading:
            false,
      ),

      body:
          SafeArea(
        child:
            Center(
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets.all(
              24,
            ),

            child:
                ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth:
                    460,
              ),

              child:
                  Card(
                child:
                    Padding(
                  padding:
                      const EdgeInsets.all(
                    28,
                  ),

                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,

                    children: [
                      _buildBrandHeader(
                        context,
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      // ------------------------------------------------
                      // EMAIL
                      // ------------------------------------------------

                      TextField(
                        controller:
                            emailController,

                        keyboardType:
                            TextInputType
                                .emailAddress,

                        textInputAction:
                            TextInputAction
                                .next,

                        decoration:
                            const InputDecoration(
                          labelText:
                              "Email",

                          hintText:
                              "Enter your email address",

                          prefixIcon:
                              Icon(
                            Icons
                                .email_outlined,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // ------------------------------------------------
                      // PASSWORD
                      // ------------------------------------------------

                      TextField(
                        controller:
                            passwordController,

                        obscureText:
                            obscurePassword,

                        textInputAction:
                            TextInputAction
                                .done,

                        onSubmitted:
                            (_) {
                          if (!loading) {
                            signin();
                          }
                        },

                        decoration:
                            InputDecoration(
                          labelText:
                              "Password",

                          hintText:
                              "Enter your password",

                          prefixIcon:
                              const Icon(
                            Icons
                                .lock_outline,
                          ),

                          suffixIcon:
                              IconButton(
                            tooltip:
                                obscurePassword
                                    ? "Show password"
                                    : "Hide password",

                            icon:
                                Icon(
                              obscurePassword
                                  ? Icons
                                      .visibility_outlined
                                  : Icons
                                      .visibility_off_outlined,
                            ),

                            onPressed: () {
                              setState(() {
                                obscurePassword =
                                    !obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // ------------------------------------------------
                      // SIGN IN BUTTON
                      // ------------------------------------------------

                      SizedBox(
                        height: 52,

                        child:
                            ElevatedButton(
                          onPressed:
                              loading
                                  ? null
                                  : signin,

                          child:
                              AnimatedSwitcher(
                            duration:
                                const Duration(
                              milliseconds:
                                  180,
                            ),

                            child:
                                loading
                                    ? const SizedBox(
                                        key:
                                            ValueKey(
                                          "loading",
                                        ),
                                        width:
                                            22,
                                        height:
                                            22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2.2,
                                        ),
                                      )
                                    : const Text(
                                        key:
                                            ValueKey(
                                          "text",
                                        ),
                                        "Sign In",
                                      ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ------------------------------------------------
                      // SIGN UP
                      // ------------------------------------------------

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Text(
                            "Don't have an account?",
                            style:
                                theme
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                              color:
                                  colorScheme
                                      .onSurfaceVariant,
                            ),
                          ),

                          TextButton(
                            onPressed:
                                loading
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    const SignUpScreen(),
                                          ),
                                        );
                                      },

                            child:
                                const Text(
                              "Sign Up",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}