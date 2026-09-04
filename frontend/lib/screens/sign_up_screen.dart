import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'app_navigation_screen.dart';

class SignUpScreen
    extends StatefulWidget {
  const SignUpScreen({
    super.key,
  });

  @override
  State<SignUpScreen>
      createState() =>
          _SignUpScreenState();
}

class _SignUpScreenState
    extends State<SignUpScreen> {

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController
      nameController =
          TextEditingController();

  final TextEditingController
      emailController =
          TextEditingController();

  final TextEditingController
      passwordController =
          TextEditingController();

  final TextEditingController
      confirmPasswordController =
          TextEditingController();

  // ============================================================
  // STATE
  // ============================================================

  bool loading =
      false;

  bool obscurePassword =
      true;

  bool obscureConfirmPassword =
      true;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<void> signup() async {
    final name =
        nameController.text.trim();

    final email =
        emailController.text.trim();

    final password =
        passwordController.text;

    final confirmPassword =
        confirmPasswordController.text;

    if (name.isEmpty) {
      _showMessage(
        "Name is required.",
      );

      return;
    }

    if (email.isEmpty) {
      _showMessage(
        "Email is required.",
      );

      return;
    }

    if (password.length < 6) {
      _showMessage(
        "Password must contain at least 6 characters.",
      );

      return;
    }

    if (password !=
        confirmPassword) {
      _showMessage(
        "Passwords do not match.",
      );

      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ApiService.signup(
        name: name,
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
          "Create your account",
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
          "Start organizing your bills and expenses in one place.",
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
  // PASSWORD FIELD
  // ============================================================

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    required TextInputAction textInputAction,
    VoidCallback? onSubmitted,
  }) {
    return TextField(
      controller:
          controller,

      obscureText:
          obscureText,

      textInputAction:
          textInputAction,

      onSubmitted:
          (_) {
        onSubmitted?.call();
      },

      decoration:
          InputDecoration(
        labelText:
            label,

        hintText:
            hint,

        prefixIcon:
            const Icon(
          Icons.lock_outline,
        ),

        suffixIcon:
            IconButton(
          tooltip:
              obscureText
                  ? "Show password"
                  : "Hide password",

          icon:
              Icon(
            obscureText
                ? Icons
                    .visibility_outlined
                : Icons
                    .visibility_off_outlined,
          ),

          onPressed:
              onToggle,
        ),
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
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Scaffold(
      appBar:
          AppBar(
        title:
            const Text(
          "Create Account",
        ),
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
                      // NAME
                      // ------------------------------------------------

                      TextField(
                        controller:
                            nameController,

                        textInputAction:
                            TextInputAction
                                .next,

                        decoration:
                            const InputDecoration(
                          labelText:
                              "Name",

                          hintText:
                              "Enter your name",

                          prefixIcon:
                              Icon(
                            Icons
                                .person_outline,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 16,
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

                      _buildPasswordField(
                        controller:
                            passwordController,

                        label:
                            "Password",

                        hint:
                            "At least 6 characters",

                        obscureText:
                            obscurePassword,

                        onToggle: () {
                          setState(() {
                            obscurePassword =
                                !obscurePassword;
                          });
                        },

                        textInputAction:
                            TextInputAction
                                .next,
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // ------------------------------------------------
                      // CONFIRM PASSWORD
                      // ------------------------------------------------

                      _buildPasswordField(
                        controller:
                            confirmPasswordController,

                        label:
                            "Confirm Password",

                        hint:
                            "Enter your password again",

                        obscureText:
                            obscureConfirmPassword,

                        onToggle: () {
                          setState(() {
                            obscureConfirmPassword =
                                !obscureConfirmPassword;
                          });
                        },

                        textInputAction:
                            TextInputAction
                                .done,

                        onSubmitted:
                            loading
                                ? null
                                : signup,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // ------------------------------------------------
                      // CREATE ACCOUNT
                      // ------------------------------------------------

                      SizedBox(
                        height: 52,

                        child:
                            ElevatedButton(
                          onPressed:
                              loading
                                  ? null
                                  : signup,

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
                                        "Create Account",
                                      ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ------------------------------------------------
                      // SIGN IN
                      // ------------------------------------------------

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Text(
                            "Already have an account?",

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
                                        Navigator.pop(
                                          context,
                                        );
                                      },

                            child:
                                const Text(
                              "Sign In",
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