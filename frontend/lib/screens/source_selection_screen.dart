import 'package:flutter/material.dart';

import 'camera_scanner_screen.dart';
import 'scanner_screen.dart';

class SourceSelectionScreen
    extends StatelessWidget {
  const SourceSelectionScreen({
    super.key,
  });

  // ============================================================
  // OPEN CAMERA
  // ============================================================

  void openCamera(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CameraScannerScreen(),
      ),
    );
  }

  // ============================================================
  // OPEN LIBRARY
  // ============================================================

  void openLibrary(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const ScannerScreen(),
      ),
    );
  }

  // ============================================================
  // BRAND MARK
  // ============================================================

  Widget _buildBrandMark(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.secondary,
          ],
        ),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.receipt_long_rounded,
        size: 22,
        color:
            colorScheme.onPrimary,
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Row(
      children: [
        _buildBrandMark(context),

        const SizedBox(
          width: 12,
        ),

        Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              "Billing Expense Manager",
              style:
                  theme.textTheme.titleMedium
                      ?.copyWith(
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            Text(
              "Receipt intelligence",
              style:
                  theme.textTheme.bodySmall
                      ?.copyWith(
                color:
                    colorScheme
                        .onSurfaceVariant,
              ),
            ),
          ],
        ),

        const Spacer(),

        Tooltip(
          message:
              "Take a photo",
          child:
              IconButton(
            onPressed: () {
              openCamera(context);
            },
            icon:
                const Icon(
              Icons
                  .photo_camera_outlined,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAGE INTRO
  // ============================================================

  Widget _buildIntro(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          "Capture your expenses.",
          style:
              theme.textTheme.displaySmall
                  ?.copyWith(
            fontWeight:
                FontWeight.w800,
            height: 1.05,
            letterSpacing: -1.2,
          ),
        ),

        const SizedBox(
          height: 10,
        ),

        ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 680,
          ),
          child:
              Text(
            "Capture a receipt, protect sensitive information "
            "locally, extract the useful details, and review "
            "everything before it is saved.",
            style:
                theme.textTheme.bodyLarge
                    ?.copyWith(
              color:
                  colorScheme
                      .onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RECEIPT LINE
  // ============================================================

  Widget _receiptLine(
    BuildContext context, {
    required double widthFactor,
  }) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Align(
      alignment:
          Alignment.centerLeft,
      child:
          FractionallySizedBox(
        widthFactor:
            widthFactor,
        child:
            Container(
          height: 7,
          margin:
              const EdgeInsets.only(
            bottom: 9,
          ),
          decoration:
              BoxDecoration(
            color:
                colorScheme.onSurface
                    .withValues(
              alpha: 0.09,
            ),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RECEIPT ILLUSTRATION
  // ============================================================

  Widget _buildReceiptIllustration(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 280,
      child:
          Stack(
        alignment:
            Alignment.center,
        clipBehavior:
            Clip.none,
        children: [
          // ------------------------------------------------------
          // OUTER GLOW
          // ------------------------------------------------------

          Container(
            width: 235,
            height: 235,
            decoration:
                BoxDecoration(
              shape:
                  BoxShape.circle,
              gradient:
                  RadialGradient(
                colors: [
                  colorScheme.primary
                      .withValues(
                    alpha: 0.13,
                  ),
                  colorScheme.primary
                      .withValues(
                    alpha: 0.0,
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------
          // BACK SHADOW SHEET
          // ------------------------------------------------------

          Transform.rotate(
            angle: 0.06,
            child:
                Container(
              width: 175,
              height: 220,
              decoration:
                  BoxDecoration(
                color:
                    colorScheme
                        .primaryContainer
                        .withValues(
                  alpha: 0.55,
                ),
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),
              ),
            ),
          ),

          // ------------------------------------------------------
          // RECEIPT
          // ------------------------------------------------------

          Transform.rotate(
            angle: -0.045,
            child:
                Container(
              width: 185,
              height: 235,
              padding:
                  const EdgeInsets.all(
                20,
              ),
              decoration:
                  BoxDecoration(
                color:
                    colorScheme.surface,
                borderRadius:
                    BorderRadius.circular(
                  8,
                ),
                border:
                    Border.all(
                  color:
                      colorScheme
                          .outlineVariant,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withValues(
                      alpha:
                          theme.brightness ==
                                  Brightness.light
                              ? 0.08
                              : 0.20,
                    ),
                    blurRadius: 28,
                    offset:
                        const Offset(
                      0,
                      14,
                    ),
                  ),
                ],
              ),
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  Center(
                    child:
                        Icon(
                      Icons.storefront_rounded,
                      size: 31,
                      color:
                          colorScheme.primary,
                    ),
                  ),

                  const SizedBox(
                    height: 13,
                  ),

                  _receiptLine(
                    context,
                    widthFactor:
                        0.70,
                  ),

                  _receiptLine(
                    context,
                    widthFactor:
                        0.88,
                  ),

                  _receiptLine(
                    context,
                    widthFactor:
                        0.56,
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _receiptLine(
                    context,
                    widthFactor:
                        0.92,
                  ),

                  _receiptLine(
                    context,
                    widthFactor:
                        0.78,
                  ),

                  _receiptLine(
                    context,
                    widthFactor:
                        0.65,
                  ),

                  const Spacer(),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                    children: [
                      Container(
                        width: 42,
                        height: 8,
                        decoration:
                            BoxDecoration(
                          color:
                              colorScheme
                                  .onSurface
                                  .withValues(
                            alpha: 0.09,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                      ),
                      Container(
                        width: 58,
                        height: 11,
                        decoration:
                            BoxDecoration(
                          color:
                              colorScheme
                                  .primary
                                  .withValues(
                            alpha: 0.18,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ------------------------------------------------------
          // SCANNER BADGE
          // ------------------------------------------------------

          Positioned(
            right: 30,
            bottom: 10,
            child:
                Container(
              width: 62,
              height: 62,
              decoration:
                  BoxDecoration(
                color:
                    colorScheme.primary,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        colorScheme.primary
                            .withValues(
                      alpha: 0.28,
                    ),
                    blurRadius: 20,
                    offset:
                        const Offset(
                      0,
                      9,
                    ),
                  ),
                ],
              ),
              child:
                  Icon(
                Icons
                    .document_scanner_outlined,
                color:
                    colorScheme.onPrimary,
                size: 29,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION TILE
  // ============================================================

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required bool primary,
    required VoidCallback onPressed,
  }) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final background =
        primary
            ? colorScheme.primary
            : colorScheme.surface;

    final foreground =
        primary
            ? colorScheme.onPrimary
            : colorScheme.onSurface;

    return Material(
      color:
          background,
      borderRadius:
          BorderRadius.circular(
        18,
      ),
      child:
          InkWell(
        onTap:
            onPressed,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        child:
            Container(
          padding:
              const EdgeInsets.all(
            16,
          ),
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            border:
                primary
                    ? null
                    : Border.all(
                        color:
                            colorScheme
                                .outlineVariant,
                      ),
          ),
          child:
              Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration:
                    BoxDecoration(
                  color:
                      primary
                          ? Colors.white
                              .withValues(
                          alpha:
                              0.15,
                        )
                          : colorScheme
                              .primaryContainer,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                    Icon(
                  icon,
                  size: 23,
                  color:
                      primary
                          ? foreground
                          : colorScheme
                              .onPrimaryContainer,
                ),
              ),

              const SizedBox(
                width: 14,
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
                          theme.textTheme
                              .titleMedium
                              ?.copyWith(
                        fontWeight:
                            FontWeight.w800,
                        color:
                            foreground,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      description,
                      style:
                          theme.textTheme
                              .bodySmall
                              ?.copyWith(
                        color:
                            primary
                                ? foreground
                                    .withValues(
                                    alpha:
                                        0.78,
                                  )
                                : colorScheme
                                    .onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 8,
              ),

              Icon(
                Icons
                    .arrow_forward_rounded,
                color:
                    primary
                        ? foreground
                        : colorScheme
                            .onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SCAN WORKSPACE
  // ============================================================

  Widget _buildScanWorkspace(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        26,
      ),
      decoration:
          BoxDecoration(
        gradient:
            LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            colorScheme
                .surfaceContainerHighest,
            colorScheme.surface,
          ],
        ),
        borderRadius:
            BorderRadius.circular(
          28,
        ),
        border:
            Border.all(
          color:
              colorScheme
                  .outlineVariant,
        ),
      ),
      child:
          LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          final isWide =
              constraints.maxWidth >=
                  680;

          if (isWide) {
            return Row(
              children: [
                Expanded(
                  flex: 6,
                  child:
                      _buildReceiptIllustration(
                    context,
                  ),
                ),

                const SizedBox(
                  width: 30,
                ),

                Expanded(
                  flex: 5,
                  child:
                      _buildActionArea(
                    context,
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildReceiptIllustration(
                context,
              ),
              const SizedBox(
                height: 14,
              ),
              _buildActionArea(
                context,
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // ACTION AREA
  // ============================================================

  Widget _buildActionArea(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          "Start with a receipt",
          style:
              theme.textTheme.headlineSmall
                  ?.copyWith(
            fontWeight:
                FontWeight.w800,
          ),
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          "Choose how you want to capture it.",
          style:
              theme.textTheme.bodyMedium
                  ?.copyWith(
            color:
                colorScheme
                    .onSurfaceVariant,
          ),
        ),

        const SizedBox(
          height: 22,
        ),

        _buildActionTile(
          context:
              context,
          icon:
              Icons.camera_alt_rounded,
          title:
              "Take a photo",
          description:
              "Capture a new receipt with your camera.",
          primary:
              true,
          onPressed: () {
            openCamera(context);
          },
        ),

        const SizedBox(
          height: 12,
        ),

        _buildActionTile(
          context:
              context,
          icon:
              Icons.upload_file_rounded,
          title:
              "Upload an image",
          description:
              "Choose a receipt already stored on your device.",
          primary:
              false,
          onPressed: () {
            openLibrary(context);
          },
        ),
      ],
    );
  }

  // ============================================================
  // WORKFLOW ITEM
  // ============================================================

  Widget _buildWorkflowItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Expanded(
      child:
          Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration:
                BoxDecoration(
              color:
                  colorScheme
                      .primaryContainer,
              shape:
                  BoxShape.circle,
            ),
            child:
                Icon(
              icon,
              size: 21,
              color:
                  colorScheme
                      .onPrimaryContainer,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            title,
            textAlign:
                TextAlign.center,
            style:
                theme.textTheme
                    .titleSmall
                    ?.copyWith(
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            description,
            textAlign:
                TextAlign.center,
            style:
                theme.textTheme
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
    );
  }

  // ============================================================
  // CONNECTOR
  // ============================================================

  Widget _buildConnector(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return SizedBox(
      width: 32,
      child:
          Padding(
        padding:
            const EdgeInsets.only(
          top: 23,
        ),
        child:
            Container(
          height: 1,
          color:
              colorScheme
                  .outlineVariant,
        ),
      ),
    );
  }

  // ============================================================
  // WORKFLOW
  // ============================================================

  Widget _buildWorkflow(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        24,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        border:
            Border.all(
          color:
              colorScheme
                  .outlineVariant,
        ),
      ),
      child:
          LayoutBuilder(
        builder: (
          context,
          constraints,
        ) {
          if (constraints.maxWidth <
              700) {
            return Column(
              children: [
                _buildVerticalWorkflowItem(
                  context,
                  Icons.camera_alt_outlined,
                  "Capture",
                  "Take or upload a receipt.",
                ),
                _buildVerticalConnector(
                  context,
                ),
                _buildVerticalWorkflowItem(
                  context,
                  Icons.shield_outlined,
                  "Sanitize",
                  "Protect sensitive information locally.",
                ),
                _buildVerticalConnector(
                  context,
                ),
                _buildVerticalWorkflowItem(
                  context,
                  Icons.auto_awesome_outlined,
                  "Extract",
                  "AI reads the important details.",
                ),
                _buildVerticalConnector(
                  context,
                ),
                _buildVerticalWorkflowItem(
                  context,
                  Icons.fact_check_outlined,
                  "Review",
                  "Check everything before saving.",
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildWorkflowItem(
                context: context,
                icon:
                    Icons.camera_alt_outlined,
                title:
                    "Capture",
                description:
                    "Take or upload a receipt.",
              ),

              _buildConnector(
                context,
              ),

              _buildWorkflowItem(
                context: context,
                icon:
                    Icons.shield_outlined,
                title:
                    "Sanitize",
                description:
                    "Protect sensitive information locally.",
              ),

              _buildConnector(
                context,
              ),

              _buildWorkflowItem(
                context: context,
                icon:
                    Icons.auto_awesome_outlined,
                title:
                    "Extract",
                description:
                    "AI reads the important details.",
              ),

              _buildConnector(
                context,
              ),

              _buildWorkflowItem(
                context: context,
                icon:
                    Icons.fact_check_outlined,
                title:
                    "Review",
                description:
                    "Check everything before saving.",
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // VERTICAL WORKFLOW ITEM
  // ============================================================

  Widget _buildVerticalWorkflowItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration:
              BoxDecoration(
            color:
                colorScheme
                    .primaryContainer,
            shape:
                BoxShape.circle,
          ),
          child:
              Icon(
            icon,
            size: 20,
            color:
                colorScheme
                    .onPrimaryContainer,
          ),
        ),

        const SizedBox(
          width: 14,
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
                    theme.textTheme
                        .titleSmall
                        ?.copyWith(
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                description,
                style:
                    theme.textTheme
                        .bodySmall
                        ?.copyWith(
                  color:
                      colorScheme
                          .onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // VERTICAL CONNECTOR
  // ============================================================

  Widget _buildVerticalConnector(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(context).colorScheme;

    return Align(
      alignment:
          Alignment.centerLeft,
      child:
          Container(
        width: 2,
        height: 22,
        margin:
            const EdgeInsets.only(
          left: 21,
          top: 5,
          bottom: 5,
        ),
        color:
            colorScheme
                .outlineVariant,
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
      body:
          Stack(
        children: [
          // ========================================================
          // BACKGROUND ACCENTS
          // ========================================================

          Positioned(
            top: -170,
            right: -130,
            child:
                IgnorePointer(
              child:
                  Container(
                width: 430,
                height: 430,
                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,
                  gradient:
                      RadialGradient(
                    colors: [
                      colorScheme.primary
                          .withValues(
                        alpha: 0.07,
                      ),
                      colorScheme.primary
                          .withValues(
                        alpha: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -210,
            left: -170,
            child:
                IgnorePointer(
              child:
                  Container(
                width: 470,
                height: 470,
                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,
                  gradient:
                      RadialGradient(
                    colors: [
                      colorScheme.secondary
                          .withValues(
                        alpha: 0.06,
                      ),
                      colorScheme.secondary
                          .withValues(
                        alpha: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ========================================================
          // MAIN CONTENT
          // ========================================================

          SafeArea(
            child:
                Center(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.fromLTRB(
                  28,
                  24,
                  28,
                  42,
                ),
                child:
                    ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 1120,
                  ),
                  child:
                      Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .stretch,
                    children: [
                      _buildHeader(
                        context,
                      ),

                      const SizedBox(
                        height: 54,
                      ),

                      _buildIntro(
                        context,
                      ),

                      const SizedBox(
                        height: 28,
                      ),

                      _buildScanWorkspace(
                        context,
                      ),

                      const SizedBox(
                        height: 42,
                      ),

                      Text(
                        "How it works",
                        style:
                            theme.textTheme
                                .headlineSmall
                                ?.copyWith(
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        "A simple protected path from receipt image to saved expense.",
                        style:
                            theme.textTheme
                                .bodyMedium
                                ?.copyWith(
                          color:
                              colorScheme
                                  .onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      _buildWorkflow(
                        context,
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // ==================================================
                      // PRIVACY STRIP
                      // ==================================================

                      Container(
                        width:
                            double.infinity,
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              colorScheme
                                  .surfaceContainerHighest,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            15,
                          ),
                        ),
                        child:
                            Row(
                          children: [
                            Icon(
                              Icons
                                  .security_outlined,
                              size: 19,
                              color:
                                  colorScheme
                                      .primary,
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  Text(
                                "Sensitive information is sanitized locally before the receipt image is sent to the backend.",
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
        ],
      ),
    );
  }
}