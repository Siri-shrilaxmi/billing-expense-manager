import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'scanner_screen.dart';

class CameraScannerScreen
    extends StatefulWidget {
  const CameraScannerScreen({
    super.key,
  });

  @override
  State<CameraScannerScreen>
      createState() =>
          _CameraScannerScreenState();
}

class _CameraScannerScreenState
    extends State<CameraScannerScreen> {
  CameraController? _controller;

  bool initializing = true;
  bool capturing = false;

  String? errorMessage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    initializeCamera();
  }

  // ============================================================
  // INITIALIZE CAMERA
  // ============================================================

  Future<void> initializeCamera() async {
    try {
      final cameras =
          await availableCameras();

      if (cameras.isEmpty) {
        throw Exception(
          "No camera was found on this device.",
        );
      }

      CameraDescription selectedCamera =
          cameras.first;

      for (final camera
          in cameras) {
        if (camera.lensDirection ==
            CameraLensDirection.back) {
          selectedCamera =
              camera;
          break;
        }
      }

      final controller =
          CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller =
            controller;

        initializing = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        initializing = false;

        errorMessage =
            e.toString()
                .replaceFirst(
              "Exception: ",
              "",
            );
      });
    }
  }

  // ============================================================
  // TAKE PHOTO
  // ============================================================

  Future<void> takePhoto() async {
    final controller =
        _controller;

    if (capturing ||
        controller == null ||
        !controller.value
            .isInitialized) {
      return;
    }

    setState(() {
      capturing = true;
    });

    try {
      final XFile file =
          await controller.takePicture();

      final Uint8List bytes =
          await file.readAsBytes();

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              ScannerScreen(
            initialImage:
                bytes,
            source:
                "camera_capture",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        capturing = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          behavior:
              SnackBarBehavior.floating,
          content:
              Text(
            "Could not capture image: $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // CAMERA GUIDE
  // ============================================================

  Widget _buildGuide(
    BuildContext context,
  ) {
    return IgnorePointer(
      child:
          Center(
        child:
            Container(
          width: 310,
          height: 410,
          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              24,
            ),
            border:
                Border.all(
              color:
                  Colors.white
                      .withValues(
                alpha: 0.92,
              ),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar(
    BuildContext context,
  ) {
    return SafeArea(
      bottom: false,
      child:
          Padding(
        padding:
            const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          0,
        ),
        child:
            Row(
          children: [
            Container(
              decoration:
                  BoxDecoration(
                color:
                    Colors.black.withValues(
                  alpha: 0.42,
                ),
                shape:
                    BoxShape.circle,
              ),
              child:
                  IconButton(
                tooltip:
                    "Back",
                onPressed:
                    capturing
                        ? null
                        : () {
                            Navigator
                                .pop(
                              context,
                            );
                          },
                icon:
                    const Icon(
                  Icons
                      .arrow_back_rounded,
                  color:
                      Colors.white,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 14,
                vertical: 9,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.black.withValues(
                  alpha: 0.42,
                ),
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
              child:
                  const Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .document_scanner_outlined,
                    color:
                        Colors.white,
                    size: 17,
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Text(
                    "Receipt Scanner",
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM CAPTURE BAR
  // ============================================================

  Widget _buildBottomBar(
    BuildContext context,
  ) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child:
          SafeArea(
        top: false,
        child:
            Column(
          children: [
            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 15,
                vertical: 9,
              ),
              decoration:
                  BoxDecoration(
                color:
                    Colors.black.withValues(
                  alpha: 0.42,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child:
                  Text(
                capturing
                    ? "Capturing receipt..."
                    : "Place the receipt inside the frame",
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            GestureDetector(
              onTap:
                  capturing
                      ? null
                      : takePhoto,
              child:
                  AnimatedContainer(
                duration:
                    const Duration(
                  milliseconds: 180,
                ),
                width: 82,
                height: 82,
                padding:
                    const EdgeInsets
                        .all(
                  6,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.white
                          .withValues(
                    alpha:
                        capturing
                            ? 0.55
                            : 0.96,
                  ),
                  shape:
                      BoxShape.circle,
                ),
                child:
                    Container(
                  decoration:
                      BoxDecoration(
                    color:
                        capturing
                            ? Colors
                                .grey
                            : Colors
                                .white,
                    shape:
                        BoxShape.circle,
                    border:
                        Border.all(
                      color:
                          Colors.black12,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    final theme =
        Theme.of(context);

    final colorScheme =
        theme.colorScheme;

    return Scaffold(
      body:
          Center(
        child:
            Padding(
          padding:
              const EdgeInsets.all(
            24,
          ),
          child:
              ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 440,
            ),
            child:
                Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration:
                      BoxDecoration(
                    color:
                        colorScheme
                            .errorContainer,
                    shape:
                        BoxShape.circle,
                  ),
                  child:
                      Icon(
                    Icons
                        .camera_alt_outlined,
                    size: 38,
                    color:
                        colorScheme
                            .onErrorContainer,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  "Camera unavailable",
                  style: theme
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  errorMessage ??
                      "The camera could not be initialized.",
                  textAlign:
                      TextAlign.center,
                  style: theme
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color:
                        colorScheme
                            .onSurfaceVariant,
                    height: 1.45,
                  ),
                ),

                const SizedBox(
                  height: 22,
                ),

                FilledButton.icon(
                  onPressed: () {
                    setState(() {
                      initializing =
                          true;
                      errorMessage =
                          null;
                    });

                    initializeCamera();
                  },
                  icon:
                      const Icon(
                    Icons
                        .refresh_rounded,
                  ),
                  label:
                      const Text(
                    "Try Again",
                  ),
                ),
              ],
            ),
          ),
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
    if (initializing) {
      return const Scaffold(
        backgroundColor:
            Colors.black,
        body:
            Center(
          child:
              CircularProgressIndicator(
            color:
                Colors.white,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return _buildError();
    }

    final controller =
        _controller;

    if (controller == null ||
        !controller.value
            .isInitialized) {
      return const Scaffold(
        backgroundColor:
            Colors.black,
        body:
            Center(
          child:
              Text(
            "Camera is unavailable.",
            style:
                TextStyle(
              color:
                  Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          Colors.black,

      body:
          Stack(
        fit:
            StackFit.expand,
        children: [
          // ========================================================
          // CAMERA
          // ========================================================

          CameraPreview(
            controller,
          ),

          // ========================================================
          // DIMMED GUIDE AREA
          // ========================================================

          Container(
            color:
                Colors.black.withValues(
              alpha: 0.12,
            ),
          ),

          _buildGuide(
            context,
          ),

          // ========================================================
          // TOP
          // ========================================================

          _buildTopBar(
            context,
          ),

          // ========================================================
          // CENTER LABEL
          // ========================================================

          Positioned(
            left: 0,
            right: 0,
            top: 110,
            child:
                Center(
              child:
                  Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.black
                          .withValues(
                    alpha:
                        0.42,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                    const Text(
                  "Align the receipt within the frame",
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // ========================================================
          // BOTTOM
          // ========================================================

          _buildBottomBar(
            context,
          ),
        ],
      ),
    );
  }
}