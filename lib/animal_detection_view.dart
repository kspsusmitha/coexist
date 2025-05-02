import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:image_picker/image_picker.dart';

class AnimalDetectionView extends StatefulWidget {
  const AnimalDetectionView({super.key});

  @override
  State<AnimalDetectionView> createState() => _AnimalDetectionViewState();
}

class _AnimalDetectionViewState extends State<AnimalDetectionView> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  bool _isDetecting = false;
  String? _detectedAnimal;
  String? _animalDetails;
  String? _errorMessage;
  File? _selectedImage;
  final _imagePicker = ImagePicker();
  final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: 'AIzaSyApHNMo6vyWhc2rooOLubtxVpDdQvAEqRo',
  );

  void _logError(String message, dynamic error, [StackTrace? stackTrace]) {
    debugPrint('Error: $message');
    debugPrint('Error details: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e, stackTrace) {
      _logError('Image picker failed', e, stackTrace);
      setState(() {
        _errorMessage = 'Failed to pick image: ${e.toString()}';
      });
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        setState(() {
          _errorMessage = 'No internet connection. Please check your network and try again.';
        });
        return false;
      }
      return true;
    } catch (e, stackTrace) {
      _logError('Network connectivity check failed', e, stackTrace);
      setState(() {
        _errorMessage = 'Error checking network connection: ${e.toString()}';
      });
      return false;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Check if camera permission is already granted
      var status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
        if (status.isDenied) {
          setState(() {
            _errorMessage = 'Camera permission is required to use this feature';
          });
          return;
        }
      }

      // Get available cameras
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available on this device';
        });
        return;
      }

      // Try to initialize the camera with error handling
      try {
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _controller!.initialize();
        
        // Check if the camera is still mounted after initialization
        if (!mounted) return;

        setState(() {
          _isCameraInitialized = true;
          _errorMessage = null;
        });
      } catch (e, stackTrace) {
        _logError('Camera initialization failed', e, stackTrace);
        setState(() {
          _errorMessage = 'Failed to initialize camera: ${e.toString()}';
        });
        // Try to dispose the controller if it was created but failed to initialize
        await _controller?.dispose();
        _controller = null;
      }
    } catch (e, stackTrace) {
      _logError('Camera access failed', e, stackTrace);
      setState(() {
        _errorMessage = 'Error accessing camera: ${e.toString()}';
      });
    }
  }

  Future<void> _detectAnimal() async {
    if (!await _checkInternetConnection()) {
      return;
    }

    setState(() {
      _isDetecting = true;
      _errorMessage = null;
    });

    try {
      Uint8List bytes;
      if (_selectedImage != null) {
        bytes = await _selectedImage!.readAsBytes();
      } else if (_controller != null && _isCameraInitialized) {
        final image = await _controller!.takePicture();
        bytes = await File(image.path).readAsBytes();
      } else {
        setState(() {
          _errorMessage = 'No image source available';
          _isDetecting = false;
        });
        return;
      }
      
      final prompt = TextPart('''
        Analyze this image and provide detailed information about any animals present in JSON format.
        Include the following fields if applicable:
        - common_name
        - scientific_name
        - species
        - habitat
        - diet
        - conservation_status
        - interesting_facts
        - geographical_distribution
      ''');
      
      final imagePart = DataPart('image/jpeg', bytes);
      
      try {
        final response = await _model.generateContent([
          Content.multi([prompt, imagePart])
        ]).timeout(const Duration(seconds: 30));

        setState(() {
          _detectedAnimal = response.text ?? 'No animal detected';
          _animalDetails = response.text;
          _isDetecting = false;
        });
      } on SocketException catch (e, stackTrace) {
        _logError('Network error during animal detection', e, stackTrace);
        setState(() {
          _errorMessage = 'Network error: Please check your internet connection and try again.';
          _isDetecting = false;
        });
      } on TimeoutException catch (e, stackTrace) {
        _logError('Request timed out', e, stackTrace);
        setState(() {
          _errorMessage = 'Request timed out. Please try again.';
          _isDetecting = false;
        });
      } catch (e, stackTrace) {
        _logError('Animal detection failed', e, stackTrace);
        setState(() {
          _errorMessage = 'Error detecting animal: ${e.toString()}';
          _isDetecting = false;
        });
      }
    } catch (e, stackTrace) {
      _logError('Image processing failed', e, stackTrace);
      setState(() {
        _errorMessage = 'Error processing image: ${e.toString()}';
        _isDetecting = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Detection'),
      ),
      body: _errorMessage != null
          ? Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _initializeCamera,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: _selectedImage != null
                      ? Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        )
                      : _isCameraInitialized
                          ? CameraPreview(_controller!)
                          : const Center(child: CircularProgressIndicator()),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isDetecting ? null : _pickImage,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Upload Photo'),
                          ),
                          if (_isCameraInitialized)
                            ElevatedButton.icon(
                              onPressed: _isDetecting ? null : _detectAnimal,
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Take Photo'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _isDetecting ? null : _detectAnimal,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        child: _isDetecting
                            ? const CircularProgressIndicator()
                            : const Text('Detect Animal'),
                      ),
                      if (_detectedAnimal != null) ...[
                        const SizedBox(height: 20),
                        Text(
                          'Detected Animal:',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _detectedAnimal!,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 