import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/image_preprocessor.dart';
import '../services/image_sanitizer.dart';
import 'sign_in_screen.dart';

class ScannerScreen extends StatefulWidget {
  final Uint8List? initialImage;
  final String source;

  const ScannerScreen({
    super.key,
    this.initialImage,
    this.source = "file_upload",
  });

  @override
  State<ScannerScreen> createState() =>
      _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // ============================================================
  // IMAGE
  // ============================================================

  Uint8List? displayedImage;

  String? imageSource;

  // ============================================================
  // PROCESSING
  // ============================================================

  bool processing = false;

  double? processingTimeMs;

  String processingStatus = "Ready.";

  // ============================================================
  // QWEN
  // ============================================================

  Map<String, dynamic>? qwenResult;

  // ============================================================
  // FORM
  // ============================================================

  final TextEditingController merchantController =
      TextEditingController();

  final TextEditingController dateTimeController =
      TextEditingController();

  final TextEditingController totalCostController =
      TextEditingController();

  final TextEditingController noteController =
      TextEditingController();

  // ============================================================
  // CURRENCY
  // ============================================================

  String selectedCurrency = "INR";

  final List<String> currencies = const [
    "INR",
    "USD",
    "EUR",
    "GBP",
    "JPY",
    "AED",
    "AUD",
    "CAD",
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    if (widget.initialImage != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          processImage(
            widget.initialImage!,
            widget.source,
          );
        },
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    merchantController.dispose();
    dateTimeController.dispose();
    totalCostController.dispose();
    noteController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    if (processing) {
      return;
    }

    final result =
        await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) {
      return;
    }

    final bytes =
        result.files.single.bytes;

    if (bytes == null ||
        bytes.isEmpty) {
      return;
    }

