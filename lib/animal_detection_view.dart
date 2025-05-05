import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'dart:convert';
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
  Map<String, dynamic>? _parsedAnimalData;
  bool _showResults = false;

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
        imageQuality: 100,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
          _showResults = false;
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

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available on this device';
        });
        return;
      }

      try {
        _controller = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _controller!.initialize();
        
        await _controller!.setFocusMode(FocusMode.auto);
        
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

  Map<String, dynamic>? _parseAnimalData(String? jsonString) {
    if (jsonString == null) return null;
    
    try {
      // Clean the response string to ensure it's valid JSON
      String cleanedJson = jsonString.trim();
      
      // Remove any markdown code block indicators
      if (cleanedJson.startsWith('```json')) {
        cleanedJson = cleanedJson.substring(7);
      }
      if (cleanedJson.startsWith('```')) {
        cleanedJson = cleanedJson.substring(3);
      }
      if (cleanedJson.endsWith('```')) {
        cleanedJson = cleanedJson.substring(0, cleanedJson.length - 3);
      }
      
      // Remove any leading/trailing whitespace and newlines
      cleanedJson = cleanedJson.trim();
      
      // Parse the cleaned JSON
      final parsed = json.decode(cleanedJson);
      
      // Ensure we have a Map
      if (parsed is! Map<String, dynamic>) {
        return null;
      }
      
      return parsed;
    } catch (e) {
      debugPrint('JSON parsing error: $e');
      debugPrint('Original response: $jsonString');
      return null;
    }
  }

  Widget _buildAnimalInfoCard(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDosAndDontsCard() {
    if (_parsedAnimalData == null || _parsedAnimalData!['dos_and_donts'] == null) {
      return const SizedBox.shrink();
    }

    final dosAndDonts = _parsedAnimalData!['dos_and_donts'];
    if (dosAndDonts is! List || dosAndDonts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dos and Don\'ts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...dosAndDonts.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.circle,
                    size: 8,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalDetails() {
    if (_parsedAnimalData == null) {
      return const Center(
        child: Text(
          'No animal detected or data could not be parsed',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_parsedAnimalData!['common_name'] != null)
            _buildAnimalInfoCard('Common Name', _parsedAnimalData!['common_name']),
          if (_parsedAnimalData!['scientific_name'] != null)
            _buildAnimalInfoCard('Scientific Name', _parsedAnimalData!['scientific_name']),
          if (_parsedAnimalData!['species'] != null)
            _buildAnimalInfoCard('Species', _parsedAnimalData!['species']),
          if (_parsedAnimalData!['habitat'] != null)
            _buildAnimalInfoCard('Habitat', _parsedAnimalData!['habitat']),
          if (_parsedAnimalData!['diet'] != null)
            _buildAnimalInfoCard('Diet', _parsedAnimalData!['diet']),
          if (_parsedAnimalData!['conservation_status'] != null)
            _buildAnimalInfoCard('Conservation Status', _parsedAnimalData!['conservation_status']),
          if (_parsedAnimalData!['geographical_distribution'] != null)
            _buildAnimalInfoCard('Geographical Distribution', _parsedAnimalData!['geographical_distribution']),
          if (_parsedAnimalData!['interesting_facts'] != null)
            _buildAnimalInfoCard('Interesting Facts', _parsedAnimalData!['interesting_facts']),
          _buildDosAndDontsCard(),
        ],
      ),
    );
  }

  Future<void> _detectAnimal() async {
    if (!await _checkInternetConnection()) {
      return;
    }

    setState(() {
      _isDetecting = true;
      _errorMessage = null;
      _showResults = false;
    });

    try {
      Uint8List bytes;
      if (_selectedImage != null) {
        bytes = await _selectedImage!.readAsBytes();
      } else if (_controller != null && _isCameraInitialized) {
        try {
          final image = await _controller!.takePicture();
          bytes = await File(image.path).readAsBytes();
          await File(image.path).delete();
        } catch (e) {
          setState(() {
            _errorMessage = 'Failed to capture image: ${e.toString()}';
            _isDetecting = false;
          });
          return;
        }
      } else {
        setState(() {
          _errorMessage = 'No image source available';
          _isDetecting = false;
        });
        return;
      }
      
      final prompt = TextPart('''
        Analyze this image carefully and identify any animals present.
        Look for any living creatures, including mammals, birds, reptiles, amphibians, or fish.
        Pay attention to both large and small animals, and consider partial views or obscured animals.
        
        Your response must be in valid JSON format, starting with { and ending with }.
        Do not include any markdown formatting or additional text.
        
        Include these fields if you detect an animal:
        {
          "common_name": "The common name of the animal",
          "scientific_name": "The scientific name if known",
          "species": "The species classification",
          "habitat": "Where this animal typically lives",
          "diet": "What this animal typically eats",
          "conservation_status": "The conservation status if known",
          "interesting_facts": "Any interesting facts about this animal",
          "geographical_distribution": "Where this animal is found",
          "dos_and_donts": ["Important safety tips when encountering this animal"]
        }
        
        If you cannot confidently identify any animal, return:
        {
          "error": "No animal detected. Please ensure the animal is clearly visible in the image."
        }
      ''');
      
      final imagePart = DataPart('image/jpeg', bytes);
      
      try {
        final response = await _model.generateContent([
          Content.multi([prompt, imagePart])
        ]).timeout(const Duration(seconds: 45));

        if (response.text == null || response.text!.isEmpty) {
          setState(() {
            _errorMessage = 'No response received from the AI model';
            _isDetecting = false;
          });
          return;
        }

        final parsedData = _parseAnimalData(response.text);
        
        if (parsedData == null) {
          setState(() {
            _errorMessage = 'Failed to parse the AI model response';
            _isDetecting = false;
          });
          return;
        }

        if (parsedData['error'] != null) {
          setState(() {
            _errorMessage = parsedData['error'];
            _isDetecting = false;
          });
          return;
        }

        // Validate that we have at least some animal information
        if (!parsedData.containsKey('common_name') && 
            !parsedData.containsKey('species')) {
          setState(() {
            _errorMessage = 'No animal detected in the image. Please ensure the animal is clearly visible and try again.';
            _isDetecting = false;
          });
          return;
        }

        setState(() {
          _detectedAnimal = response.text;
          _animalDetails = response.text;
          _parsedAnimalData = parsedData;
          _isDetecting = false;
          _showResults = true;
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
    _selectedImage = null;
    _parsedAnimalData = null;
    _detectedAnimal = null;
    _animalDetails = null;
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
                  flex: 2,
                  child: _selectedImage != null
                      ? Container(
                          width: double.infinity,
                          height: double.infinity,
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        )
                      : _isCameraInitialized && _controller != null && _controller!.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: CameraPreview(_controller!),
                            )
                          : const Center(child: CircularProgressIndicator()),
                ),
                if (_showResults && _parsedAnimalData != null)
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: _buildAnimalDetails(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      if (_selectedImage == null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _isDetecting ? null : _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Upload Photo'),
                            ),
                            if (_isCameraInitialized && _controller != null && _controller!.value.isInitialized)
                              ElevatedButton.icon(
                                onPressed: _isDetecting ? null : () async {
                                  try {
                                    final image = await _controller!.takePicture();
                                    setState(() {
                                      _selectedImage = File(image.path);
                                      _errorMessage = null;
                                      _showResults = false;
                                    });
                                  } catch (e) {
                                    setState(() {
                                      _errorMessage = 'Failed to capture image: ${e.toString()}';
                                    });
                                  }
                                },
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Take Photo'),
                              ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _showResults = false;
                                  _parsedAnimalData = null;
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Take New Photo'),
                            ),
                            ElevatedButton.icon(
                              onPressed: _isDetecting ? null : _detectAnimal,
                              icon: const Icon(Icons.search),
                              label: const Text('Detect Animal'),
                            ),
                          ],
                        ),
                      ],
                      if (_isDetecting)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
} 