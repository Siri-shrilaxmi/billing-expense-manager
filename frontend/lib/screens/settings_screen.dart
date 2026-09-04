import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/theme_controller.dart';
import 'sign_in_screen.dart';

// ============================================================================
// SETTINGS SCREEN
// ============================================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
  });

  @override
  State<SettingsScreen> createState() =>
      _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  // ==========================================================================
  // CURRENT THEME
  // ==========================================================================

  ThemeMode get selectedTheme =>
      ThemeController
          .instance
          .themeMode
          .value;

  // ==========================================================================
  // THEME LABEL
  // ==========================================================================

  String themeLabel(
    ThemeMode mode,
  ) {
    switch (mode) {
      case ThemeMode.system:
        return "System";

      case ThemeMode.light:
        return "Light";

      case ThemeMode.dark:
        return "Dark";
    }
  }

  // ==========================================================================
  // SIGN OUT
  // ==========================================================================

  Future<void> logout(
    BuildContext context,
  ) async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Sign Out",
          ),
          content: const Text(
            "Are you sure you want to sign out?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                "Cancel",
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                "Sign Out",
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await ApiService.logout();

    if (!context.mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SignInScreen(),
      ),
      (_) => false,
    );
  }

  // ==========================================================================
  // SETTINGS TILE
  // ==========================================================================

  Widget _settingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final resolvedIconColor =
        iconColor ??
            colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.all(
            18,
          ),
          decoration:
              BoxDecoration(
            color:
                colorScheme.surface,
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border:
                Border.all(
              color:
                  colorScheme
                      .outlineVariant,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  color:
                      resolvedIconColor
                          .withOpacity(
                    0.10,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 23,
                  color:
                      resolvedIconColor,
                ),
              ),

              const SizedBox(
                width: 15,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style:
                          theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      subtitle,
                      style:
                          theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                        color:
                            colorScheme
                                .onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size: 16,
                color:
                    colorScheme
                        .onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION LABEL
  // ==========================================================================

  Widget _sectionLabel(
    BuildContext context,
    String text,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Padding(
      padding:
          const EdgeInsets.only(
        left: 4,
        bottom: 10,
      ),
      child: Text(
        text.toUpperCase(),
        style:
            Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(
          color:
              colorScheme.primary,
          fontWeight:
              FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ==========================================================================
  // OPEN APPEARANCE
  // ==========================================================================

  void openAppearance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AppearanceSettingsScreen(),
      ),
    );
  }

  // ==========================================================================
  // OPEN ACCOUNT
  // ==========================================================================

  void openAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AccountSettingsScreen(),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              24,
              22,
              24,
              40,
            ),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 850,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [

                  // ========================================================
                  // HEADER
                  // ========================================================

                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration:
                            BoxDecoration(
                          gradient:
                              LinearGradient(
                            begin:
                                Alignment
                                    .topLeft,
                            end:
                                Alignment
                                    .bottomRight,
                            colors: [
                              colorScheme
                                  .primary,
                              colorScheme
                                  .secondary,
                            ],
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),
                        child: Icon(
                          Icons
                              .settings_rounded,
                          color:
                              colorScheme
                                  .onPrimary,
                          size: 25,
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              "Settings",
                              style:
                                  theme
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              "Customize the application and manage your account.",
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
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  // ========================================================
                  // GENERAL
                  // ========================================================

                  _sectionLabel(
                    context,
                    "General",
                  ),

                  _settingsTile(
                    context: context,
                    icon:
                        Icons.palette_outlined,
                    title:
                        "Appearance",
                    subtitle:
                        "Theme: ${themeLabel(selectedTheme)}",
                    onTap:
                        openAppearance,
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ========================================================
                  // ACCOUNT
                  // ========================================================

                  _sectionLabel(
                    context,
                    "Account",
                  ),

                  _settingsTile(
                    context: context,
                    icon:
                        Icons.person_outline_rounded,
                    title:
                        "Account",
                    subtitle:
                        "Manage your profile, password, and account information.",
                    onTap:
                        openAccount,
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ========================================================
                  // SESSION
                  // ========================================================

                  _sectionLabel(
                    context,
                    "Session",
                  ),

                  _settingsTile(
                    context: context,
                    icon:
                        Icons.logout_rounded,
                    title:
                        "Sign Out",
                    subtitle:
                        "Remove the current session from this device.",
                    iconColor:
                        colorScheme.error,
                    onTap: () {
                      logout(
                        context,
                      );
                    },
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  // ========================================================
                  // INFORMATION
                  // ========================================================

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 17,
                      vertical: 15,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          colorScheme
                              .surfaceVariant,
                      borderRadius:
                          BorderRadius
                              .circular(
                        16,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .info_outline_rounded,
                          size: 19,
                          color:
                              colorScheme
                                  .primary,
                        ),

                        const SizedBox(
                          width: 9,
                        ),

                        Expanded(
                          child: Text(
                            "Additional application preferences will appear here as they are implemented.",
                            style:
                                theme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                              color:
                                  colorScheme
                                      .onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// APPEARANCE SETTINGS SCREEN
// ============================================================================

class AppearanceSettingsScreen
    extends StatefulWidget {
  const AppearanceSettingsScreen({
    super.key,
  });

  @override
  State<AppearanceSettingsScreen>
      createState() =>
          _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState
    extends State<AppearanceSettingsScreen> {

  // ==========================================================================
  // CURRENT THEME
  // ==========================================================================

  ThemeMode get selectedTheme =>
      ThemeController
          .instance
          .themeMode
          .value;

  // ==========================================================================
  // THEME TITLE
  // ==========================================================================

  String themeTitle(
    ThemeMode mode,
  ) {
    switch (mode) {
      case ThemeMode.system:
        return "System";

      case ThemeMode.light:
        return "Light";

      case ThemeMode.dark:
        return "Dark";
    }
  }

  // ==========================================================================
  // THEME DESCRIPTION
  // ==========================================================================

  String themeDescription(
    ThemeMode mode,
  ) {
    switch (mode) {
      case ThemeMode.system:
        return "Follow the device or browser appearance.";

      case ThemeMode.light:
        return "Use the light application theme.";

      case ThemeMode.dark:
        return "Use the dark application theme.";
    }
  }

  // ==========================================================================
  // THEME OPTION
  // ==========================================================================

  Widget _themeOption({
    required BuildContext context,
    required ThemeMode mode,
    required IconData icon,
  }) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final selected =
        selectedTheme == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        onTap: () async {
          await ThemeController
              .instance
              .setThemeMode(
            mode,
          );

          if (!mounted) {
            return;
          }

          setState(() {});
        },
        child: AnimatedContainer(
          duration:
              const Duration(
            milliseconds: 180,
          ),
          padding:
              const EdgeInsets.all(
            17,
          ),
          decoration:
              BoxDecoration(
            color:
                selected
                    ? colorScheme
                        .primaryContainer
                    : colorScheme.surface,
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border:
                Border.all(
              color:
                  selected
                      ? colorScheme
                          .primary
                      : colorScheme
                          .outlineVariant,
              width:
                  selected
                      ? 1.5
                      : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  color:
                      selected
                          ? colorScheme
                              .primary
                          : colorScheme
                              .surfaceVariant,
                  borderRadius:
                      BorderRadius
                          .circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      selected
                          ? colorScheme
                              .onPrimary
                          : colorScheme
                              .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      themeTitle(
                        mode,
                      ),
                      style:
                          theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      themeDescription(
                        mode,
                      ),
                      style:
                          theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                        color:
                            colorScheme
                                .onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                selected
                    ? Icons
                        .radio_button_checked_rounded
                    : Icons
                        .radio_button_unchecked_rounded,
                color:
                    selected
                        ? colorScheme
                            .primary
                        : colorScheme
                            .onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Appearance",
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 700,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [

                  // ========================================================
                  // HEADER
                  // ========================================================

                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      22,
                    ),
                    decoration:
                        BoxDecoration(
                      gradient:
                          LinearGradient(
                        begin:
                            Alignment
                                .topLeft,
                        end:
                            Alignment
                                .bottomRight,
                        colors: [
                          colorScheme
                              .primaryContainer,
                          colorScheme
                              .surfaceVariant,
                        ],
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        23,
                      ),
                      border:
                          Border.all(
                        color:
                            colorScheme
                                .outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration:
                              BoxDecoration(
                            color:
                                colorScheme
                                    .primary,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              17,
                            ),
                          ),
                          child: Icon(
                            Icons
                                .palette_rounded,
                            color:
                                colorScheme
                                    .onPrimary,
                            size: 27,
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                "Appearance",
                                style:
                                    theme
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                "Choose the visual theme used throughout the application.",
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  Text(
                    "Theme",
                    style:
                        theme
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    "Your selection applies to the entire application.",
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

                  const SizedBox(
                    height: 16,
                  ),

                  _themeOption(
                    context:
                        context,
                    mode:
                        ThemeMode.system,
                    icon:
                        Icons
                            .brightness_auto_rounded,
                  ),

                  const SizedBox(
                    height: 11,
                  ),

                  _themeOption(
                    context:
                        context,
                    mode:
                        ThemeMode.light,
                    icon:
                        Icons
                            .light_mode_rounded,
                  ),

                  const SizedBox(
                    height: 11,
                  ),

                  _themeOption(
                    context:
                        context,
                    mode:
                        ThemeMode.dark,
                    icon:
                        Icons
                            .dark_mode_rounded,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ACCOUNT SETTINGS SCREEN
// ============================================================================

class AccountSettingsScreen
    extends StatefulWidget {
  const AccountSettingsScreen({
    super.key,
  });

  @override
  State<AccountSettingsScreen>
      createState() =>
          _AccountSettingsScreenState();
}

class _AccountSettingsScreenState
    extends State<AccountSettingsScreen> {

  // ==========================================================================
  // DATA
  // ==========================================================================

  bool loading = true;

  String? errorMessage;

  Map<String, dynamic> account = {};

  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final TextEditingController
      nameController =
          TextEditingController();

  final TextEditingController
      emailController =
          TextEditingController();

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    loadAccount();
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // LOAD ACCOUNT
  // ==========================================================================

  Future<void> loadAccount() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final result =
          await ApiService.getAccount();

      if (!mounted) {
        return;
      }

      setState(() {
        account = result;

        nameController.text =
            result["name"]
                    ?.toString() ??
                "";

        emailController.text =
            result["email"]
                    ?.toString() ??
                "";

        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message =
          e.toString().replaceFirst(
                "Exception: ",
                "",
              );

      if (message.contains(
        "session has expired",
      )) {
        await ApiService.clearToken();

        if (!mounted) {
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const SignInScreen(),
          ),
          (_) => false,
        );

        return;
      }

      setState(() {
        loading = false;
        errorMessage = message;
      });
    }
  }

  // ==========================================================================
  // UPDATE PROFILE
  // ==========================================================================

  Future<void> updateProfile() async {
    final name =
        nameController.text.trim();

    final email =
        emailController.text.trim();

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

    try {
      final result =
          await ApiService.updateProfile(
        name: name,
        email: email,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        account = result;
      });

      _showMessage(
        "Profile updated successfully.",
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message =
          e.toString().replaceFirst(
                "Exception: ",
                "",
              );

      if (message.contains(
        "session has expired",
      )) {
        await ApiService.clearToken();

        if (!mounted) {
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const SignInScreen(),
          ),
          (_) => false,
        );

        return;
      }

      _showMessage(
        message,
      );
    }
  }

  // ==========================================================================
  // EDIT PROFILE
  // ==========================================================================

  Future<void> editProfile() async {
    final temporaryName =
        TextEditingController(
      text: nameController.text,
    );

    final temporaryEmail =
        TextEditingController(
      text: emailController.text,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Edit Profile",
          ),

          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [

              TextField(
                controller:
                    temporaryName,
                textInputAction:
                    TextInputAction.next,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Name",
                  prefixIcon:
                      Icon(
                    Icons
                        .person_outline,
                  ),
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              TextField(
                controller:
                    temporaryEmail,
                keyboardType:
                    TextInputType
                        .emailAddress,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Email",
                  prefixIcon:
                      Icon(
                    Icons
                        .email_outlined,
                  ),
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                "Cancel",
              ),
            ),

            FilledButton(
              onPressed: () async {
                final name =
                    temporaryName
                        .text
                        .trim();

                final email =
                    temporaryEmail
                        .text
                        .trim();

                if (name.isEmpty ||
                    email.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                );

                nameController.text =
                    name;

                emailController.text =
                    email;

                await updateProfile();
              },
              child: const Text(
                "Save",
              ),
            ),
          ],
        );
      },
    );

    temporaryName.dispose();
    temporaryEmail.dispose();
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        content:
            Text(message),
      ),
    );
  }

  // ==========================================================================
  // DATE FORMAT
  // ==========================================================================

  String displayDate(
    dynamic value,
  ) {
    if (value == null) {
      return "Unavailable";
    }

    final text =
        value.toString();

    if (text.isEmpty) {
      return "Unavailable";
    }

    try {
      final date =
          DateTime.parse(
        text,
      );

      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];

      return "${date.day} "
          "${months[date.month - 1]} "
          "${date.year}";
    } catch (_) {
      return text;
    }
  }

  // ==========================================================================
  // INFO ROW
  // ==========================================================================

  Widget _infoRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Row(
      children: [

        Container(
          width: 40,
          height: 40,
          decoration:
              BoxDecoration(
            color:
                colorScheme
                    .primaryContainer,
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color:
                colorScheme
                    .onPrimaryContainer,
          ),
        ),

        const SizedBox(
          width: 13,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [

              Text(
                title,
                style:
                    theme
                        .textTheme
                        .bodySmall
                        ?.copyWith(
                  color:
                      colorScheme
                          .onSurfaceVariant,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(
                value.isEmpty
                    ? "Not provided"
                    : value,
                maxLines: 2,
                overflow:
                    TextOverflow
                        .ellipsis,
                style:
                    theme
                        .textTheme
                        .bodyLarge
                        ?.copyWith(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // OPTION TILE
  // ==========================================================================

  Widget _optionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Material(
      color:
          Colors.transparent,
      child:
          InkWell(
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        onTap:
            onTap,
        child:
            Container(
          padding:
              const EdgeInsets.all(
            18,
          ),
          decoration:
              BoxDecoration(
            color:
                colorScheme.surface,
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border:
                Border.all(
              color:
                  colorScheme
                      .outlineVariant,
            ),
          ),
          child:
              Row(
            children: [

              Container(
                width:
                    46,
                height:
                    46,
                decoration:
                    BoxDecoration(
                  color:
                      colorScheme
                          .primaryContainer,
                  borderRadius:
                      BorderRadius
                          .circular(
                    13,
                  ),
                ),
                child:
                    Icon(
                  icon,
                  color:
                      colorScheme
                          .onPrimaryContainer,
                ),
              ),

              const SizedBox(
                width:
                    14,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [

                    Text(
                      title,
                      style:
                          theme
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),

                    const SizedBox(
                      height:
                          4,
                    ),

                    Text(
                      subtitle,
                      style:
                          theme
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                        color:
                            colorScheme
                                .onSurfaceVariant,
                        height:
                            1.35,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons
                    .arrow_forward_ios_rounded,
                size:
                    16,
                color:
                    colorScheme
                        .onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION LABEL
  // ==========================================================================

  Widget _sectionLabel(
    BuildContext context,
    String text,
  ) {
    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Padding(
      padding:
          const EdgeInsets.only(
        left: 4,
        bottom: 10,
      ),
      child: Text(
        text.toUpperCase(),
        style:
            Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(
          color:
              colorScheme.primary,
          fontWeight:
              FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    // ------------------------------------------------------------------------
    // LOADING
    // ------------------------------------------------------------------------

    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Account",
          ),
        ),
        body:
            const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    // ------------------------------------------------------------------------
    // ERROR
    // ------------------------------------------------------------------------

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Account",
          ),
        ),
        body: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(
              24,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [

                Container(
                  width: 70,
                  height: 70,
                  decoration:
                      BoxDecoration(
                    color:
                        colorScheme
                            .errorContainer,
                    shape:
                        BoxShape.circle,
                  ),
                  child: Icon(
                    Icons
                        .error_outline_rounded,
                    color:
                        colorScheme
                            .onErrorContainer,
                    size: 34,
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                Text(
                  "Unable to load account",
                  style:
                      theme
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  errorMessage!,
                  textAlign:
                      TextAlign.center,
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

                const SizedBox(
                  height: 18,
                ),

                FilledButton.icon(
                  onPressed:
                      loadAccount,
                  icon: const Icon(
                    Icons
                        .refresh_rounded,
                  ),
                  label: const Text(
                    "Try Again",
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // ------------------------------------------------------------------------
    // ACCOUNT PAGE
    // ------------------------------------------------------------------------

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Account",
        ),
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            22,
            24,
            40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 700,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [

                  // ========================================================
                  // PROFILE HEADER
                  // ========================================================

                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      22,
                    ),
                    decoration:
                        BoxDecoration(
                      gradient:
                          LinearGradient(
                        begin:
                            Alignment
                                .topLeft,
                        end:
                            Alignment
                                .bottomRight,
                        colors: [
                          colorScheme
                              .primaryContainer,
                          colorScheme
                              .surfaceVariant,
                        ],
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        24,
                      ),
                      border:
                          Border.all(
                        color:
                            colorScheme
                                .outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [

                        Container(
                          width: 66,
                          height: 66,
                          decoration:
                              BoxDecoration(
                            color:
                                colorScheme
                                    .primary,
                            shape:
                                BoxShape
                                    .circle,
                          ),
                          child: Icon(
                            Icons
                                .person_rounded,
                            color:
                                colorScheme
                                    .onPrimary,
                            size: 32,
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [

                              Text(
                                nameController
                                        .text
                                        .trim()
                                        .isEmpty
                                    ? "Your Account"
                                    : nameController
                                        .text
                                        .trim(),
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    theme
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                emailController
                                    .text
                                    .trim(),
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
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
                            ],
                          ),
                        ),

                        IconButton(
                          tooltip:
                              "Edit profile",
                          onPressed:
                              editProfile,
                          icon: const Icon(
                            Icons
                                .edit_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ========================================================
                  // PROFILE
                  // ========================================================

                  _sectionLabel(
                    context,
                    "Profile",
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      18,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          colorScheme.surface,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                      border:
                          Border.all(
                        color:
                            colorScheme
                                .outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [

                        _infoRow(
                          context:
                              context,
                          icon:
                              Icons
                                  .person_outline,
                          title:
                              "Name",
                          value:
                              nameController
                                  .text,
                        ),

                        const Divider(
                          height: 26,
                        ),

                        _infoRow(
                          context:
                              context,
                          icon:
                              Icons
                                  .email_outlined,
                          title:
                              "Email",
                          value:
                              emailController
                                  .text,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ========================================================
                  // SECURITY
                  // ========================================================

                  _sectionLabel(
                    context,
                    "Security",
                  ),

                  _optionTile(
                    context:
                        context,
                    icon:
                        Icons
                            .lock_outline_rounded,
                    title:
                        "Password & Security",
                    subtitle:
                        "Change your account password.",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ========================================================
                  // ACCOUNT INFORMATION
                  // ========================================================

                  _sectionLabel(
                    context,
                    "Account Information",
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      18,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          colorScheme.surface,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                      border:
                          Border.all(
                        color:
                            colorScheme
                                .outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [

                        _infoRow(
                          context:
                              context,
                          icon:
                              Icons
                                  .fingerprint_rounded,
                          title:
                              "Account ID",
                          value:
                              account[
                                      "user_id"]
                                  ?.toString() ??
                              "Unavailable",
                        ),

                        const Divider(
                          height: 26,
                        ),

                        _infoRow(
                          context:
                              context,
                          icon:
                              Icons
                                  .calendar_today_outlined,
                          title:
                              "Member since",
                          value:
                              displayDate(
                            account[
                                "created_at"],
                          ),
                        ),

                        const Divider(
                          height: 26,
                        ),

                        _infoRow(
                          context:
                              context,
                          icon:
                              Icons
                                  .update_outlined,
                          title:
                              "Last updated",
                          value:
                              displayDate(
                            account[
                                "updated_at"],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CHANGE PASSWORD SCREEN
// ============================================================================

class ChangePasswordScreen
    extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
  });

  @override
  State<ChangePasswordScreen>
      createState() =>
          _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {

  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final TextEditingController
      currentController =
          TextEditingController();

  final TextEditingController
      newController =
          TextEditingController();

  final TextEditingController
      confirmController =
          TextEditingController();

  // ==========================================================================
  // STATE
  // ==========================================================================

  bool loading = false;

  bool obscureCurrent = true;

  bool obscureNew = true;

  bool obscureConfirm = true;

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // CHANGE PASSWORD
  // ==========================================================================

  Future<void> changePassword() async {
    final current =
        currentController.text;

    final newPassword =
        newController.text;

    final confirm =
        confirmController.text;

    if (current.isEmpty) {
      _showMessage(
        "Current password is required.",
      );
      return;
    }

    if (newPassword.length < 6) {
      _showMessage(
        "New password must contain at least 6 characters.",
      );
      return;
    }

    if (newPassword != confirm) {
      _showMessage(
        "New passwords do not match.",
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await ApiService.changePassword(
        currentPassword:
            current,
        newPassword:
            newPassword,
      );

      if (!mounted) {
        return;
      }

      currentController.clear();
      newController.clear();
      confirmController.clear();

      _showMessage(
        "Password updated successfully.",
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      final message =
          e.toString().replaceFirst(
                "Exception: ",
                "",
              );

      if (message.contains(
        "session has expired",
      )) {
        await ApiService.clearToken();

        if (!mounted) {
          return;
        }

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const SignInScreen(),
          ),
          (_) => false,
        );

        return;
      }

      _showMessage(
        message,
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        content:
            Text(message),
      ),
    );
  }

  // ==========================================================================
  // PASSWORD FIELD
  // ==========================================================================

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller:
          controller,
      obscureText:
          obscure,
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
              obscure
                  ? "Show password"
                  : "Hide password",
          onPressed:
              onToggle,
          icon:
              Icon(
            obscure
                ? Icons
                    .visibility_outlined
                : Icons
                    .visibility_off_outlined,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Password & Security",
        ),
      ),

      body: SafeArea(
        child:
            SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            40,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 650,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [

                  // ========================================================
                  // HEADER
                  // ========================================================

                  Container(
                    padding:
                        const EdgeInsets
                            .all(
                      22,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          colorScheme.surface,
                      borderRadius:
                          BorderRadius
                              .circular(
                        22,
                      ),
                      border:
                          Border.all(
                        color:
                            colorScheme
                                .outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [

                        Container(
                          width: 56,
                          height: 56,
                          decoration:
                              BoxDecoration(
                            color:
                                colorScheme
                                    .primaryContainer,
                            borderRadius:
                                BorderRadius
                                    .circular(
                              17,
                            ),
                          ),
                          child: Icon(
                            Icons
                                .shield_outlined,
                            size: 28,
                            color:
                                colorScheme
                                    .onPrimaryContainer,
                          ),
                        ),

                        const SizedBox(
                          width: 14,
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                "Change password",
                                style:
                                    theme
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                "Update the password used to sign in to your account.",
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ========================================================
                  // CURRENT PASSWORD
                  // ========================================================

                  _passwordField(
                    controller:
                        currentController,
                    label:
                        "Current password",
                    hint:
                        "Enter your current password",
                    obscure:
                        obscureCurrent,
                    onToggle: () {
                      setState(() {
                        obscureCurrent =
                            !obscureCurrent;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // ========================================================
                  // NEW PASSWORD
                  // ========================================================

                  _passwordField(
                    controller:
                        newController,
                    label:
                        "New password",
                    hint:
                        "At least 6 characters",
                    obscure:
                        obscureNew,
                    onToggle: () {
                      setState(() {
                        obscureNew =
                            !obscureNew;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // ========================================================
                  // CONFIRM PASSWORD
                  // ========================================================

                  _passwordField(
                    controller:
                        confirmController,
                    label:
                        "Confirm new password",
                    hint:
                        "Enter the new password again",
                    obscure:
                        obscureConfirm,
                    onToggle: () {
                      setState(() {
                        obscureConfirm =
                            !obscureConfirm;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // ========================================================
                  // UPDATE BUTTON
                  // ========================================================

                  SizedBox(
                    height: 52,
                    child:
                        FilledButton.icon(
                      onPressed:
                          loading
                              ? null
                              : changePassword,

                      icon:
                          loading
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                )
                              : const Icon(
                                  Icons
                                      .lock_reset_rounded,
                                ),

                      label:
                          Text(
                        loading
                            ? "Updating..."
                            : "Update Password",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}