    await processImage(
      bytes,
      "file_upload",
    );
  }

  // ============================================================
  // IMAGE PIPELINE
  // ============================================================

  Future<void> processImage(
    Uint8List bytes,
    String source,
  ) async {
    if (bytes.isEmpty) {
      return;
    }

    setState(() {
      displayedImage = bytes;
      imageSource = source;

      processing = true;
      processingTimeMs = null;
      qwenResult = null;

      processingStatus =
          "Preprocessing image...";

      merchantController.clear();
      dateTimeController.clear();
      totalCostController.clear();
      noteController.clear();

      selectedCurrency = "INR";
    });

    final stopwatch =
        Stopwatch()..start();

    try {
      // ========================================================
      // STEP 1
      // ========================================================

      final preprocessed =
          await ImagePreprocessor.preprocess(
        bytes,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        processingStatus =
            "Sanitizing image locally...";
      });

      // ========================================================
      // STEP 2
      // ========================================================

      final sanitized =
          await ImageSanitizer.sanitize(
        preprocessed,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        displayedImage = sanitized;

        processingStatus =
            "Analyzing sanitized image...";
      });

      // ========================================================
      // STEP 3
      // ========================================================

      final result =
          await ApiService.analyzeImage(
        sanitized,
      );

      stopwatch.stop();

      if (!mounted) {
        return;
      }

      setState(() {
        processing = false;

        processingTimeMs =
            stopwatch.elapsedMicroseconds /
                1000.0;

        processingStatus =
            "Analysis completed.";

        qwenResult = result;
      });

      populateEditableFields(
        result,
      );
    } catch (e) {
      stopwatch.stop();

      if (!mounted) {
        return;
      }

      setState(() {
        processing = false;

        processingTimeMs =
            stopwatch.elapsedMicroseconds /
                1000.0;

        processingStatus =
            "Processing failed.";
      });

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
        "Processing failed: $message",
      );
    }
  }

  // ============================================================
  // QWEN CLEANING
  // ============================================================

  String _cleanQwenField(
    dynamic value,
    String placeholder,
  ) {
    if (value == null) {
      return "";
    }

    final text =
        value.toString().trim();

    if (text.isEmpty) {
      return "";
    }

    if (text.toLowerCase() ==
        placeholder.toLowerCase()) {
      return "";
    }

    return text;
  }

  // ============================================================
  // POPULATE
  // ============================================================

  void populateEditableFields(
    Map<String, dynamic> result,
  ) {
    merchantController.text =
        _cleanQwenField(
      result["merchant"],
      "Name of the store or restaurant",
    );

    dateTimeController.text =
        _cleanQwenField(
      result["date_time"],
      "Date and time of transaction",
    );

    totalCostController.text =
        _cleanQwenField(
      result["total_cost"],
      "Final total amount paid",
    );

    noteController.clear();

    if (mounted) {
      setState(() {});
    }
  }

  // ============================================================
  // CAN SAVE
  // ============================================================

  bool get canSave {
    return merchantController.text
            .trim()
            .isNotEmpty &&
        totalCostController.text
            .trim()
            .isNotEmpty;
  }

  // ============================================================
  // CONFIDENCE
  // ============================================================

  double? _getGenerationConfidence() {
    final value =
        qwenResult?[
            "generation_confidence"];

    if (value == null) {
      return null;
    }

    return double.tryParse(
      value.toString(),
    );
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> saveReceipt() async {
    if (!canSave) {
      return;
    }

    if (imageSource == null) {
      _showMessage(
        "No image source is available.",
      );
      return;
    }

    try {
      setState(() {
        processing = true;
        processingStatus =
            "Saving receipt...";
      });

      final result =
          await ApiService.saveReceipt(
        merchant:
            merchantController.text.trim(),

        totalCost:
            totalCostController.text.trim(),

        currency:
            selectedCurrency,

        paymentTime:
            dateTimeController.text
                    .trim()
                    .isEmpty
                ? null
                : dateTimeController.text
                    .trim(),

        notes:
            noteController.text
                    .trim()
                    .isEmpty
                ? null
                : noteController.text
                    .trim(),

        source:
            imageSource,

        qwenResult:
            qwenResult,

        generationConfidence:
            _getGenerationConfidence(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        processing = false;
        processingStatus =
            "Receipt saved.";
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          content:
              Text(
            "Receipt saved successfully. "
            "Receipt ID: ${result["receipt_id"]}",
          ),
        ),
      );

      Navigator.popUntil(
        context,
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        processing = false;
        processingStatus =
            "Save failed.";
      });

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

      _showMessage(message);
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
        behavior:
            SnackBarBehavior.floating,
        content:
            Text(message),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    if (processing) {
      _showMessage(
        "Please wait until the current operation finishes.",
      );
      return;
    }

    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) {
        return AlertDialog(
          title:
              const Text(
            "Sign Out",
          ),
          content:
              const Text(
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
              child:
                  const Text(
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
              child:
                  const Text(
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
  }

  // ============================================================
  // CURRENCY
  // ============================================================

  String _currencySymbol(
    String currency,
  ) {
    switch (currency) {
      case "INR":
        return "₹ ";

      case "USD":
        return "\$ ";

      case "EUR":
        return "€ ";

      case "GBP":
        return "£ ";

      case "JPY":
        return "¥ ";

      case "AED":
        return "د.إ ";

      case "AUD":
        return "A\$ ";

      case "CAD":
        return "C\$ ";

      default:
        return "";
    }
  }

  // ============================================================
  // STAGE
  // ============================================================

  Widget _buildStage(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool active,
    required bool complete,
  }) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final color =
        active || complete
            ? colorScheme.primary
            : colorScheme
                .onSurfaceVariant
                .withValues(
              alpha: 0.55,
            );

    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration:
              BoxDecoration(
            color: color,
            shape:
                BoxShape.circle,
          ),
        ),
        const SizedBox(
          width: 6,
        ),
        Icon(
          icon,
          size: 15,
          color: color,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          title,
          style: theme
              .textTheme
              .bodySmall
              ?.copyWith(
            color: color,
            fontWeight:
                active
                    ? FontWeight.w700
                    : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // IMAGE AREA
  // ============================================================

  Widget _buildImageArea(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 500,
      child:
          Container(
        clipBehavior:
            Clip.antiAlias,
        decoration:
            BoxDecoration(
          color:
              colorScheme
                  .surfaceContainerHighest,
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
            displayedImage == null
                ? _buildEmptyImage(
                    context,
                  )
                : Stack(
                    fit:
                        StackFit.expand,
                    children: [
                      Image.memory(
                        displayedImage!,
                        fit:
                            BoxFit.contain,
                      ),
                      Positioned(
                        left: 16,
                        top: 16,
                        child:
                            Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration:
                              BoxDecoration(
                            color:
                                Colors.black
                                    .withValues(
                              alpha: 0.55,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                          child:
                              Row(
                            mainAxisSize:
                                MainAxisSize
                                    .min,
                            children: [
                              const Icon(
                                Icons
                                    .shield_outlined,
                                size: 15,
                                color:
                                    Colors.white,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(
                                processing
                                    ? "Processing"
                                    : "Sanitized image",
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildEmptyImage(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Container(
          width: 86,
          height: 86,
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
            Icons
                .document_scanner_outlined,
            size: 38,
            color:
                colorScheme
                    .onPrimaryContainer,
          ),
        ),
        const SizedBox(
          height: 18,
        ),
        Text(
          "No receipt selected",
          style:
              theme.textTheme
                  .titleLarge
                  ?.copyWith(
            fontWeight:
                FontWeight.w800,
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        Text(
          "Upload a receipt to begin.",
          style:
              theme.textTheme
                  .bodyMedium
                  ?.copyWith(
            color:
                colorScheme
                    .onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // REVIEW
  // ============================================================

  Widget _buildReview(
    BuildContext context,
  ) {
    if (qwenResult == null) {
      return const SizedBox.shrink();
    }

    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    final confidence =
        qwenResult?[
            "generation_confidence"];

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme.surface,
        borderRadius:
            BorderRadius.circular(
          24,
        ),
        border:
            Border.all(
          color:
              colorScheme
                  .outlineVariant,
        ),
      ),
      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Text(
            "Review receipt",
            style:
                theme.textTheme
                    .headlineSmall
                    ?.copyWith(
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            "Check the extracted information before saving.",
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

          TextField(
            controller:
                merchantController,
            onChanged:
                (_) => setState(
              () {},
            ),
            decoration:
                const InputDecoration(
              labelText:
                  "Merchant *",
              prefixIcon:
                  Icon(
                Icons.storefront_outlined,
              ),
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          TextField(
            controller:
                dateTimeController,
            onChanged:
                (_) => setState(
              () {},
            ),
            decoration:
                const InputDecoration(
              labelText:
                  "Date / Time",
              prefixIcon:
                  Icon(
                Icons.schedule_outlined,
              ),
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          Row(
            children: [
              Expanded(
                flex: 2,
                child:
                    TextField(
                  controller:
                      totalCostController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal:
                        true,
                  ),
                  onChanged:
                      (_) => setState(
                    () {},
                  ),
                  decoration:
                      InputDecoration(
                    labelText:
                        "Total *",
                    prefixText:
                        _currencySymbol(
                      selectedCurrency,
                    ),
                    prefixIcon:
                        const Icon(
                      Icons
                          .payments_outlined,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                    DropdownButtonFormField<
                        String>(
                  initialValue:
                      selectedCurrency,
                  decoration:
                      const InputDecoration(
                    labelText:
                        "Currency",
                  ),
                  items:
                      currencies.map(
                    (currency) {
                      return DropdownMenuItem<
                          String>(
                        value:
                            currency,
                        child:
                            Text(
                          currency,
                        ),
                      );
                    },
                  ).toList(),
                  onChanged:
                      (value) {
                    if (value ==
                        null) {
                      return;
                    }

                    setState(() {
                      selectedCurrency =
                          value;
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          TextField(
            controller:
                noteController,
            maxLines:
                3,
            decoration:
                const InputDecoration(
              labelText:
                  "Note",
              prefixIcon:
                  Icon(
                Icons.notes_outlined,
              ),
              alignLabelWithHint:
                  true,
            ),
          ),

          _buildMissingMessage(
            context,
          ),

          if (confidence !=
              null) ...[
            const SizedBox(
              height: 14,
            ),
            Text(
              "Qwen confidence: $confidence",
              style:
                  theme.textTheme
                      .bodySmall
                      ?.copyWith(
                color:
                    colorScheme
                        .onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // MISSING
  // ============================================================

  Widget _buildMissingMessage(
    BuildContext context,
  ) {
    final missing =
        <String>[];

    if (merchantController.text
        .trim()
        .isEmpty) {
      missing.add(
        "merchant",
      );
    }

    if (totalCostController.text
        .trim()
        .isEmpty) {
      missing.add(
        "total",
      );
    }

    if (missing.isEmpty) {
      return const SizedBox.shrink();
    }

    final colorScheme =
        Theme.of(context)
            .colorScheme;

    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        top: 13,
      ),
      padding:
          const EdgeInsets.all(
        11,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme
                .errorContainer,
        borderRadius:
            BorderRadius.circular(
          11,
        ),
      ),
      child:
          Text(
        "Missing: ${missing.join(", ")}",
        style:
            TextStyle(
          color:
              colorScheme
                  .onErrorContainer,
          fontWeight:
              FontWeight.w600,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatus(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 15,
        vertical: 11,
      ),
      decoration:
          BoxDecoration(
        color:
            colorScheme
                .surfaceContainerHighest,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),
      child:
          Row(
        children: [
          if (processing)
            SizedBox(
              width: 16,
              height: 16,
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
                color:
                    colorScheme.primary,
              ),
            )
          else
            Icon(
              qwenResult !=
                      null
                  ? Icons
                      .check_circle_outline
                  : Icons
                      .info_outline,
              size: 18,
              color:
                  qwenResult !=
                          null
                      ? Colors.green
                      : colorScheme
                          .primary,
            ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child:
                Text(
              processing
                  ? processingStatus
                  : qwenResult !=
                          null
                      ? "Analysis completed."
                      : "Choose a receipt to begin.",
              style:
                  theme.textTheme
                      .bodySmall
                      ?.copyWith(
                fontWeight:
                    FontWeight.w600,
              ),
            ),
          ),

          if (!processing &&
              processingTimeMs !=
                  null)
            Text(
              "${processingTimeMs!.toStringAsFixed(0)} ms",
              style:
                  theme.textTheme
                      .bodySmall
                      ?.copyWith(
                color:
                    colorScheme
                        .onSurfaceVariant,
              ),
            ),
        ],
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
          SafeArea(
        child:
            Center(
          child:
              SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(
              24,
              20,
              24,
              35,
            ),
            child:
                ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth:
                    1160,
              ),
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Row(
                    children: [
                      IconButton(
                        tooltip:
                            "Back",
                        onPressed:
                            processing
                                ? null
                                : () =>
                                    Navigator.pop(
                                      context,
                                    ),
                        icon:
                            const Icon(
                          Icons
                              .arrow_back_rounded,
                        ),
                      ),

                      Container(
                        width: 38,
                        height: 38,
                        decoration:
                            BoxDecoration(
                          color:
                              colorScheme
                                  .primaryContainer,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            11,
                          ),
                        ),
                        child:
                            Icon(
                          Icons
                              .document_scanner_outlined,
                          size: 21,
                          color:
                              colorScheme
                                  .onPrimaryContainer,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child:
                            Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              "Receipt Scanner",
                              style:
                                  theme.textTheme
                                      .titleLarge
                                      ?.copyWith(
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                            Text(
                              "Capture • Protect • Extract • Review",
                              style:
                                  theme.textTheme
                                      .bodySmall
                                      ?.copyWith(
                                color:
                                    colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      PopupMenuButton<
                          String>(
                        enabled:
                            !processing,
                        onSelected:
                            (value) {
                          if (value ==
                              "logout") {
                            logout();
                          }
                        },
                        itemBuilder:
                            (context) =>
                                const [
                          PopupMenuItem<
                              String>(
                            value:
                                "logout",
                            child:
                                Text(
                              "Sign Out",
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ==================================================
                  // PIPELINE
                  // ==================================================

                  Container(
                    width:
                        double.infinity,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          colorScheme
                              .surfaceContainerHighest,
                      borderRadius:
                          BorderRadius
                              .circular(
                        14,
                      ),
                    ),
                    child:
                        Wrap(
                      spacing: 22,
                      runSpacing: 8,
                      children: [
                        _buildStage(
                          context,
                          title:
                              "Capture",
                          icon:
                              Icons
                                  .camera_alt_outlined,
                          active:
                              displayedImage !=
                                      null &&
                                  qwenResult ==
                                      null &&
                                  !processingStatus
                                      .contains(
                                    "Sanitizing",
                                  ) &&
                                  !processingStatus
                                      .contains(
                                    "Analyzing",
                                  ),
                          complete:
                              displayedImage !=
                                  null,
                        ),
                        _buildStage(
                          context,
                          title:
                              "Sanitize",
                          icon:
                              Icons
                                  .shield_outlined,
                          active:
                              processingStatus
                                  .contains(
                                "Sanitizing",
                              ),
                          complete:
                              displayedImage !=
                                      null &&
                                  !processingStatus
                                      .contains(
                                    "Preprocessing",
                                  ),
                        ),
                        _buildStage(
                          context,
                          title:
                              "Extract",
                          icon:
                              Icons
                                  .auto_awesome_outlined,
                          active:
                              processingStatus
                                  .contains(
                                "Analyzing",
                              ),
                          complete:
                              qwenResult !=
                                  null,
                        ),
                        _buildStage(
                          context,
                          title:
                              "Review",
                          icon:
                              Icons
                                  .fact_check_outlined,
                          active:
                              qwenResult !=
                                  null,
                          complete:
                              false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ==================================================
                  // IMAGE
                  // ==================================================

                  _buildImageArea(
                    context,
                  ),

                  // ==================================================
                  // REVIEW
                  // ==================================================

                  if (qwenResult !=
                      null) ...[
                    const SizedBox(
                      height: 18,
                    ),
                    _buildReview(
                      context,
                    ),
                  ],

                  const SizedBox(
                    height: 18,
                  ),

                  // ==================================================
                  // STATUS
                  // ==================================================

                  _buildStatus(
                    context,
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // ==================================================
                  // ACTIONS
                  // ==================================================

                  Row(
                    children: [
                      Expanded(
                        child:
                            OutlinedButton.icon(
                          onPressed:
                              processing
                                  ? null
                                  : pickImage,
                          icon:
                              const Icon(
                            Icons
                                .upload_file_outlined,
                          ),
                          label:
                              Text(
                            displayedImage ==
                                    null
                                ? "Choose Receipt"
                                : "Choose Another",
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child:
                            FilledButton.icon(
                          onPressed:
                              processing ||
                                      !canSave
                                  ? null
                                  : saveReceipt,
                          icon:
                              const Icon(
                            Icons
                                .save_outlined,
                          ),
                          label:
                              const Text(
                            "Save Receipt",
                          ),
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
    );
  }
}