import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ReceiptCaptureWidget extends StatefulWidget {
  final Function(XFile?) onImageCaptured;
  final XFile? capturedImage;

  const ReceiptCaptureWidget({
    super.key,
    required this.onImageCaptured,
    this.capturedImage,
  });

  @override
  State<ReceiptCaptureWidget> createState() => _ReceiptCaptureWidgetState();
}

class _ReceiptCaptureWidgetState extends State<ReceiptCaptureWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  XFile? _capturedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _capturedImage = widget.capturedImage;
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();

      // Apply settings (skip unsupported features on web)
      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
      } catch (e) {
        if (kDebugMode) debugPrint('Failed to set focus mode: $e');
      }

      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          if (kDebugMode) debugPrint('Failed to set flash mode: $e');
        }
      }

      setState(() {
        _isCameraInitialized = true;
        _isInitializing = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('Camera initialization failed: $e');
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      setState(() {
        _capturedImage = photo;
      });
      widget.onImageCaptured(photo);
      HapticFeedback.mediumImpact();
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to capture photo: $e');
      // Optionally show an error to the user here.
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _capturedImage = image;
        });
        widget.onImageCaptured(image);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to pick image from gallery: $e');
      // Optionally surface a user-facing message here.
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
    widget.onImageCaptured(null);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Receipt (Optional)',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        _capturedImage != null ? _buildCapturedImage() : _buildCameraOptions(),
      ],
    );
  }

  Widget _buildCapturedImage() {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(
              child: kIsWeb
                  ? Image.network(
                      _capturedImage!.path,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'image',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 8.w,
                            ),
                          ),
                        );
                      },
                    )
                  : Image.file(
                      File(_capturedImage!.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'image',
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                              size: 8.w,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Positioned(
              top: 2.w,
              right: 2.w,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _retakePhoto,
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'refresh',
                        color: Colors.white,
                        size: 5.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _capturedImage = null;
                      });
                      widget.onImageCaptured(null);
                    },
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: 'close',
                        color: Colors.white,
                        size: 5.w,
                      ),
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

  Widget _buildCameraOptions() {
    return Container(
      width: double.infinity,
      height: 30.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child:
          _isCameraInitialized ? _buildCameraPreview() : _buildCameraButtons(),
    );
  }

  Widget _buildCameraPreview() {
    // Defensive: If controller isn't ready, fall back to action buttons
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return _buildCameraButtons();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),
          Positioned(
            bottom: 4.w,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: _pickFromGallery,
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: 'photo_library',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _capturePhoto,
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: CustomIconWidget(
                      iconName: 'camera_alt',
                      color: Colors.white,
                      size: 8.w,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isCameraInitialized = false;
                    });
                    _cameraController?.dispose();
                  },
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomIconWidget(
          iconName: 'camera_alt',
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          size: 12.w,
        ),
        SizedBox(height: 1.5.h),
        Text(
          'Add Receipt Photo',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                if (await _requestCameraPermission()) {
                  await _initializeCamera();
                }
              },
              icon: _isInitializing
                  ? SizedBox(
                      width: 4.w,
                      height: 4.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'camera_alt',
                      color: Colors.white,
                      size: 4.w,
                    ),
              label: Text(_isInitializing ? 'Loading...' : 'Camera'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.6.h),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 4.w,
              ),
              label: const Text('Gallery'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.6.h),
              ),
            ),
          ],
        ),
      ],
    );
  }
}